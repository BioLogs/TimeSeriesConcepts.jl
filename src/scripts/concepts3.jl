### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ e660c4b8-6999-11eb-3f49-f171c07a7062
begin
	using StatsPlots
	using Random
	using TimeSeries
	using Dates
	using Statistics
	using DataFrames
end

# ╔═╡ ba9e0f02-6999-11eb-003c-ff442833cf0b
md"""
# Introduction to Time Series III

> Author: Edwin Bedolla
>
> Data: Original, May 6th, 2020. This version, 7th February 2021.

This document closes the introduction to Time Series by exploring the last concepts which
are the *estimation* of the **autocovariance** and **autocorrelation** functions, with a
simple example.

As always, we import the needed packages.

"""

# ╔═╡ f6a2939c-6999-11eb-0bd5-855cff3d8171
gr();

# ╔═╡ f92da192-6999-11eb-386d-b185e1e75364
# Ensure reproducibility of the results
rng = MersenneTwister(5489);

# ╔═╡ fc8ba370-6999-11eb-3438-1fe2a079401e
md"""
## Estimation of correlation

In the last part we studied the **theoretical** definitions of the autocorrelation (ACF) 
and autocovariance functions (AVF), where we did some extensive examples on how to compute the 
theoretical values.

But in reality we only have *sampled data* and we usually just have a subset or 
*sample* of the original *population.* When that is the case, we can only estimate
the respective statistics by using **estimated** methods. In this document we will
explore the definitions and algorithms to estimate the autocorrelation and
autocovariance functions, we close the document exploring the **lag operator** and the
importance of it.

We start with a simple example.

"""

# ╔═╡ 0720775c-699a-11eb-3fdf-aba950119a6f
# Create a range of time for a year, spaced evenly every 1 minute
dates = DateTime(2018, 1, 1, 1):Dates.Minute(1):DateTime(2018, 12, 31, 24);

# ╔═╡ 0fc5a500-699a-11eb-3703-5d2262a3ea77
# Create a white noise array
xt = randn(rng, length(dates));

# ╔═╡ 14348eb0-699a-11eb-2427-b31244499c48
md"""
### Autoregressive time series

In this section we will build an **autoregressive time series**; this is a big topic within
Time Series analysis so we will have a special chapter for that, but here we want
to introduce the concept.

An autoregressive time series takes information from past intervals to build
future information. We will build an autoregressive time series now and plot it.
"""

# ╔═╡ 1f184cea-699a-11eb-180f-93c070a28df9
# This is the autoregressive time series
ar = @. 5.0 + xt[1:(end-1)] - 0.7 * xt[2:end];

# ╔═╡ 2d913bb0-699a-11eb-268b-4f142ec0c262
# Note that we need to remove the last element from the dates
df_ar = TimeArray(dates[1:(end-1)], ar) |> DataFrame;

# ╔═╡ 3fd5eda2-699a-11eb-0dc3-1dd47b2abd60
# Plotting indices
idxs = 1:200;

# ╔═╡ 327b97a6-699a-11eb-2a3b-bd798f261a50
# We can now plot the time series, only 100 elements though
@df df_ar plot(:timestamp[idxs], :A[idxs])

# ╔═╡ 4cb0bb06-699a-11eb-21e3-f9dc016d4ef3
md"""
As we can see, this time series is not really different from the ones that we
have studied so far, but one of the fundamental properties of the autoregressive
model or time series is that is shows **periodicity**; we will explore all of this
later.

"""

# ╔═╡ 5a5dfe3a-699a-11eb-079e-33d9f0391bc1
md"""
### Correlation of an autoregressive time series

As we said before, we are concerned with estimating the ACF and AVF of a time
series when we only have sampled data at hand. In the case of the autoregressive
time series we are studying, I have obtained the true value of the AVF,
``\gamma`` which is the following

"""

# ╔═╡ 6e9d7434-699a-11eb-3686-d95a3b2eb686
true_γ = 1.49;

# ╔═╡ 781bce66-699a-11eb-3298-69d8c28bd143
md"""
We compare it to `Julia`'s built-in function to compute the covariance
value of the time series.
"""

# ╔═╡ 80747da6-699a-11eb-05b7-2d59cfa8f535
julia_γ = cov(df_ar[:, :A], df_ar[:, :A])

# ╔═╡ 8aa25e42-699a-11eb-300a-eda4c5ae4ef9
md"""

#### Autocovariance function

We now turn our attention to defining the estimated, *unbiased* AVF, which
is defined as follows

```math
\hat{\gamma}(h)=\frac{1}{n} \sum_{t=1}^{n-h} (x_{t+h}-\bar{x}) (x_{t}-\bar{x})
```

where the **sample mean**, ``\bar{x}``, is estimated as

```math
\bar{x}=\frac{1}{N} \sum_{i}^N x_i
```

We will now implement the estimated AVF in `Julia`.
"""

# ╔═╡ a7178d88-699a-11eb-35f6-a921abd1b7dd
function avf(x, h::Integer)
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
end;

# ╔═╡ b452ff9e-699a-11eb-1c30-e58c82796b47
md"""
Let us now use this new function and compute the estimated AVF.
"""

# ╔═╡ bb0c3172-699a-11eb-1956-fdba69b12e4f
γ_by_hand = avf(df_ar[:, :A], 0)

# ╔═╡ c21299a8-699a-11eb-1cc6-fbefa6e663b1
md"""
We can see that the results are very similar to those obtained with 
the built-in `cov`, and very close to the true theoretical value. We can obtain
the true theoretical value with increasing samples from the time series.
"""

# ╔═╡ c9c05052-699a-11eb-1cf9-13bbde5a16c4
md"""
#### Autocorrelation function

A similar estimator for the ACF can be used, and in particular we have

```math
\hat{\rho}(h)=\frac{\hat{\gamma}(h)}{\hat{\gamma}(0)}=\frac{\sum_{t=1}^{N-h} (x_{t+h}-\bar{x}) (x_{t}-\bar{x})}{\sum_{t=1}^{N} (x_{t}-\bar{x})^2}
```

so we can use this to our advantage and employ the AVF to compute the ACF.

In our implementation we exploit this property bellow.
"""

# ╔═╡ e2d0731a-699a-11eb-0b57-5d8d2f14aa05
function acf(x, h::Integer)
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
end;

# ╔═╡ eb28f34a-699a-11eb-2a8e-05a9d4c85a39
md"""
We now compute the estimated ACF. Notice that we need to specify the value of
``h=1`` which adds a *lag* to the time series.
"""

# ╔═╡ f3f50a02-699a-11eb-2260-5389e475279c
ρ_by_hand = acf(df_ar[:, :A], 1)

# ╔═╡ fb2c920e-699a-11eb-1981-d3610f2bec4e
md"""
We now compare it to the one obtained by the Pearson correlation function with
the built-in `cor` function in `Julia`.
"""

# ╔═╡ 045e3a6e-699b-11eb-175e-3db7a6a91aa0
ρ_julia = cor(df_ar[1:(end - 1), :A], df_ar[2:end, :A])

# ╔═╡ 0a0c7a5a-699b-11eb-3407-1b91a137ddeb
md"""
The results are quite similar, just as we expected.
"""

# ╔═╡ 1286d234-699b-11eb-02f9-87c97528f072
md"""
## Lag in Time Series

Up until now we have mentioned several times the word **lag** in different scenarios.
It is now time to address the meaning of this word in the context of Time Series.
Time Series are a process in different time intervals, and we are sometimes interested
in what happens between two time intervals ``s`` and ``t``
within the same Time Series.

A special type of operation, called the **lag operator** produces the value of a previous
time interval with respect to the current time interval.
The lag operator is denoted by ``L`` and when applied to a Time Series
``X=\{x_1,x_2,x_3,\dots\}`` we get the following

```math
Lx_k = x_{k-1}
```

When doing something like this `df_ar[1:(end-1), :A]` we are essentially applying the lag
operator by hand, were the lag is one in this case. The `TimeSeries` package has support for this. Let us do a simple example computing the ACF like before.

"""

# ╔═╡ 65f6025a-699b-11eb-3ade-79ceaaab9d13
# We need to use a TimeArray in order to apply the lag operator
ts = TimeArray(dates[1:(end-1)], ar);

# ╔═╡ 6e93168c-699b-11eb-019b-e14265dbc1dd
# We use lag to put the past value in the current value of the time series
ts_lag = lag(ts) |> DataFrame;

# ╔═╡ 72f6ffea-699b-11eb-1a40-0fcd4586faf2
# Convert to DataFrame for easier handling
df_ts = DataFrame(ts);

# ╔═╡ 7a25936c-699b-11eb-1814-5348ae852ed3
# Compute the ACF, note that instead of using indexing we just use the
# lagged time series first
lag_value = cor(ts_lag[:, :A], df_ts[2:end, :A]);

# ╔═╡ 7e4ab922-699b-11eb-0940-31f4a6eef3b5
# And it should be the same as before
lag_value == ρ_julia

# ╔═╡ 91586a8c-699b-11eb-33e9-c1a053cb23c2
md"""
We can go back to an arbitrary time interval if we *raise* the lag operator to a given 
*power*, like so

```math
L^n x_k = x_{k-n}
```

for example ``L^2 x_k = x_{x-2}`` so we actually got the
previous-to-last value from the time series.

Furthermore, because the lag operator can be raised to arbitrary powers we can build
**polynomials** out of the lag operator, like so

```math
a(L) = a_0 + a_1 L + a_2 L^2 + \cdots \\
a(L)x_t = a_0 x_t + a_1 x_{t-1} + a_2 x_{t-2} + a_3 x_{t-3} \cdots
```

which resembles an autoregressive time series. In fact it is the use in autoregressive 
models and moving averages where the lag operator is of the utmost importance.

For example, in this document we used the autoregressive model

```math
y_t = 5+x_t-0.7x_{t-1}
```

which could be written in terms of the lag operator as

```math
y_t = 5+x_t-0.7Lx_t = 5+x_t(1-0.7L) .
```

We will come back to this when we study the
[ARIMA processes](https://en.wikipedia.org/wiki/Autoregressive_integrated_moving_average) later on.

"""

# ╔═╡ Cell order:
# ╟─ba9e0f02-6999-11eb-003c-ff442833cf0b
# ╠═e660c4b8-6999-11eb-3f49-f171c07a7062
# ╠═f6a2939c-6999-11eb-0bd5-855cff3d8171
# ╠═f92da192-6999-11eb-386d-b185e1e75364
# ╟─fc8ba370-6999-11eb-3438-1fe2a079401e
# ╠═0720775c-699a-11eb-3fdf-aba950119a6f
# ╠═0fc5a500-699a-11eb-3703-5d2262a3ea77
# ╟─14348eb0-699a-11eb-2427-b31244499c48
# ╠═1f184cea-699a-11eb-180f-93c070a28df9
# ╠═2d913bb0-699a-11eb-268b-4f142ec0c262
# ╠═3fd5eda2-699a-11eb-0dc3-1dd47b2abd60
# ╠═327b97a6-699a-11eb-2a3b-bd798f261a50
# ╟─4cb0bb06-699a-11eb-21e3-f9dc016d4ef3
# ╟─5a5dfe3a-699a-11eb-079e-33d9f0391bc1
# ╠═6e9d7434-699a-11eb-3686-d95a3b2eb686
# ╟─781bce66-699a-11eb-3298-69d8c28bd143
# ╠═80747da6-699a-11eb-05b7-2d59cfa8f535
# ╟─8aa25e42-699a-11eb-300a-eda4c5ae4ef9
# ╠═a7178d88-699a-11eb-35f6-a921abd1b7dd
# ╟─b452ff9e-699a-11eb-1c30-e58c82796b47
# ╠═bb0c3172-699a-11eb-1956-fdba69b12e4f
# ╟─c21299a8-699a-11eb-1cc6-fbefa6e663b1
# ╟─c9c05052-699a-11eb-1cf9-13bbde5a16c4
# ╠═e2d0731a-699a-11eb-0b57-5d8d2f14aa05
# ╟─eb28f34a-699a-11eb-2a8e-05a9d4c85a39
# ╠═f3f50a02-699a-11eb-2260-5389e475279c
# ╟─fb2c920e-699a-11eb-1981-d3610f2bec4e
# ╠═045e3a6e-699b-11eb-175e-3db7a6a91aa0
# ╟─0a0c7a5a-699b-11eb-3407-1b91a137ddeb
# ╟─1286d234-699b-11eb-02f9-87c97528f072
# ╠═65f6025a-699b-11eb-3ade-79ceaaab9d13
# ╠═6e93168c-699b-11eb-019b-e14265dbc1dd
# ╠═72f6ffea-699b-11eb-1a40-0fcd4586faf2
# ╠═7a25936c-699b-11eb-1814-5348ae852ed3
# ╠═7e4ab922-699b-11eb-0940-31f4a6eef3b5
# ╟─91586a8c-699b-11eb-33e9-c1a053cb23c2
