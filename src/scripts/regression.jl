using RData
using DataFrames
using TimeSeries
using Dates

cmort = RData.load(joinpath("data", "cmort.rda")) |> DataFrame
size_cmort = length(cmort[:, :cmort])
println(size_cmort)
println(cmort)

dates = Date(1970, 1, 1):Day(7):Date(1979, 10)
println(length(dates))
