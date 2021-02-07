### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 6c8602e6-6996-11eb-1df7-b9a9535458ae
begin
	using StatsPlots
	using Random
	using TimeSeries
	using Dates
	using Statistics
	using DataFrames
end

# ╔═╡ 0edc349e-6996-11eb-17fe-75948b35db2b
md"""
# Introduction to Time Series II

> Author: Edwin Bedolla
>
> Date: Original, 6th April 2020. This version, 7th February 2021.

In this document, the main statistics such as the **mean function**, **autocovariance function**
and **autocorrelation function** will be described, along with some examples.

We will import all of the necessary modules first.

"""

# ╔═╡ 75a9e6e4-6996-11eb-2bb2-892253de4b62
gr();

# ╔═╡ 9a0f887c-6996-11eb-204e-1da9ecf118b7
# Ensure reproducibility of the results
rng = MersenneTwister(8092);

# ╔═╡ 9df97102-6996-11eb-23da-43ac18f5284a
md"""
## Descriptive statistics and measures

A full description of a given time series is always given by the **joint distribution function**
of the time series which is a multi-dimensional function that is very difficult to track for
most of the time series that are dealt with.

Instead, we usually work with what's known as the **marginal distribution function** defined as

```math
F_t(x) = P \{ x_t \leq x \}
```

where ``P \{ x_t \leq x \}`` is the probability that the *realization*
of the time series ``x_t``
at time ``t`` is less or equal that the value of ``x``.
Even more common is to use a related function known as the **marginal density function**

```math
f_t(x) = \frac{\partial F_t(x)}{\partial x}
```

and when both functions exist they can provide all the information needed to do meaningful
analysis of the time series.

### Mean function

With these functions we can now define one of the most important descriptive measures,
the **mean function** which is defined as

```math
\mu_{xt} = E(x_t) = \int_{-\infty}^{\infty} x f_t(x) dx
```

where ``E`` is the *expected value operator* found in classical statistics.

### Autocovariance and autocorrelation

We are also interested in analyzing the dependence or lack of between
realization values in different
time periods, i.e. ``x_t`` and ``x_s``; in that case we can use classical
statistics to define two very important and fundamental quantities.

The first one is known as the **autocovariance function** and it's defined as

```math
\gamma_{x} (s, t) = \text{cov}(x_s,x_t) = E[(x_s - \mu_s)(x_t - \mu_t)]
```

where ``\text{cov}`` is the [covariance](https://en.wikipedia.org/wiki/Covariance)
as defined in classical statistics. A simple way of defining the *autocovariance*
is the following

> The **autocovariance** tells us about the *linear* dependence between two points on the same
> time series observed at different times.

Normally, we know from classical statistics that if for a given time series
``x_t`` we should have
``\gamma_{x} (s, t) = 0`` then it means that there is no linear
dependence between ``x_t`` and ``x_s`` at time periods ``t`` and ``s``;
but this does not mean that there is **no** relation between them
at all. For that, we need another measure that we describe below.

We now introduce the **autocorrelation function** (ACF) and it's defined as

```math
\rho(s,t) = \frac{\gamma_{x} (s, t)}{\sqrt{\gamma_{x} (s, s) \gamma_{x} (t, t)}}
```

which is a measure of **predictability** and we can define it in words as follows

> The **autocorrelation** measures the *linear predictability* of a given time series ``x_t`` at
> time ``t``, using values from the same time series but at time ``s``.

This measure is very much related to[Pearson's correlation coefficient](https://en.wikipedia.org/wiki/Pearson_correlation_coefficient)
from classical statistics, which is a way to measure the relationship between values.

The range of values for the ACF is ``-1 \leq \rho(s,t) \leq 1``;
when ``\rho(s,t) = 1`` it means that a *linear model* can perfectly describe the
realization of the time series at time ``t``
provided with the realization at time ``s``, e.g. a trend goind upwards,
on the other hand, if ``\rho(s,t) = -1`` would mean that the realization
of the time series ``x_t`` decrease while the realization ``x_s`` is increasing.

"""

# ╔═╡ a25d2f06-6997-11eb-0c96-23650463738f
md"""
## Example

Let's look at an example for the particular case of the *moving average*. We will
be working out the analytic form of the *autocovariance function* and *ACF* for the moving average
while also providing the same results numerically using `Julia`.

Recall the 3-valued moving average to be defined as

```math
v_t = \frac{1}{3} \left( w_{t-1} + w_{t} + w_{t+1} \right)
```

Let's plot the moving average again. We will create a very big time series for the sake
of numerical approximation below.

First, we create the white noise time series.

"""

# ╔═╡ b9fcb5f0-6997-11eb-1027-dda87c151112
# Create a range of time for a year, spaced evenly every 1 minute
dates = DateTime(2018, 1, 1, 1):Dates.Minute(1):DateTime(2018, 12, 31, 24);

# ╔═╡ e5e97644-6997-11eb-0104-07a8556f3c96
# Build a TimeSeries object with the specified time range and white noise
ts = TimeArray(dates, randn(rng, length(dates)));

# ╔═╡ f32d34ee-6997-11eb-1629-a7f7bede2305
# Create a DataFrame of the TimeSeries for easier handling
df_ts = DataFrame(ts);

# ╔═╡ d47822d4-6997-11eb-3d00-39a0fe53f1e2
md"""
Then, as before, we compute the 3-valued moving average.
"""

# ╔═╡ dc19ba7a-6997-11eb-1c18-2f592d5120ec
# Compute the 3-valued moving average
moving_average = moving(mean, ts, 3);

# ╔═╡ e1567d34-6997-11eb-180d-99d7c6d4ebd1
# Create a DataFrame of the TimeSeries for easier handling
df_average = DataFrame(moving_average);

# ╔═╡ fdb064f4-6997-11eb-18ff-ddfa35e5e89f
md"""
Recall what these look like in a plot. We just plot the first 100 elements in
the time series to avoid having a very cluttered plot.
"""

# ╔═╡ 1698af3a-6998-11eb-297b-8176c30e0da8
# Indices to plot
idxs = 1:100;

# ╔═╡ 03658032-6998-11eb-0225-bfbce55888f5
begin
	@df df_ts plot(:timestamp[idxs], :A[idxs], label = "White noise")
	@df df_average plot!(:timestamp[idxs], :A[idxs], label = "Moving average")
end

# ╔═╡ 0da7f61a-6998-11eb-1381-ff73d8bf8d9f
md"""
We are now ready to do some calculations. First, we invoke the definition of the
*autocovariance function* and apply it to the moving average

```math
\gamma_v(s,t)=\text{cov}(v_s,v_t)=
\text{cov}\{\frac{1}{3} \left( w_{t-1} + w_{t} + w_{t+1} \right),
\frac{1}{3} \left( w_{s-1} + w_{s} + w_{s+1} \right)\}
```

and now we need to look at some special cases.

- When ``s = t`` we now have the following

```math
\gamma_v(t,t)=\text{cov}(v_t,v_t)=
\text{cov}\{\frac{1}{3} \left( w_{t-1} + w_{t} + w_{t+1} \right),
\frac{1}{3} \left( w_{t-1} + w_{t} + w_{t+1} \right)\}
```

then, by the property of
[covariance of linear combinations](https://en.wikipedia.org/wiki/Covariance#Covariance_of_linear_combinations)
we have the following simplification

```math
\gamma_v(t,t)=\text{cov}(v_t,v_t)=
\frac{1}{9}\{\text{cov}(w_{t-1},w_{t-1}) + \text{cov}(w_{t},w_{t})
+ \text{cov}(w_{t+1},w_{t+1})\}
```

and because $\text{cov}(U,U) = \text{var}(U)$ for a random variable $U$, for a white
noise random variable we have $\text{var}(w_t)=\sigma^2_{wt}$, thus

```math
\gamma_v(t,t)=\text{cov}(v_t,v_t)= \frac{3}{9} \sigma^2_{wt}
```

In this case, recall that our white noise is normally distributed
``w_t \sim \mathcal{N}(0,\sigma^2_{wt})`` with ``\sigma^2_{wt}`` so the true expected
value is the following

"""

# ╔═╡ 67cf2bc2-6998-11eb-1c9f-f9b0bde636fe
true_γ = 3 / 9

# ╔═╡ 882be004-6998-11eb-058c-61714e97aa01
md"""
We will try to compute the *autocovariance function* using classical statistics
by means of the `cov` function in `Julia`. We need to pass it the time series like
so
"""

# ╔═╡ 91347c6a-6998-11eb-3de5-fff4ccaaca50
γ_jl = cov(df_average[:, :A], df_average[:, :A])

# ╔═╡ c78e9cb0-6997-11eb-23fa-9f1936729792
md"""
And we can see that the value is quite similar. The error must come from the fact
that we may need a bigger ensemble of values, but this should suffice.
"""

# ╔═╡ acafb36a-6998-11eb-3081-f9c9868f502d
md"""
- When ``s = t + 1`` we now have the following

```math
\gamma_v(t+1,t)=\text{cov}(v_{t+1},v_t)=
\text{cov}\{\frac{1}{3} \left( w_{t} + w_{t+1} + w_{t+2} \right),
\frac{1}{3} \left( w_{t-1} + w_{t} + w_{t+1} \right)\} \\
\gamma_v(t+1,t)=\frac{1}{9}\{\text{cov}(w_{t},w_{t}) + \text{cov}(w_{t+1},w_{t+1})\} \\
\gamma_v(t+1,t)=\frac{2}{9} \sigma^2_{wt}
```

So the true value is now
"""

# ╔═╡ bc0badd2-6998-11eb-3c7f-71441b60348b
true_γ1 = 2 / 9

# ╔═╡ c0d3f3a6-6998-11eb-1f6f-bf3d9f53c907
md"""
To check this, we perform the same operations as before, but this time, we need
to *move* the time series one time step with respect to itself.
"""

# ╔═╡ d077547e-6998-11eb-2d7f-5be66624cbb2
# Remove the last element from the first and start with the second element
γ_jl1 = cov(df_average[1:(end-1), :A], df_average[2:end, :A])

# ╔═╡ da11ef28-6998-11eb-38b9-c32091494df2
md"""
Great! Within a tolerance value, this is quite a nice estimate. It turns out that
for the cases ``s = t + h`` where ``h \geq 2``, the value for the *autocovariance*
is zero. We'll check it numerically here.
"""

# ╔═╡ e87fcae2-6998-11eb-33bd-19d5fc7c0ab3
# Remove the last element from the first and start with the second element
γ_jl_zero = cov(df_average[1:(end-3), :A], df_average[4:end, :A])

# ╔═╡ f1188e62-6998-11eb-0be9-d90fc94b3bf2
md"""
It's actually true, a value very close to zero but, _¿why?_ It's easy to see
if one applies the *autocovariance function* definition and checks the case
``s = t + 3``, and so on.

Let's now focus on the **ACF** for a 3-valued moving average.
We have several cases, like before.
"""

# ╔═╡ 05fc8600-6999-11eb-3edc-43b7a149d975
md"""
- When ``s = t`` we now have the following

```math
\rho_v(t,t)=\frac{\gamma_v(t,t)}{\sqrt{\gamma_v(t,t)\gamma_v(t,t)}}\\
\rho_v(t,t)=\frac{\gamma_v(t,t)}{\gamma_v(t,t)} = 1
```

so it turns out that the true value is ``\rho_v(t,t)=1``, and we can check this using
the `cor` function to compute the correlation coefficient in `Julia` as an estimate
for the *ACF*
"""

# ╔═╡ 17613e36-6999-11eb-0aa5-57b2d7d2ce0c
ρ_est = cor(df_average[:, :A], df_average[:, :A])

# ╔═╡ 222001f4-6999-11eb-33ca-83ec4484a65b
md"""
- When ``s = t + 1`` we now have the following

```math
\rho_v(t+1,t)=\frac{\gamma_v(t+1,t)}{\sqrt{\gamma_v(t+1,t+1)\gamma_v(t,t)}}\\
```

recall from before that ``\gamma(t,t)=3/9 \sigma_{vt}^2``
for a white noise time series, and we also have
``\gamma(t+1,t)=2/9 \sigma_{vt}^2``, so the *ACF* is now

```math
\rho_v(t+1,t)=\frac{2/9 \sigma_{vt}^2}{\sqrt{(3/9 \sigma_{vt}^2)(3/9 \sigma_{vt}^2)}}\\
\rho_v(t+1,t)=\frac{18 \sigma_{vt}^2}{27 \sigma_{vt}^2}\\
\rho_v(t+1,t)=\frac{2}{3}
```

which is the true value
"""

# ╔═╡ 45212f3e-6999-11eb-2b9c-dd5199e5f42a
true_ρ2 = 2 / 3

# ╔═╡ 4b74f596-6999-11eb-1bd2-1d6fce0f49b9
md"""
and again, we can check this value numerically
"""

# ╔═╡ 4fb34158-6999-11eb-214b-dd4ae90bb907
ρ_est2 = cor(df_average[1:(end-1), :A], df_average[2:end, :A])

# ╔═╡ 57325360-6999-11eb-37a0-fd1ba4b66d6f
md"""
Lastly, like with the *autocovariance*, the *ACF* for the cases
``s = t + h`` where ``h \geq 2``
is zero as seen below
"""

# ╔═╡ 6606538c-6999-11eb-1490-83a7727526d0
ρ_est_zero2 = cor(df_average[1:(end-3), :A], df_average[4:end, :A])

# ╔═╡ Cell order:
# ╟─0edc349e-6996-11eb-17fe-75948b35db2b
# ╠═6c8602e6-6996-11eb-1df7-b9a9535458ae
# ╠═75a9e6e4-6996-11eb-2bb2-892253de4b62
# ╠═9a0f887c-6996-11eb-204e-1da9ecf118b7
# ╟─9df97102-6996-11eb-23da-43ac18f5284a
# ╟─a25d2f06-6997-11eb-0c96-23650463738f
# ╠═b9fcb5f0-6997-11eb-1027-dda87c151112
# ╠═e5e97644-6997-11eb-0104-07a8556f3c96
# ╠═f32d34ee-6997-11eb-1629-a7f7bede2305
# ╟─d47822d4-6997-11eb-3d00-39a0fe53f1e2
# ╠═dc19ba7a-6997-11eb-1c18-2f592d5120ec
# ╠═e1567d34-6997-11eb-180d-99d7c6d4ebd1
# ╟─fdb064f4-6997-11eb-18ff-ddfa35e5e89f
# ╠═1698af3a-6998-11eb-297b-8176c30e0da8
# ╠═03658032-6998-11eb-0225-bfbce55888f5
# ╟─0da7f61a-6998-11eb-1381-ff73d8bf8d9f
# ╠═67cf2bc2-6998-11eb-1c9f-f9b0bde636fe
# ╟─882be004-6998-11eb-058c-61714e97aa01
# ╠═91347c6a-6998-11eb-3de5-fff4ccaaca50
# ╟─c78e9cb0-6997-11eb-23fa-9f1936729792
# ╟─acafb36a-6998-11eb-3081-f9c9868f502d
# ╠═bc0badd2-6998-11eb-3c7f-71441b60348b
# ╟─c0d3f3a6-6998-11eb-1f6f-bf3d9f53c907
# ╠═d077547e-6998-11eb-2d7f-5be66624cbb2
# ╟─da11ef28-6998-11eb-38b9-c32091494df2
# ╠═e87fcae2-6998-11eb-33bd-19d5fc7c0ab3
# ╟─f1188e62-6998-11eb-0be9-d90fc94b3bf2
# ╟─05fc8600-6999-11eb-3edc-43b7a149d975
# ╠═17613e36-6999-11eb-0aa5-57b2d7d2ce0c
# ╟─222001f4-6999-11eb-33ca-83ec4484a65b
# ╠═45212f3e-6999-11eb-2b9c-dd5199e5f42a
# ╟─4b74f596-6999-11eb-1bd2-1d6fce0f49b9
# ╠═4fb34158-6999-11eb-214b-dd4ae90bb907
# ╟─57325360-6999-11eb-37a0-fd1ba4b66d6f
# ╠═6606538c-6999-11eb-1490-83a7727526d0
