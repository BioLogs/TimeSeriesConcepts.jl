using Plots
using Random
using TimeSeries
using Dates
using Statistics
using DataFrames
using Test

pyplot()

rng = MersenneTwister(8092)

# Create a range of time for a year, spaced evenly every 50 hours
dates = DateTime(2018, 1, 1, 1):Dates.Minute(1):DateTime(2018, 12, 31, 24)
# Build a TimeSeries object with the specified time range and white noise
ts = TimeArray(dates, randn(rng, length(dates)))
moving_average = moving(mean, ts, 3)
# Create a DataFrame with it
df = DataFrame(moving_average)

function acf(x::AbstractArray, h::Integer)
    n = length(x)
    # Compute sample mean
    μ = sum(x) / n
    γ = 0.0

    endidx = Int(n-h)
    @inbounds for i in 1:endidx
        γ += (x[i+h] - μ) * (x[i] - μ)
    end

    return γ / ((n - h) * var(x))
end

γ = acf(df[:, :A], 2)
println(γ)
n = df[:, :A] |> length
println(cor(df[1:(end-2), :A], df[3:end, :A]))
# println(1 / 9)
println(1 / 3)
