#' ---
#' title: Introduction to Time Series II
#' author: Edwin Bedolla
#' date: 6th April 2020
#' ---
#' 
#' In this document, the main statistics such as the **mean function**, **autocovariance function**
#' and **autocorrelation function** will be described, along with some examples.
#' 
#' We will import all of the necessary modules first.
#' 
#+ results = "hidden"

using StatsPlots
using Random
using TimeSeries
using Dates
using Statistics
using DataFrames

pyplot()

# Ensure reproducibility of the results
rng = MersenneTwister(8092)

#' 
#' 
#' ## Descriptive statistics and measures
#' 
#' A full description of a given time series is always given by the **joint distribution function**
#' of the time series which is a multi-dimensional function that is very difficult to track for
#' most of the time series that are dealt with.
#' 
#' Instead, we usually work with what's known as the **marginal distribution function** defined as
#' 
#' $$
#' F_t(x) = P \{ x_t \leq x \}
#' $$
#' 
#' where $P \{ x_t \leq x \}$ is the probability that the *realization* of the time series $x_t$
#' at time $t$ is less or equal that the value of $x$.
#' Even more common is to use a related function known as the **marginal density function**
#' 
#' $$
#' f_t(x) = \frac{\partial F_t(x)}{\partial x}
#' $$
#' 
#' and when both functions exist they can provide all the information needed to do meaningful
#' analysis of the time series.
#' 
#' ### Mean function
#' With these functions we can now define one of the most important descriptive measures,
#' the **mean function** which is defined as
#' 
#' $$
#' \mu_{xt} = E(x_t) = \int_{-\infty}^{\infty} x f_t(x) dx
#' $$
#' 
#' where $E$ is the *expected value operator* found in classical statistics.
#' 
#' ### Autocovariance and autocorrelation
#' We are also interested in analyzing the dependence or lack of between realization values in different
#' time periods, i.e. $x_t$ and $x_s$; in that case we can use classical statistics to define two very
#' important and fundamental quantities.
#' 
#' The first one is known as the **autocovariance function** and it's defined as
#' 
#' $$
#' \gamma_{x} (s, t) = \text{cov}(x_s,x_t) = E[(x_s - \mu_s)(x_t - \mu_t)]
#' $$
#' 
#' where $\text{cov}$ is the [covariance](https://en.wikipedia.org/wiki/Covariance) as defined in
#' classical statistics. A simple way of defining the *autocovariance* is the following
#' 
#' 
#' > The **autocovariance** tells us about the *linear* dependence between two points on the same
#' > time series observed at different times.
#' 
#' 
#' Normally, we know from classical statistics that if for a given time series $x_t$ we should have
#' $\gamma_{x} (s, t) = 0$ then it means that there is no linear dependence between $x_t$ and
#' $x_s$ at time periods $t$ and $s$; but this does not mean that there is **no** relation between them
#' at all. For that, we need another measure that we describe below.
#' 
#' We now introduce the **autocorrelation function** (ACF) and it's defined as
#' 
#' $$
#' \rho(s,t) = \frac{\gamma_{x} (s, t)}{\sqrt{\gamma_{x} (s, s) \gamma_{x} (t, t)}}
#' $$
#' 
#' which is a measure of **predictability** and we can define it in words as follows
#' 
#' > The **autocorrelation** measures the *linear predictability* of a given time series $x_t$ at
#' > time $t$, using values from the same time series but at time $s$.
#' 
#' This measure is very much related to [Pearson's correlation coefficient](https://en.wikipedia.org/wiki/Pearson_correlation_coefficient)
#' from classical statistics, which is a way to measure the relationship between values.
#' The range of values for the ACF is $-1 \leq \rho(s,t) \leq 1$; when $\rho(s,t) = 1$
#' it means that a *linear model* can perfectly describe the realization of the time series at time $t$
#' provided with the realization at time $s$, e.g. a trend goind upwards, on the other hand,
#' if $\rho(s,t) = -1$ would mean that the realization of the time series $x_t$ decrease while the realization
#' $x_s$ is increasing.
#' 
#' 
#+ 

# Create a range of time for a year, spaced evenly every 60 hours
dates = DateTime(2018, 1, 1, 1):Dates.Minute(1):DateTime(2018, 12, 31, 24)
# Build a TimeSeries object with the specified time range and white noise
ts = TimeArray(dates, randn(rng, length(dates)))
df_ts = DataFrame(ts)
first(df_ts)


#+ 

moving_average = moving(mean, ts, 3)
# Create a DataFrame with it
df_average = DataFrame(moving_average)
first(df_average)

#' 
#' 
#' Recall what these look like.
#' 
#+ 

@df df_ts plot(:timestamp[1:100], :A[1:100], label = "White noise")
@df df_average plot!(:timestamp[1:100], :A[1:100], label = "Moving average")


#+ 

true_γ = 1 / 9


#+ 

#γ_jl = cov(df[1:(end - 2), :A], df[3:end, :A])


#+ 

true_ρ = 1 / 3
#ρ_jl = cor(df[1:(end - 2), :A], df[3:end, :A])

