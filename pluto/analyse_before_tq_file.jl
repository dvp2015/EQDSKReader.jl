### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ ef6b6742-c4d8-4c30-b00d-8d24a436a92d

using Pkg

# ╔═╡ 356c1374-2ce1-44e7-a04f-8d29dfedb64a
using EQDSKReader

# ╔═╡ 1e121b3e-35b1-4619-97a2-1b692fe8d891
using Plots


# ╔═╡ c9a17fb4-3802-11ed-325c-8b2be110f038
md"""
# Analysing EQDSK file structure.
"""

# ╔═╡ b4318e67-2e90-4592-835f-e47fa872852f
begin
	const HERE = dirname(@__FILE__)
	const ROOT = dirname(HERE)
end

# ╔═╡ 77f942e2-9316-4df7-bdea-da6819761189
begin
	Pkg.activate(HERE)
	Pkg.add(path=ROOT)
	Pkg.add(["Plots","PlotlyBase","PlotlyKaleido"])
end


# ╔═╡ 96716227-0cfd-47c3-82de-bb98b3042a1e
begin
	const DATA_DIR = joinpath(ROOT, "test", "data")
	const DATA_FILE = joinpath(DATA_DIR, "beforeTQ.eqdsk")
	@assert isdir(DATA_DIR)
	@assert isfile(DATA_FILE)
end

# ╔═╡ eb21a90d-5bc7-4558-9ebd-69ad6decffee
content = Content(DATA_FILE)

# ╔═╡ 351a7930-ee95-4ab5-ad2c-5d1547acc3e2
plotly()

# ╔═╡ 8972493a-8b7c-4361-9744-0c1689f452c6
begin
	r = range(content.rleft, content.rleft + content.rdim, length=content.nw)
	z = range(
		content.zmid - 0.5*content.zdim, content.zmid + 0.5*content.zdim, length=content.nh
	)
end

# ╔═╡ 5f8ce35c-a55f-4067-a4e1-e93da32dbc57
begin
	plot(;
		aspect_ratio=:equal, 
		xlabel="R,m", 
		ylabel="Z,m", 
		xlim=(r[1], r[end]), 
		ylim=(z[1], z[end]), 
		size=(500, 700)
	)
	contourf!(r, z, transpose(content.psirz), )
	plot!(content.rbbbs, content.zbbbs, label="plasma boundary")
	plot!(content.rlim, content.zlim, label="limiter")
	scatter!(
		[content.rmaxis], 
		[content.zmaxis], 
		label="Magnetic axis",
		markershape=:xcross,
		markerstrokecolor=:auto
	)
end

# ╔═╡ 41de7097-5739-4242-ab10-6b38b9b12b6c
plotattr(:Plot)

# ╔═╡ e64d41b9-bbb4-4cfa-b880-bbc603e2e9a9
plotattr("size")

# ╔═╡ Cell order:
# ╟─c9a17fb4-3802-11ed-325c-8b2be110f038
# ╠═b4318e67-2e90-4592-835f-e47fa872852f
# ╠═ef6b6742-c4d8-4c30-b00d-8d24a436a92d
# ╠═77f942e2-9316-4df7-bdea-da6819761189
# ╠═356c1374-2ce1-44e7-a04f-8d29dfedb64a
# ╠═96716227-0cfd-47c3-82de-bb98b3042a1e
# ╠═eb21a90d-5bc7-4558-9ebd-69ad6decffee
# ╠═1e121b3e-35b1-4619-97a2-1b692fe8d891
# ╠═351a7930-ee95-4ab5-ad2c-5d1547acc3e2
# ╠═8972493a-8b7c-4361-9744-0c1689f452c6
# ╠═5f8ce35c-a55f-4067-a4e1-e93da32dbc57
# ╠═41de7097-5739-4242-ab10-6b38b9b12b6c
# ╠═e64d41b9-bbb4-4cfa-b880-bbc603e2e9a9
