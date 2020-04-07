#+ results = "hidden"
using Plots
using Random
using TimeSeries
using Dates
using Statistics
using DataFrames

pyplot()

# Ensure reproducibility of the results
rng = MersenneTwister(8092)

#+ results = "hidden"
# Create a range of time for a year, spaced evenly every 50 hours
dates = DateTime(2018, 1, 1, 1):Dates.Minute(1):DateTime(2018, 12, 31, 24)
# Build a TimeSeries object with the specified time range and white noise
ts = TimeArray(dates, randn(rng, length(dates)))
moving_average = moving(mean, ts, 3)
# Create a DataFrame with it
df = DataFrame(moving_average)

#+ results = "hidden"
function avf(x::AbstractArray, h::Integer)
    n = length(x)
    # Compute sample mean
    μ = mean(x)
    γ = 0.0

    endidx = Int(n - h)
    @inbounds for i in 1:endidx
        γ += (x[i + h] - μ) * (x[i] - μ)
    end

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
    return avf(x, h) / avf(x, 0)
end

#+ results = "hidden"
true_ρ = 1 / 3
ρ_hand = acrf(df[:, :A], 2)
ρ_jl = cor(df[1:(end - 2), :A], df[3:end, :A])
