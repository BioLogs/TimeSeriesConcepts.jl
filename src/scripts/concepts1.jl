### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ f3e35f66-6993-11eb-2b3f-7915f3382768
begin
	using Plots
	using Random
	using TimeSeries
	using Dates
	using Statistics: mean
end

# ╔═╡ 7df5623a-698a-11eb-0291-9b9899764848
md"""
# Introduction to Time Series I

> Author: Edwin Bedolla
>
> Date: Original, 4th April 2020. This version, 7th February 2021.

This document gathers some main concepts in time series analysis as well as some examples written
for the [Julia programming language](https://julialang.org).

First, we import every module that will be used in this document.
"""

# ╔═╡ 059e0846-6994-11eb-0a0a-b1fd93c64ba3
gr();

# ╔═╡ 1d604200-6994-11eb-1b2e-1bb27449c881
md"""
## Definitions

> - A **time series** is a collection of **random variables** indexed in a *ordered set* representing time periods.

> - **Stochastic processes** are a family of _indexed_ random variables $Z(\omega, t)$
>   where $\omega$ belongs to a **sample space** and $t$ belongs to an **index set**.

> - For a given $\omega$, $Z(\omega, t)$ as a function of $t$ is called a sample function or **realisation**.

> - The population that consists of all possible realisations is called the **ensemble**.

From these definitions we can see that a *time series* is actually a *stochastic process*.
We will now turn to see some simple examples of time series and how to program them in `Julia`.

"""

# ╔═╡ 2a51d53c-6994-11eb-3834-0d546ce983c9
md"""
## Examples

### 1. **White noise**

One of the basic time series is **white noise**, which is a time series
generated from uncorrelated variables, which are most of the time *normally distributed*.

"""

# ╔═╡ 5681a222-6994-11eb-1ce0-370b0c741e80
# Create a range of time for a year, spaced evenly every 10 hours
dates = DateTime(2018, 1, 1, 1):Dates.Hour(10):DateTime(2018, 12, 31, 24);

# ╔═╡ 5fd0b4bc-6994-11eb-2423-7b82cb249212
# Build a TimeSeries object with the specified time range and white noise
ts = TimeArray(dates, randn(length(dates)));

# ╔═╡ 722194d8-6994-11eb-0345-25a122d42c0d
plot(ts, leg=false)

# ╔═╡ 85ccb094-6994-11eb-1690-c38c7c43b7c4
md"""
This collection of random variables $\{x_t\}$ has the following properties:

```math
\mu_x = 0
```

```math
\sigma^2_x = 1
```

They are *independently and identically distributed* such that

```math
x_t \sim i.i.d. \mathcal{N}(0, 1)
```

We can see that this time series is very *noisy*, with big peaks all over the place;
if we wanted to do some meaningful analysis on it we might have a difficult time.
Instead we can apply a very simple **smoothing** technique named the **moving average**.

"""

# ╔═╡ b23b3fce-6994-11eb-28ea-e354d2ce8fbf
md"""
### 2. **Moving average**

The **moving average** is an actual time series in itself defined as

```math
v_t = \frac{1}{N} \sum_{i=0}^{N-1} w_{t-i}
```

which means that the *moving average* takes as input the neighboring values
in the past
and future time periods and evaluates them, obtaining the **realization** as an arithmetic
mean. The following example applies a moving average to a white noise time series.

"""

# ╔═╡ ebf6d020-6994-11eb-0c7e-455eb2805265
# Create a range of time for a year, spaced evenly every 50 hours
dates1 = DateTime(2018, 1, 1, 1):Dates.Hour(50):DateTime(2018, 12, 31, 24);

# ╔═╡ f6858432-6994-11eb-32ef-979ff0ffbada
# Build a TimeSeries object with the specified time range and white noise
ts1 = TimeArray(dates1, randn(length(dates1)));

# ╔═╡ 25706cee-6995-11eb-361f-efd74443d4df
# Moving average using 3 values
moving_average = moving(mean, ts1, 3);

# ╔═╡ 2c84f072-6995-11eb-35b2-f76c27eeb3ce
# And plot both of them superimposed
begin
	plot(ts, label = "White noise")
	plot!(moving_average, label = "Moving average")
end

# ╔═╡ 3a0e0968-6995-11eb-175f-612026c9c3d8
md"""
In this case we used the following 3-valued moving average

```math
v_t = \frac{1}{3} \left( w_{t-1} + w_{t} + w_{t+1} \right)
```

We can see that most of the peaks are gone, but we can still observe the main structure
of the original time series.

"""

# ╔═╡ 61dbad7e-6995-11eb-1a7f-8f683553d132
md"""
### 3. **Random walks with drift**

The analysis of *trends* is one of the prime examples of time series, where there is
a need to explore and understand what has been happening throughout several time periods.
For example, one might need to understand how the global temperature has been rising
since 1997 until today.

To model this type of time series we have the following

```math
x_t = \delta t + \sum_{j=1}^{t} w_j
```

where, as before, ``w_j`` is a white noise time series, with ``\sigma_w = 1``;
``\delta`` is the so-called *drift* coefficient that makes the trend in the time
series much more steep. In the special case that we have ``\delta = 0`` we would
have what's called a simple *random walk*.

We can see an example of a random walk *with drift* and *without drift* below.

"""

# ╔═╡ 8265a574-6995-11eb-333c-73dc1f662455
# Create a range of time for a year, spaced evenly every 50 hours
dates2 = DateTime(2018, 1, 1, 1):Dates.Hour(50):DateTime(2018, 12, 31, 24);

# ╔═╡ 8dcfcf46-6995-11eb-15f0-ffb4087992f5
# Build a TimeSeries object with the specified time range and white noise
wt = randn(length(dates2));

# ╔═╡ 93ae4a78-6995-11eb-17f5-a758fa6d7160
# Define a drift value
δ = 0.2;

# ╔═╡ 973d5198-6995-11eb-136f-1d2bf3820068
# We then build the random walk with drift
ts_drift = TimeArray(dates2, cumsum(wt .+ δ));

# ╔═╡ 9d400022-6995-11eb-2064-fd73bfa9a5b2
# And without drift
ts_nodrift = TimeArray(dates2, cumsum(wt));

# ╔═╡ a502c678-6995-11eb-1f1e-752a083ca379
# And plot both of them superimposed
begin
	plot(ts_drift, label = "Random walk with drift")
	plot!(ts_nodrift, label = "Random walk without drift")
end

# ╔═╡ b5292362-6995-11eb-06b8-5f2deab48e73
md"""
Here we see a *trend* in the time series because every time period in the future
the *realization* is always higher than in past values.We might expect that this
time series is always growing. We will see that *trends* are very useful to perform
some basic exploratory analysis on the data itself in further documents.

"""

# ╔═╡ Cell order:
# ╟─7df5623a-698a-11eb-0291-9b9899764848
# ╠═f3e35f66-6993-11eb-2b3f-7915f3382768
# ╠═059e0846-6994-11eb-0a0a-b1fd93c64ba3
# ╟─1d604200-6994-11eb-1b2e-1bb27449c881
# ╟─2a51d53c-6994-11eb-3834-0d546ce983c9
# ╠═5681a222-6994-11eb-1ce0-370b0c741e80
# ╠═5fd0b4bc-6994-11eb-2423-7b82cb249212
# ╠═722194d8-6994-11eb-0345-25a122d42c0d
# ╟─85ccb094-6994-11eb-1690-c38c7c43b7c4
# ╟─b23b3fce-6994-11eb-28ea-e354d2ce8fbf
# ╠═ebf6d020-6994-11eb-0c7e-455eb2805265
# ╠═f6858432-6994-11eb-32ef-979ff0ffbada
# ╠═25706cee-6995-11eb-361f-efd74443d4df
# ╠═2c84f072-6995-11eb-35b2-f76c27eeb3ce
# ╟─3a0e0968-6995-11eb-175f-612026c9c3d8
# ╟─61dbad7e-6995-11eb-1a7f-8f683553d132
# ╠═8265a574-6995-11eb-333c-73dc1f662455
# ╠═8dcfcf46-6995-11eb-15f0-ffb4087992f5
# ╠═93ae4a78-6995-11eb-17f5-a758fa6d7160
# ╠═973d5198-6995-11eb-136f-1d2bf3820068
# ╠═9d400022-6995-11eb-2064-fd73bfa9a5b2
# ╠═a502c678-6995-11eb-1f1e-752a083ca379
# ╟─b5292362-6995-11eb-06b8-5f2deab48e73
