# MIT License

# Copyright (c) 2023 Can Aknesil

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

using NPZ
import PyPlot as plt
import AbstractFFTs as fft
import FFTW
import Statistics as s
import DSP as dsp


fname_pre = ARGS[1]
unary_fname = "$(fname_pre)_fpga-data.bin"
npy_fname = "$(fname_pre).npy"

t_fine_bit_width = parse(Int, ARGS[2])
n_chain = parse(Int, ARGS[3])


### plotting
rcParams = plt.PyDict(plt.matplotlib."rcParams")

plt_colors = rcParams["axes.prop_cycle"].by_key()["color"]
get_from_cycle(arr, n) = arr[(n-1) % length(arr) + 1]
###


# reading vec with increasing index, least significant bit first
function to_bitvector(vec::AbstractVector{<:Unsigned})
    bits = BitVector()
    for n in vec
        for _ in 1:sizeof(typeof(n)) * 8
            push!(bits, n % 2)
            n >>= 1
        end
    end
    return bits
end

function fundamental_freq(x::AbstractVector)
    _, idx = findmax(abs.(fft.fft(x)[2:div(length(x), 2)]))
    return idx
end

"size(data): (tdl_length, n_samples)"
function tdl_mean(data::AbstractMatrix)
    avg = s.mean(data, dims=2)[:,1]
    avg = dsp.conv(avg, ones(4)) ./ 4 # due to carry chain being 4-bit
    return avg[1 + 1:end - 2]
end

# positive pulses (0 -> 1 -> 0)
# ignoring pulses at edges
# sig is binary
# return vector of (start, end) inclusive, pulse length is start-end+1
function find_pulses(sig::AbstractVector)
    diff_sig = diff(sig)
    falling_edges = findall(diff_sig .< 0)
    rising_edges  = findall(diff_sig .> 0)
    if falling_edges[1] < rising_edges[1]
        falling_edges = falling_edges[2:end]
    end
    if rising_edges[end] > falling_edges[end]
        rising_edges = rising_edges[1:end-1]
    end
    @assert(length(rising_edges) == length(falling_edges))
    pulses = collect(zip(map(x->x+1, rising_edges),
                         falling_edges))
    for p in pulses
        @assert(p[1] <= p[2])
    end
    return pulses
end

get_pulse_midpoint(p) = (p[1] + p[2]) / 2
get_pulse_length(p) = p[2] - p[1] + 1

# size(data): (samples, traces)
function eye_diagram(data::AbstractMatrix, color="b")
    map(eachcol(data)) do vec
        plt.plot(vec, alpha = 40 / size(data, 1) / 4, color=color)
    end
end

normalize(vec::AbstractVector) = vec .- round(Int, s.mean(vec))

# vec is binary
median_index(vec::AbstractVector) =
    s.median(findall(vec .== 1))


# reading and shaping data
data = read(unary_fname)
println("File size: $(length(data))")

sync_char_idx = findfirst(n -> Char(n) == 'S', data)
println("sync char index: $sync_char_idx")
data = data[sync_char_idx + 1:end]

data = to_bitvector(data)

@assert(length(data) % (t_fine_bit_width * n_chain) == 0)
data = reshape(data, t_fine_bit_width, n_chain, :)
println("nr. of samples: $(size(data, 3))")


# remove measurements where sampling_clk hasn't reached until TDL
i = 1
while all(data[:,:,i] .== 0)
    global i
    i += 1
end
antenna_delay_c = i - 1
println("Antenna delay is about $antenna_delay_c cycles, removing $antenna_delay_c all zero measurements.")
data = data[:,:,1+antenna_delay_c:end]


# remove measurements where sampling_clk hasn't reached the end of TDL
#fund_freq = fundamental_freq(tdl_mean(data[:,1,:])) # nr. of periods sampling_clk that fits in TDL
#println("Fundamental frequency: $fund_freq (verify from the eye diagram)")
fund_freq = 2 # Hard coding fundamental freq. because above code is not good.
println("Removing $(fund_freq+1) measurements.")
data = data[:,:,1+fund_freq+1:end]


# average chains and eye diagram
# for chain = 1:size(data, 2)
#     plt.figure()
#     eye_diagram(data[:, chain, :])
# end

#figsize = [9, 1.4]
figsize = [4.5, 1.2]
plt.figure(figsize=figsize)
eye_diagram(data[:, 2, :])
plt.yticks([0, 1])
plt.xlabel("Tap")
plt.ylabel("Bit level")
plt.tight_layout()
plt.savefig("plotdir/eye_diagram_single_chain.pdf")


data = s.mean(data, dims=2)[:,1,:]

plt.figure(figsize=figsize)
eye_diagram(data)
plt.xlabel("Tap")
plt.ylabel("Bit value\n(averaged)")
plt.tight_layout()
plt.savefig("plotdir/eye_diagram_averaged.pdf")


# Find common pulse locations and select an appropriete one (assuming the pulse is short)
avg = tdl_mean(data)
avg = dsp.conv(avg, ones(32)) ./ 32
#plt.figure()
#plt.plot(avg)
avg = map(x -> (x > 0.5 ? 1 : 0), avg)
pulses = find_pulses(avg)
println("Pulse locations: $(get_pulse_midpoint.(pulses))")
println("Pulse lengths  : $(get_pulse_length.(pulses))")

_, idx = findmin(p -> abs(get_pulse_midpoint(p) - size(data, 1) / 2), pulses)
pulse = pulses[idx]
pulse_midpoint = round(Int, get_pulse_midpoint(pulse))
pulse_length = get_pulse_length(pulse)
println("Selecting pulse with midpoint $pulse_midpoint, length $pulse_length")


# Chop, translate, and normalize data
pulse_period = size(data, 1) / (fund_freq + 1)
println("Pulse period is estimated to be at most $pulse_period (verify from the eye diagram)")
chop_start = round(Int, pulse_midpoint - pulse_period / 2)
chop_end   = round(Int, pulse_midpoint + pulse_period / 2)
if chop_start < 1
    chop_start = 1
end
if chop_end > size(data, 1)
    chop_end = size(data, 1)
end
println("Chop range: [$chop_start, $chop_end] (verify from the eye diagram)")
data = data[chop_start:chop_end,:]

edge_data = map(eachcol(data)) do vec
    midpoint = round(Int, median_index(vec))
    
    vec2 = copy(vec)
    for i = 1:midpoint
        vec2[i] = 1
    end
    falling_edge = sum(vec2) + (chop_start - 1)

    vec2 = copy(vec)
    for i = midpoint:length(vec2)
        vec2[i] = 1
    end
    rising_edge = -sum(vec2) + (length(vec2) + chop_start - 1)

    return falling_edge, rising_edge
end

falling_edge_data = map(d -> d[1], edge_data)
rising_edge_data  = map(d -> d[2], edge_data)

falling_edge_data_mean = s.mean(falling_edge_data)
tap_delay = 12.9e-9 / 800
fs = 100e6
println("Average propagation in TDC: $(falling_edge_data_mean) taps")
println("Average antenna delay: $((1/fs * antenna_delay_c + tap_delay * falling_edge_data_mean) * 1e9) nanoseconds")

plt.figure(figsize=[10, 3])
plt.plot(falling_edge_data)
plt.xlabel("Sample")
plt.ylabel("TDC delay (tap)")
plt.tight_layout()
# !!! Falling edge in this code file means rising edge of the sampling clk !!!
plt.savefig("plotdir/measurement_rising_edge.pdf") 

plt.figure()
plt.plot(rising_edge_data)

#pulse_length_data = falling_edge_data .- rising_edge_data
#plt.figure()
#plt.plot(pulse_length_data)

#falling_edge_data = normalize(falling_edge_data)
#rising_edge_data  = normalize(rising_edge_data)


# Write data
npzwrite("$(fname_pre)_falling-edge_t-fine.npy", falling_edge_data)
npzwrite("$(fname_pre)_rising-edge_t-fine.npy", rising_edge_data)
#npzwrite("$(fname_pre)_pulse-length_t-fine.npy", pulse_length_data)


#plt.show()


