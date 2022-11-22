### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# ╔═╡ ea134bdf-17ec-4280-933d-b7b2f4c323bf
# ╠═╡ show_logs = false
# See Pluto 
# https://github.com/fonsp/Pluto.jl/wiki/%F0%9F%8E%81-Package-management#pattern-the-shared-environment
begin
 	using Pkg
 	Pkg.activate(temp=true)
	Pkg.add([
		"GLMakie",
		"Interpolations",
	])
	# Use version controlled variant below if the above stops working
	# (working versions are fixed in this comment)
	# Pkg.add(
	# 	Pkg.PackageSpec(name="GLMakie", version="0.7.3"),
	#   "Interpolations",0.14.6
	# )
end

# ╔═╡ 9a211d3c-bfcf-4b21-af66-27700f453856
using GLMakie

# ╔═╡ 0ecaec62-3802-4f91-90ce-3d8680fec694
using EQDSKReader

# ╔═╡ 6b9e7928-7aa9-4284-aee2-a37568151f86
using Interpolations

# ╔═╡ c9a17fb4-3802-11ed-325c-8b2be110f038
md"""
# Analysing EQDSK file structure.
"""

# ╔═╡ b4318e67-2e90-4592-835f-e47fa872852f
begin
	const HERE = @__DIR__
	const ROOT = dirname(HERE)
end

# ╔═╡ af1f348e-5cc6-4310-979c-4d5ef89e8a41
# ╠═╡ show_logs = false
Pkg.develop(path=ROOT)

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
# function normalize_psi(ψ)
# 	ψ_min, _ = extrema(ψ)
# 	(ψ .- ψ_min) / -0.746ψ_min
# end

# ╔═╡ e423a56d-62d7-4d77-bb62-a8add3b270cb
extrema(normalize_psi(content.psirz))

# ╔═╡ 1f5b822d-1c7e-4093-9bd3-48d5b88267f0
XR, XZ = lowest_boundary_point(content)

# ╔═╡ 836a4883-89df-4953-b064-2a951705b389


# ╔═╡ 3450d86e-ec15-4504-b049-f3500509c62a
interpolated_psi = scale(
	interpolate(
		map(Float64, content.psirz), 
		BSpline(Quadratic(Line(OnGrid())))  # the best
	), 
	r, 
	z
)

# ╔═╡ 04b21833-1c88-4732-9cc5-61ecf45986b4
begin
	f = Figure(resolution=(500, 800))
	ax = Axis(
		f[1,1],
		xlabel=L"R,m", 
		ylabel=L"Z,m", 
		aspect=DataAspect(),
		title="Interpretation variance"
	)
	diffs = abs.([ 
		interpolated_psi(r[i[1]], z[i[2]]) - content.psirz[i]
		for i in CartesianIndices(content.psirz)
	])
	cf = contourf!(ax, r, z, diffs, colormap=:blues, )
	Colorbar(f[1,2], cf, label=L"δΨ(R,Z)")
	f
end

# ╔═╡ 41a26108-6bf1-4ce6-9891-91c1cb1b6855


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
		color=:yellow,
		alpha=0.25,
		# colormap=:grays, 
		linewidth=2,
	)
	rbbs_points = [Point2f(x,y) for (x,y) in zip(content.rbbbs, content.zbbbs)]
	rlim_points = [Point2f(x,y) for (x,y) in zip(content.rlim, content.zlim)]
	scatter!(ax, content.rmaxis, content.zmaxis, color=:gray60, marker=:cross, label="Magnetic axis")
	scatter!(ax, XR, XZ, color=:gray90, marker=:diamond, label="boundary bottom")
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

# ╔═╡ da4a3fc2-9a75-4009-b5dc-b52ba84c3dd0
Base.current_project()

# ╔═╡ 8ec24276-a712-4942-9281-fe992f17fc62
a = [
 1 2
 3 4
]

# ╔═╡ 984bcd02-07b4-4d7b-a383-fba9d29179df
map(Float64, a)

# ╔═╡ e8201ac3-ad14-45f6-8a81-3cc8634a8242


# ╔═╡ Cell order:
# ╟─c9a17fb4-3802-11ed-325c-8b2be110f038
# ╠═b4318e67-2e90-4592-835f-e47fa872852f
# ╠═ea134bdf-17ec-4280-933d-b7b2f4c323bf
# ╠═af1f348e-5cc6-4310-979c-4d5ef89e8a41
# ╠═9a211d3c-bfcf-4b21-af66-27700f453856
# ╠═76c71444-c280-4c59-a65b-7f8b0623068c
# ╠═0ecaec62-3802-4f91-90ce-3d8680fec694
# ╠═96716227-0cfd-47c3-82de-bb98b3042a1e
# ╠═eb21a90d-5bc7-4558-9ebd-69ad6decffee
# ╠═c11ee525-3423-4958-8063-0346d6d6fa53
# ╠═5f8ce35c-a55f-4067-a4e1-e93da32dbc57
# ╠═41de7097-5739-4242-ab10-6b38b9b12b6c
# ╠═e423a56d-62d7-4d77-bb62-a8add3b270cb
# ╠═1f5b822d-1c7e-4093-9bd3-48d5b88267f0
# ╠═6b9e7928-7aa9-4284-aee2-a37568151f86
# ╠═836a4883-89df-4953-b064-2a951705b389
# ╠═3450d86e-ec15-4504-b049-f3500509c62a
# ╠═04b21833-1c88-4732-9cc5-61ecf45986b4
# ╠═41a26108-6bf1-4ce6-9891-91c1cb1b6855
# ╠═044231f1-efd6-4d98-9c77-3e97723fa574
# ╠═da4a3fc2-9a75-4009-b5dc-b52ba84c3dd0
# ╠═8ec24276-a712-4942-9281-fe992f17fc62
# ╠═984bcd02-07b4-4d7b-a383-fba9d29179df
# ╠═e8201ac3-ad14-45f6-8a81-3cc8634a8242
