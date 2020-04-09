#+ results = "hidden"
using StatsPlots
using Random
using TimeSeries
using Dates
using Statistics
using DataFrames

pyplot()

# Ensure reproducibility of the results
rng = MersenneTwister(5489)

#+ results = "hidden"
# Create a range of time for a year, spaced evenly every 1 minute
dates = DateTime(2018, 1, 1, 1):Dates.Minute(1):DateTime(2018, 12, 31, 24)
# Build a TimeSeries object with the specified time range and white noise
xt = randn(rng, length(dates))

#+
ar = 5.0 .+ xt[1:(end-1)] - 0.7 * xt[2:end]
# Note that we need to remove the last element from the dates
df_ar = TimeArray(dates[1:(end-1)], ar) |> DataFrame
# We can now plot the time series, only 100 elements though
@df df_ar plot(:timestamp[1:100], :A[1:100])

#+
true_γ = 1.49

#+
cov(df_ar[:, :A], df_ar[:, :A])

#+ results = "hidden"
function avf(x::AbstractArray, h::Integer)
    # Get the total number of elements in the time series
    n = length(x)
    # Compute sample mean
    μ = sum(x) / n
    # Initialize the sample autocovariance
    γ = 0.0

    # Get the final index according to the lag
    endidx = Int(n - h)
    # Use the definition for the sample autocovariance
    @inbounds for i in 1:endidx
        γ += (x[i + h] - μ) * (x[i] - μ)
    end

    # And normalize
    return γ / n
end

#+
γ_hand = avf(df_ar[:, :A], 0)

#+ results = "hidden"
function acrf(x::AbstractArray, h::Integer)
    # Get the total number of elements in the time series
    n = length(x)
    # Obtain the sample mean
    μ = sum(x) / n

    # Compute the autocovariance for a time series
    # without lag
    autocov = sum((x[i] - μ)^2 for i = eachindex(x))
    # Normalize
    autocov /= n

    # Get the autocovariance with lag and divide it
    # by the one without lag
    return avf(x, h) / autocov
end

#+
ρ_hand = acrf(df_ar[:, :A], 1)

#+
ρ_jl = cor(df_ar[1:(end - 1), :A], df_ar[2:end, :A])
