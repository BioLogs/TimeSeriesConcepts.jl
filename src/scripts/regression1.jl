### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 4b5b292a-699e-11eb-0b9f-7daa58c4eeba
begin
	using DataFrames
	using TimeSeries
	using Dates
	using StatsPlots
end

# ╔═╡ 8ab35a9c-69a6-11eb-2112-1733984fe260
md"""
TODO: pp 50 from the book
Try working with the RData format instead.
"""

# ╔═╡ b92c9ec8-699f-11eb-2416-dd71aa4bf2d9
gr();

# ╔═╡ 574c6094-69a2-11eb-35d9-df19dc196d0d
full_df = DataFrame();

# ╔═╡ ae93f34e-69a2-11eb-216d-53292bcbd85a
# files = Dict("cmort" => "cmort.dat",
# 	"temp" => "temp.dat",
# 	"part" => "particle.dat"
# );

# ╔═╡ 07e736d8-69a6-11eb-09c5-ab3114753f2b
files = Dict(:cmort => "cmort.dat");

# ╔═╡ 653a7668-699e-11eb-022e-d79092879b0c
function read_files_to_df!(df, k, v)
	base_path = "../data"
	open(joinpath(base_path, v), "r") do io
		df.k = read(io)
	end
end;

# ╔═╡ e313c112-69a2-11eb-1a37-b9695c591827
read_files_to_df!(full_df, "cmort", get(files, :cmort, 1))

# ╔═╡ 552adfe4-69a6-11eb-1d17-4dcde0b9ffe2
first(full_df, 3)

# ╔═╡ 71961502-699e-11eb-3626-d504ba310af6
dates = Date(1970, 1, 1):Day(7):Date(1979, 10);

# ╔═╡ af740eb0-699e-11eb-2ef7-f5785d24db12
cmort_ar = TimeArray(dates[1:end-1], cmort[!, :cmort], [:cmort]);

# ╔═╡ e3071582-699f-11eb-1657-792d26702790
df_cmort = DataFrame(cmort_ar);

# ╔═╡ 26f05f74-69a0-11eb-32f7-97e305b6aba1
@df df_cmort plot(:timestamp, :cmort, leg=false)

# ╔═╡ 3727b36c-69a0-11eb-15e2-237d37b7be34


# ╔═╡ 679228c0-699e-11eb-1095-0f981944a5f1


# ╔═╡ 677c9046-699e-11eb-20b9-e37da734c1a3


# ╔═╡ 6763604e-699e-11eb-1f20-b716b1e3a4d1


# ╔═╡ 6749ae56-699e-11eb-06c1-5f35812d1b06


# ╔═╡ 672ef066-699e-11eb-3ab5-b972365504fe


# ╔═╡ 6715ed6e-699e-11eb-365e-cb335f1e8a73


# ╔═╡ 66fb044a-699e-11eb-300d-fd661918f5bd


# ╔═╡ 66e4225c-699e-11eb-132f-47a9bd831a87


# ╔═╡ 66ca2744-699e-11eb-2412-fb201a7c3e98


# ╔═╡ 66ae1838-699e-11eb-14db-c9fe4e1b5b45


# ╔═╡ 66969334-699e-11eb-05f9-498acac4c604


# ╔═╡ 66772d0a-699e-11eb-1a76-ed5e301953dd


# ╔═╡ 6657f7fa-699e-11eb-1992-8521c50bd37b


# ╔═╡ Cell order:
# ╠═8ab35a9c-69a6-11eb-2112-1733984fe260
# ╠═4b5b292a-699e-11eb-0b9f-7daa58c4eeba
# ╠═b92c9ec8-699f-11eb-2416-dd71aa4bf2d9
# ╠═574c6094-69a2-11eb-35d9-df19dc196d0d
# ╠═ae93f34e-69a2-11eb-216d-53292bcbd85a
# ╠═07e736d8-69a6-11eb-09c5-ab3114753f2b
# ╠═653a7668-699e-11eb-022e-d79092879b0c
# ╠═e313c112-69a2-11eb-1a37-b9695c591827
# ╠═552adfe4-69a6-11eb-1d17-4dcde0b9ffe2
# ╠═71961502-699e-11eb-3626-d504ba310af6
# ╠═af740eb0-699e-11eb-2ef7-f5785d24db12
# ╠═e3071582-699f-11eb-1657-792d26702790
# ╠═26f05f74-69a0-11eb-32f7-97e305b6aba1
# ╠═3727b36c-69a0-11eb-15e2-237d37b7be34
# ╠═679228c0-699e-11eb-1095-0f981944a5f1
# ╠═677c9046-699e-11eb-20b9-e37da734c1a3
# ╠═6763604e-699e-11eb-1f20-b716b1e3a4d1
# ╠═6749ae56-699e-11eb-06c1-5f35812d1b06
# ╠═672ef066-699e-11eb-3ab5-b972365504fe
# ╠═6715ed6e-699e-11eb-365e-cb335f1e8a73
# ╠═66fb044a-699e-11eb-300d-fd661918f5bd
# ╠═66e4225c-699e-11eb-132f-47a9bd831a87
# ╠═66ca2744-699e-11eb-2412-fb201a7c3e98
# ╠═66ae1838-699e-11eb-14db-c9fe4e1b5b45
# ╠═66969334-699e-11eb-05f9-498acac4c604
# ╠═66772d0a-699e-11eb-1a76-ed5e301953dd
# ╠═6657f7fa-699e-11eb-1992-8521c50bd37b
