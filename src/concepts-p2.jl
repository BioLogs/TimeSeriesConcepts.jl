#+ results = "hidden"
using Plots
using Random
using TimeSeries
using Dates
using Statistics
using DataFrames
using Test

pyplot()
# Define a seed to enable reproducibility
rng = MersenneTwister(8092)

#+ results = "hidden"
# Create a range of time for a year, spaced evenly every 1 minute
dates = DateTime(2018, 1, 1, 1):Dates.Minute(1):DateTime(2018, 12, 31, 24)
# Build a TimeSeries object with the specified time range and white noise
ts = TimeArray(dates, randn(rng, length(dates)))
# Compute the 3-valued moving average of the series
moving_average = moving(mean, ts, 3)
# Create a DataFrame with it for simpler handling
df = DataFrame(moving_average)

#+ results = "hidden"
function avf(x::AbstractArray, h::Integer)
    # Total number of elements
    n = length(x)
    # Compute sample mean
    μ = mean(x)
    # Value of the covariance
    γ = 0.0

    # We cast the total number of elements as an integer
    endidx = Int(n - h)
    @inbounds for i in 1:endidx
        # Apply the sample covariance formula
        γ += (x[i + h] - μ) * (x[i] - μ)
    end

    # We return the normalized covariance value
    return γ / (n - h)
end

#+ results = "hidden"
true_γ = 1 / 9
γ_hand = avf(df[:, :A], 2)
γ_jl = cov(df[1:(end - 2), :A], df[3:end, :A])

#+ hold = true
println("True autocovariance value: $true_γ")
println("AVF by hand: $γ_hand")
println("AVF using Julia: $γ_jl")

#+ results = "hidden"
function acrf(x::AbstractArray, h::Integer)
    # Apply the sample correlation formula
    return avf(x, h) / avf(x, 0)
end

#+ results = "hidden"
true_ρ = 1 / 3
ρ_hand = acrf(df[:, :A], 2)
ρ_jl = cor(df[1:(end - 2), :A], df[3:end, :A])

#+ hold = true
println("True autocorrelation value: $true_ρ")
println("ACF by hand: $ρ_hand")
println("ACF using Julia: $ρ_jl")
