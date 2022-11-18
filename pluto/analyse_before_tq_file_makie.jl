### A Pluto.jl notebook ###
# v0.19.11

using Markdown
using InteractiveUtils

# ╔═╡ 9a211d3c-bfcf-4b21-af66-27700f453856
using GLMakie

# ╔═╡ 356c1374-2ce1-44e7-a04f-8d29dfedb64a
using EQDSKReader

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
	using Pkg
	Pkg.activate(HERE)
	Pkg.add(path=ROOT)
end

# ╔═╡ 76c71444-c280-4c59-a65b-7f8b0623068c
GLMakie.activate!()

# ╔═╡ 96716227-0cfd-47c3-82de-bb98b3042a1e
begin
	const DATA_DIR = joinpath(ROOT, "test", "data")
	const DATA_FILE = joinpath(DATA_DIR, "beforeTQ.eqdsk")
	@assert isdir(DATA_DIR)
	@assert isfile(DATA_FILE)
end

# ╔═╡ eb21a90d-5bc7-4558-9ebd-69ad6decffee
content = Content(DATA_FILE)

# ╔═╡ c11ee525-3423-4958-8063-0346d6d6fa53
begin
	r = rpoints(content)
	z = zpoints(content)
	nothing
end

# ╔═╡ 5f8ce35c-a55f-4067-a4e1-e93da32dbc57
let
	f = Figure(resolution=(500, 800))
	ax = Axis(
		f[1,1]; xlabel=L"R,m", ylabel=L"Z,m", aspect=DataAspect(), 
		title="Raw Ψ"
	)
	xlims!(ax, r[1], r[end])
	ylims!(ax, z[1], z[end])
	# colsize!(f.layout, 1, Aspect(1, aspect))
	Ψ_min, Ψ_max = extrema(content.psirz)
	levels=range(Ψ_min, Ψ_max, length=20)
	cntr = contourf!(
		r, z, content.psirz, levels=levels, colormap=:greens, linestyle="-",
	)
	rbbs_points = [Point2f(x,y) for (x,y) in zip(content.rbbbs, content.zbbbs)]
	rlim_points = [Point2f(x,y) for (x,y) in zip(content.rlim, content.zlim)]
	scatter!(ax, content.rmaxis, content.zmaxis, color=:gray60, marker=:xcross, label="Magnetic axis")
	lines!(ax, rbbs_points, label="Plasma boundary")
	lines!(ax, rlim_points, label="Limiter")
	# plot(;aspect_ratio=:equal, xlabel="R,m", ylabel="Z,m", xlim=(0.0,3.0), ylim=(-2.0, 2.0))
	# plot!(content.rbbbs, content.zbbbs, label="plasma boundary")
	# plot!(content.rlim, content.zlim, label="limiter")
	# resize_to_layout!(f)
	Colorbar(f[1,2], cntr, label=L"Ψ(R,Z)")
	axislegend()
	f
end

# ╔═╡ 41de7097-5739-4242-ab10-6b38b9b12b6c
function normalize_psi(ψ)
	ψ_min, _ = extrema(ψ)
	(ψ .- ψ_min) / -ψ_min
end

# ╔═╡ e423a56d-62d7-4d77-bb62-a8add3b270cb
extrema(normalize_psi(content.psirz))

# ╔═╡ 737c8b5f-c9ba-4ca2-affb-823738fd7961
function select_rz(Ψ, value)
	
end

# ╔═╡ 1f5b822d-1c7e-4093-9bd3-48d5b88267f0


# ╔═╡ 044231f1-efd6-4d98-9c77-3e97723fa574
let
	f = Figure(resolution=(500, 800))
	ax = Axis(
		f[1,1]; 
		xlabel=L"R,m", 
		ylabel=L"Z,m", 
		aspect=DataAspect(),
		title="Normalized Ψ"
	)
	xlims!(ax, r[1], r[end])
	ylims!(ax, z[1], z[end])
	# colsize!(f.layout, 1, Aspect(1, aspect))
	ψ = normalize_psi(content.psirz)
	Ψ_min, Ψ_max = extrema(ψ)
	# Ψ_min, Ψ_max = 0, 1
	levels=range(Ψ_min, Ψ_max, length=15)
	cntr = contourf!(ax,
		r, z, ψ, 
		levels=levels, 
		colormap=:greens, 
		linestyle="-",
		linecolor=:black,
		linewidth=2
	)
	cntr1 = contour!(ax,
		r, z, ψ, 
		levels=[1.0], 
		colormap=:reds, 
		linestyle="-",
		linewidth=1,
	)
	rbbs_points = [Point2f(x,y) for (x,y) in zip(content.rbbbs, content.zbbbs)]
	rlim_points = [Point2f(x,y) for (x,y) in zip(content.rlim, content.zlim)]
	scatter!(ax, content.rmaxis, content.zmaxis, color=:gray60, marker=:xcross, label="Magnetic axis")
	lines!(ax, rbbs_points, label="Plasma boundary")
	lines!(ax, rlim_points, label="Limiter")
	# plot(;aspect_ratio=:equal, xlabel="R,m", ylabel="Z,m", xlim=(0.0,3.0), ylim=(-2.0, 2.0))
	# plot!(content.rbbbs, content.zbbbs, label="plasma boundary")
	# plot!(content.rlim, content.zlim, label="limiter")
	# resize_to_layout!(f)
	Colorbar(f[1,2], cntr, label=L"Ψ(R,Z)")
	axislegend()
	f
end

# ╔═╡ Cell order:
# ╟─c9a17fb4-3802-11ed-325c-8b2be110f038
# ╠═b4318e67-2e90-4592-835f-e47fa872852f
# ╠═77f942e2-9316-4df7-bdea-da6819761189
# ╠═9a211d3c-bfcf-4b21-af66-27700f453856
# ╠═76c71444-c280-4c59-a65b-7f8b0623068c
# ╠═356c1374-2ce1-44e7-a04f-8d29dfedb64a
# ╠═96716227-0cfd-47c3-82de-bb98b3042a1e
# ╠═eb21a90d-5bc7-4558-9ebd-69ad6decffee
# ╠═c11ee525-3423-4958-8063-0346d6d6fa53
# ╠═5f8ce35c-a55f-4067-a4e1-e93da32dbc57
# ╠═41de7097-5739-4242-ab10-6b38b9b12b6c
# ╠═e423a56d-62d7-4d77-bb62-a8add3b270cb
# ╠═737c8b5f-c9ba-4ca2-affb-823738fd7961
# ╠═1f5b822d-1c7e-4093-9bd3-48d5b88267f0
# ╠═044231f1-efd6-4d98-9c77-3e97723fa574
