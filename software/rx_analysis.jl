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

include("Signals.jl")
using .Signals
using NPZ
import PyPlot as plt
import Statistics as s
import DSP as dsp


fname_pre = ARGS[1]
sampling_freq = parse(Float64, ARGS[2])
target_freq = parse(Float64, ARGS[3])
if length(ARGS) >= 4
    fname_pre_2 = ARGS[4] # for comparison
else
    fname_pre_2 = nothing
end

db = false
target_freq_error = 500000


#rcParams = plt.PyDict(plt.matplotlib."rcParams")
#rcParams["font.size"] = 18

function plot(f::Function, fname::AbstractString, plot_args...)
    plt.figure(figsize=[4.5, 2.5])
    f(plot_args...)
    plt.tight_layout()
    plt.savefig("plotdir/" * fname)
end

plot(fname::AbstractString, plot_args...) = plot(plt.plot, fname, plot_args...)


function resample(x::AbstractVector, y::AbstractVector, resampling_rate)
    y2 = dsp.resample(y, resampling_rate)
    x2 = collect(0.0:length(y2)-1)
    x2 .*= x[end] / x2[end]
    return x2, y2
end


load_trace(fname_pre, fs) =
    Signal(npzread("$(fname_pre)_t-fine.npy"), fs)


t_fine = load_trace(fname_pre, sampling_freq)
if !isnothing(fname_pre_2)
    t_fine_2 = load_trace(fname_pre_2, sampling_freq)
end


println("Standard deviation of t_fine: $(s.std(t_fine))")

plot("rx_measurement.pdf") do
    # !!! HARDCODED LABELS !!!
    plt.plot(t_fine, label="Tx is on: 10Vpp, 4MHz", linewidth=1, zorder=2)
    if !isnothing(fname_pre_2)
        plt.plot(t_fine_2, label="Tx is off", linewidth=1, zorder=1)
    end
    plt.xlabel("Sample")
    plt.ylabel("TDC delay (tap)")
    plt.legend()
end

psd_freqs, psd = mean_amplitude_spectrum(t_fine)
#psd[1] = 0
if !isnothing(fname_pre_2)
    psd_freqs_2, psd_2 = mean_amplitude_spectrum(t_fine_2)
    #psd_2[1] = 0
end    

plot("rx_measurement_psd.pdf") do
    # !!! HARDCODED LABELS !!!
    plt.plot(psd_freqs, psd, linewidth=1, zorder=2)
    if !isnothing(fname_pre_2)
        plt.plot(psd_freqs, psd_2, linewidth=1, zorder=1)
    end
    plt.ylim(0, 1)
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("TDC delay magnitude\n(tap)")
    plt.legend(["Tx is on: 10Vpp, 4MHz",
                "Tx is off"])
end


resampling_rate = 20
psd_freqs_smooth, psd_smooth = resample(psd_freqs, psd, resampling_rate)
if !isnothing(fname_pre_2)
    psd_freqs_2_smooth, psd_2_smooth = resample(psd_freqs_2, psd_2, resampling_rate)
end

# plot("a.png") do
#     plt.plot(psd_freqs_smooth, psd_smooth)
#     if !isnothing(fname_pre_2)
#         plt.plot(psd_freqs_smooth, psd_2_smooth)
#     end
# end


psd_diff = psd_freqs, psd - psd_2
psd_smooth_diff = psd_smooth - psd_2_smooth

if !isnothing(fname_pre_2)
    #plot("a.png", psd_diff)
    plot("a.png", psd_freqs_smooth, psd_smooth_diff)
end

target_psd_start = findfirst(>(target_freq - target_freq_error), psd_freqs_smooth)
target_psd_end   = findfirst(>(target_freq + target_freq_error), psd_freqs_smooth)
transmitter_mag_max = maximum(psd_smooth_diff[target_psd_start:target_psd_end])
println("transmitter_mag_max: $transmitter_mag_max (Validate from plot)")


#plt.show()
