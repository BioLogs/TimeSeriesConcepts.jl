#' ---
#' title: Introduction to Time Series III
#' author: Edwin Bedolla
#' date: May 6th, 2020
#' ---
#' 
#' This document closes the introduction to Time Series by exploring the last concepts which
#' are the *estimation* of the **autocovariance** and **autocorrelation** functions, with a
#' simple example.
#' 
#' As always, we import the needed packages.
#' 
#' 
#+ results = "hidden"

using StatsPlots
using Random
using TimeSeries
using Dates
using Statistics
using DataFrames
using Test

gr()

# Ensure reproducibility of the results
rng = MersenneTwister(5489)

#' 
#' 
#' 
#' 
#' # Estimation of correlation
#' 
#' In the last part we studied the **theoretical** definitions of the autocorrelation (ACF) 
#' and autocovariance functions (AVF), were we did some extensive examples on how to compute the 
#' theoretical values.
#' 
#' But in reality we only have *sampled data* and we usually just have a subset or 
#' *sample* of the original *population.* When that is the case, we can only estimate
#' the respective statistics by using **estimated** methods. In this document we will
#' explore the definitions and algorithms to estimate the autocorrelation and
#' autocovariance functions, we close the document exploring the **lag operator** and the
#' importance of it.
#' 
#' We start with a simple example.
#' 
#' 
#+ results = "hidden"

# Create a range of time for a year, spaced evenly every 1 minute
dates = DateTime(2018, 1, 1, 1):Dates.Minute(1):DateTime(2018, 12, 31, 24)
# Create a white noise array
xt = randn(rng, length(dates))

#' 
#' 
#' 
#' 
#' ## Autoregressive time series
#' 
#' In this we will build an **autoregressive time series**; this is a big topic within
#' Time Series analysis so we will have a special chapter for that, but here we want
#' to introduce the concept.
#' 
#' An autoregressive time series takes information from past intervals to build
#' future information. We will build an autoregressive time series now and plot it.
#' 
#' 
#+ 

# This is the autoregressive time series
ar = 5.0 .+ xt[1:(end-1)] .- 0.7 * xt[2:end]
# Note that we need to remove the last element from the dates
df_ar = TimeArray(dates[1:(end-1)], ar) |> DataFrame
# We can now plot the time series, only 100 elements though
@df df_ar plot(:timestamp[1:200], :A[1:200])

#' 
#' 
#' 
#' 
#' As we can see, this time series is not really different from the ones that we
#' have studied so far, but one of the fundamental properties of the autoregressive
#' model or time series is that is shows **periodicity**; we will explore all of this
#' later.
#' 
#' ## Correlation of an autoregressive time series
#' 
#' As we said before, we are concerned with estimating the ACF and AVF of a time
#' series when we only have sampled data at hand. In the case of the autoregressive
#' time series we are studying, I have obtained the true value of the AVF, $\gamma$
#' which is the following.
#' 
#' 
#+ 

true_γ = 1.49

#' 
#' 
#' 
#' 
#' We compare it to the `Julia`'s built-in function to comput the covariance
#' value of the time series.
#' 
#' 
#+ 

cov(df_ar[:, :A], df_ar[:, :A])

#' 
#' 
#' 
#' 
#' ### Autocovariance function
#' 
#' We now turn our attention to defining the estimated, *unbiased* AVF, which
#' is defined as follows
#' 
#' $$
#' \hat{\gamma}(h)=\frac{1}{n} \sum_{t=1}^{n-h} (x_{t+h}-\bar{x}) (x_{t}-\bar{x})
#' $$
#' 
#' where the **sample mean**, $\bar{x}$, is estimated as
#' 
#' $$
#' \bar{x}=\frac{1}{N} \sum_{i}^N x_i
#' $$
#' 
#' We will now implement the estimated AVF in `Julia`.
#' 
#' 
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

#' 
#' 
#' 
#' 
#' Let us now use this new function and compute the estimated AVF.
#' 
#' 
#+ 

γ_hand = avf(df_ar[:, :A], 0)

#' 
#' 
#' 
#' 
#' We can see that the results are very similar to those obtained with 
#' the built-in `cov`, and very close to the true theoretical value. We will obtain
#' the true theoretical value with increasing samples from the time series.
#' 
#' ### Autocorrelation function
#' 
#' A similar estimator for the ACF can be used, and in particular we have
#' 
#' $$
#' \hat{\rho}(h)=\frac{\hat{\gamma}(h)}{\hat{\gamma}(0)}=\frac{\sum_{t=1}^{N-h} (x_{t+h}-\bar{x}) (x_{t}-\bar{x})}{\sum_{t=1}^{N} (x_{t}-\bar{x})^2}
#' $$
#' 
#' so we can use this to our advantage and employ the AVF to compute the ACF.
#' 
#' In our implementation we exploit this property bellow.
#' 
#' 
#+ results = "hidden"

function acf(x::AbstractArray, h::Integer)
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

#' 
#' 
#' 
#' 
#' We now compute the estimated ACF. Notice that we need to specify the value of
#' $h=1$ which adds a *lag* to the time series.
#' 
#' 
#+ 

ρ_hand = acf(df_ar[:, :A], 1)

#' 
#' 
#' 
#' 
#' We now compare it to the one obtained by the Pearson correlation function with
#' the built-in `cor` function in `Julia`.
#' 
#' 
#+ 

ρ_jl = cor(df_ar[1:(end - 1), :A], df_ar[2:end, :A])

#' 
#' 
#' 
#' 
#' The results are quite similar, just what we expected.
#' 
#' # Lag in Time Series
#' 
#' Up until now we have mentioned several times the word **lag** in different scenarios.
#' It is now time to address the meaning of this word in the context of Time Series.
#' Time Series are a process in different time intervals, and we are sometimes interested
#' in what happens between two time intervals $s$ and $t$ within the same Time Series.
#' 
#' A special type of operation, called the **lag operator** produces the value of a previous
#' time interval with respect to the current time interval. The lag operator is denoted by
#' $L$ and when applied to a Time Series $X=\{x_1,x_2,x_3,\dots\}$ we get the following
#' 
#' $$
#' Lx_k = x_{k-1}
#' $$
#' 
#' When doing something like this `df_ar[1:(end-1), :A]` we are essentially applying the lag
#' operator by hand, were the lag is one in this case. The `TimeSeries` package has support for this. Let us do a simple example computing the ACF like before.
#' 
#' 
#+ 

# We need to use a TimeArray in order to apply the lag operator
ts = TimeArray(dates[1:(end-1)], ar)
# We use lag to put the past value in the current value of the time series
ts_lag = lag(ts) |> DataFrame
# Convert to DataFrame for easier handling
df_ts = DataFrame(ts)
# Compute the ACF, note that instead of using indexing we just use the
# lagged time series first
lag_value = cor(ts_lag[:, :A], df_ts[2:end, :A])
# And it should be the same as before
@test lag_value == ρ_jl

#' 
#' 
#' We can go back to an arbitrary time interval if we *raise* the lag operator to a given 
#' *power*, like so
#' 
#' $$
#' L^n x_k = x_{k-n}
#' $$
#' 
#' for example $L^2 x_k = x_{x-2}$ so we actually got the previous-to-last value from the time
#' series.
#' 
#' Furthermore, because the lag operator can be raised to arbitrary powers we can build
#' **polynomials** out of the lag operator, like so
#' 
#' $$
#' a(L) = a_0 + a_1 L + a_2 L^2 + \cdots \\
#' a(L)x_t = a_0 x_t + a_1 x_{t-1} + a_2 x_{t-2} + a_3 x_{t-3} \cdots
#' $$
#' 
#' which resembles an autoregressive time series. In fact it is the use in autoregressive 
#' models and moving averages where the lag operator is of the utmost importance.
#' 
#' For example, in this document we used the autoregressive model
#' $y_t = 5+x_t-0.7x_{t-1}$ which could be written in terms of the lag operator as
#' $y_t = 5+x_t-0.7Lx_t = 5+x_t(1-0.7L)$. We will come back to this when we study the
#' [ARIMA processes](https://en.wikipedia.org/wiki/Autoregressive_integrated_moving_average) later on.
#' 