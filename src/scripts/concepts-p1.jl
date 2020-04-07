#' ---
#' title: Introduction to Time Series I
#' author: Edwin Bedolla
#' date: 4th April 2020
#' ---
#' 
#' This document gathers some main concepts in time series analysis as well as some examples written
#' for the [Julia programming language](https://julialang.org).
#' 
#' 
#' First, we import every module that will be used in this document.
#' 
#' 
#' 
#+ results = "hidden"

using Plots
using Random
using TimeSeries
using Dates
using Statistics: mean

pyplot()

#' 
#' 
#' 
#' 
#' 
#' 
#' ## Definitions
#' > - A **time series** is a collection of **random variables** indexed in a *ordered set* representing time periods.
#' 
#' > - **Stochastic processes** are a family of _indexed_ random variables $Z(\omega, t)$
#' >   where $\omega$ belongs to a **sample space** and $t$ belongs to an **index set**.
#' 
#' > - For a given $\omega$, $Z(\omega, t)$ as a function of $t$ is called a sample function or **realisation**.
#' 
#' > - The population that consists of all possible realisations is called the **ensemble**.
#' 
#' From these definitions we can see that a *time series* is actually a *stochastic process*.
#' We will now turn to see some simple examples of time series and how to program them in `Julia`.
#' 
#' ## Examples
#' 
#' 
#' 1. **White noise**
#' 
#' 
#' One of the basic time series is **white noise**, which is a time series
#' generated from uncorrelated variables, which are most of the time *normally distributed*.
#' 
#' 
#' 
#+ 

# Create a range of time for a year, spaced evenly every 10 hours
dates = DateTime(2018, 1, 1, 1):Dates.Hour(10):DateTime(2018, 12, 31, 24)
# Build a TimeSeries object with the specified time range and white noise
ts = TimeArray(dates, randn(length(dates)))

# And plot it
plot(ts, leg = false)

#' 
#' 
#' 
#' 
#' 
#' 
#' This collection of random variables $\{x_t\}$ has the following properties:
#' 
#' 
#' $\mu_x = 0$
#' 
#' 
#' $\sigma^2_x = 1$
#' 
#' 
#' - They are *independently and identically distributed* such that
#' 
#' 
#' $x_t \sim i.i.d. \mathcal{N}(0, 1)$
#' 
#' 
#' We can see that this time series is very *noisy*, with big peaks all over the place;
#' if we wanted to do some meaningful analysis on it we might have a difficult time.
#' Instead we can apply a very simple **smoothing** technique named the **moving average**.
#' 
#' 
#' 2. **Moving average**
#' 
#' 
#' The **moving average** is an actual time series in itself defined as
#' 
#' 
#' $$
#' v_t = \frac{1}{N} \sum_{i=0}^{N-1} w_{t-i}
#' $$
#' 
#' 
#' this means that the *moving average* takes as input the neighboring values in the past
#' and future time periods and evaluates them, obtaining the **realization** as an arithmetic
#' mean. The following example applies a moving average to a white noise time series.
#' 
#' 
#' 
#+ 

# Create a range of time for a year, spaced evenly every 50 hours
dates = DateTime(2018, 1, 1, 1):Dates.Hour(50):DateTime(2018, 12, 31, 24)
# Build a TimeSeries object with the specified time range and white noise
ts = TimeArray(dates, randn(length(dates)))

# Moving average using 3 values
moving_average = moving(mean, ts, 3)

# And plot both of them superimposed
plot(ts, label = "White noise")
plot!(moving_average, label = "Moving average")

#' 
#' 
#' 
#' 
#' 
#' 
#' In this case we used the following 3-valued moving average
#' 
#' 
#' $$
#' v_t = \frac{1}{3} \left( w_{t-1} + w_{t} + w_{t+1} \right)
#' $$
#' 
#' 
#' We can see that most of the peaks are gone, but we can still observe the main structure
#' of the original time series.
#' 
#' 
#' 3. **Random walks with drift**
#' 
#' 
#' The analysis of *trends* is one of the prime examples of time series, where there is
#' a need to explore and understand what has been happening throughout several time periods.
#' For example, one might need to understand how the global temperature has been rising
#' since 1997 until today.
#' 
#' To model this type of time series we have the following
#' 
#' $$
#' x_t = \delta t + \sum_{j=1}^{t} w_j
#' $$
#' 
#' where, as before, $w_j$ is a white noise time series, with $\sigma_w = 1$;
#' $\delta$ is the so-called *drift* coefficient that makes the trend in the time
#' series much more steep. In the special case that we have $\delta = 0$ we would
#' have what's called a simple *random walk*.
#' 
#' We can see an example of a random walk *with drift* and *without drift* below.
#' 
#' 
#' 
#+ 

# Create a range of time for a year, spaced evenly every 50 hours
dates = DateTime(2018, 1, 1, 1):Dates.Hour(50):DateTime(2018, 12, 31, 24)
# Build a TimeSeries object with the specified time range and white noise
wt = randn(length(dates))
# Define a drift value
δ = 0.2
# We then build the random walk with drift
ts_drift = TimeArray(dates, cumsum(wt .+ δ))
# And without drift
ts_nodrift = TimeArray(dates, cumsum(wt))

# And plot both of them superimposed
plot(ts_drift, label = "Random walk with drift")
plot!(ts_nodrift, label = "Random walk without drift")

#' 
#' 
#' 
#' 
#' Here we see a *trend* in the time series because every time period in the future
#' the *realization* is always higher than in past values.We might expect that this
#' time series is always growing. We will see that *trends* are very useful to perform
#' some basic exploratory analysis on the data itself in further documents.
#' 
#' 
#+ 

