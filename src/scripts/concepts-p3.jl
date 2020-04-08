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
ar = @. xt[1:(end-1)] - 0.7 * xt[2:end]
df_ar = TimeArray(dates[1:(end-1)], ar) |> DataFrame
@df df_ar plot(:timestamp[1:100], :A[1:100])

#+
println(cov(df_ar[:, :A], df_ar[:, :A]))

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
# true_γ = 1 / 9
# γ_hand = avf(df[:, :A], 2)
# γ_jl = cov(df[1:(end - 2), :A], df[3:end, :A])

#+ hold = true
# println("True autocovariance value: $true_γ")
# println("AVF by hand: $γ_hand")
# println("AVF using Julia: $γ_jl")

#+ results = "hidden"
function acrf(x::AbstractArray, h::Integer)
    return avf(x, h) / avf(x, 0)
end

#+ results = "hidden"
# true_ρ = 1 / 3
# ρ_hand = acrf(df[:, :A], 2)
# ρ_jl = cor(df[1:(end - 2), :A], df[3:end, :A])
