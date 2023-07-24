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

module Signals

#import DSP as dsp
import AbstractFFTs as fft
import FFTW
#import StatsBase as sb


export Signal, frequency_spectrum, mean_amplitude_spectrum


struct Signal{T<:Number} <: AbstractVector{T}
    data::AbstractVector{T}
    fs::Real
end

Signal(n::Number, fs::Real) = n

# AbstractArray interface
Base.size(A::Signal) = size(A.data)
Base.getindex(A::Signal, i::Int) = getindex(A.data, i)
Base.setindex!(A::Signal, v, i::Int) = setindex!(A.data, v, i)
# Optional
Base.IndexStyle(A::Signal) = IndexStyle(A.data)
Base.getindex(A::Signal, I...) = Signal(getindex(A.data, I...), A.fs)
Base.setindex!(A::Signal, X, I...) = Signal(setindex!(A.data, X, I...), A.fs)
Base.iterate(A::Signal) = iterate(A.data)
Base.length(A::Signal) = length(A.data)
Base.similar(A::Signal) = Signal(similar(A.data), A.fs)
Base.similar(A::Signal, ::Type{S}) where S = Signal(similar(A.data, S), A.fs)
Base.similar(A::Signal, dims::Dims) = Signal(similar(A.data, dims), A.fs)
Base.similar(A::Signal, ::Type{S}, dims::Dims) where S = Signal(similar(A.data, S, dims), A.fs)
Base.axes(A::Signal) = axes(A.data)
#Base.similar(A::Signal, ::Type{S}, inds) where S = Signal(similar(A.data, S, inds), A.fs) # create ambiguity
Base.similar(T::Union{Signal, Function}, inds) = Signal(A.data(Base.to_shape(inds)), A.fs)



# DSP functions

power_to_decibel(n) = 10 * log10(n)
power_from_decibel(n) = 10^(n / 10)


function frequency_spectrum(f::Function, signal::Signal)
    psd = f.(fft.fft(signal))
    psd_freqs = (0:length(signal)) .* signal.fs ./ length(signal)
    psd_freqs = psd_freqs[1:end-1]

    # Second half of the spectrum is mirror of first half.
    psd = psd[1:div(length(psd), 2)]
    psd_freqs = psd_freqs[1:div(length(psd_freqs), 2)]

    return psd_freqs, psd
end

frequency_spectrum(sig::Signal) = frequency_spectrum(identity, sig)

mean_amplitude_spectrum(sig::Signal) = frequency_spectrum(x -> abs(x) / length(sig), sig)



end # module Signal
