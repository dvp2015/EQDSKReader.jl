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
	packages = [
		"GLMakie",
		"PerceptualColourMaps",
		"XLSX",
	]
	Pkg.add(packages)
	str_packages = join(packages, ", ", " and ")
	md"Install packages $(str_packages)"
end

# ╔═╡ 63826b68-1a83-4ea4-b505-d774745a2624
using PerceptualColourMaps

# ╔═╡ 9a211d3c-bfcf-4b21-af66-27700f453856
using GLMakie

# ╔═╡ 0ecaec62-3802-4f91-90ce-3d8680fec694
using EQDSKReader

# ╔═╡ ef57b24e-187f-44f7-a162-e4efc48079b5
using XLSX

# ╔═╡ c9a17fb4-3802-11ed-325c-8b2be110f038
md"""
# Analysing EQDSK file structure.
"""

# ╔═╡ b4318e67-2e90-4592-835f-e47fa872852f
begin
	const HERE = @__DIR__
	const ROOT = dirname(HERE)
	md"Working directory: _$(pwd())_"
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
		r, z, content.psirz, levels=levels, colormap=cgrad(cmap("D8")), linestyle="-",
	)
	cntr_psi_boundary = contour!(
		r, z, 
		content.psirz, 
		levels=[calc_boundary_psi(content)], 
		colormap=:greens, linestyle="-", linewidth=4
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

# ╔═╡ 3450d86e-ec15-4504-b049-f3500509c62a
interpolated_psi = create_psi_interpolator(content)

# ╔═╡ 04b21833-1c88-4732-9cc5-61ecf45986b4
let
	f = Figure(resolution=(500, 800))
	ax = Axis(
		f[1,1],
		xlabel=L"R,m", 
		ylabel=L"Z,m", 
		aspect=DataAspect(),
		title="Difference between Ψ interpolated and original."
	)
	diffs = abs.([ 
		interpolated_psi(r[i[1]], z[i[2]]) - content.psirz[i]
		for i in CartesianIndices(content.psirz)
	])
	cf = contourf!(ax, r, z, diffs, colormap=cgrad(cmap("D8")), )
	Colorbar(f[1,2], cf, label=L"|Ψ_interpolated(R,Z) - Ψ_0(R,Z)|")
	f
end

# ╔═╡ fff49e68-b186-4e94-85ec-025970551d15
let
	f = Figure(resolution=(700, 600))
	ax = Axis(
		f[1,1],
		xlabel=L"R,m", 
		ylabel=L"Ψ", 
		# aspect=DataAspect(),
		title="Ψ interpolated vs original (R, $(content.zmaxis))."
	)
	zi = searchsorted(z, content.zmaxis)
	original = [Point2f(x,y) for (x,y) in zip(r, content.psirz[:, zi.stop])]
	scatter!(ax, original, label="original")
	zsel = z[zi.stop]
	interpolated = [
		Point2f(x, interpolated_psi(x, zsel)) for x in range(r[1], r[end], length=200)
	]
	lines!(ax, interpolated, label="interpolated", color=:red)
	axislegend()
	f
end

# ╔═╡ 73152261-f0e2-4cec-8716-ba46acdbbb38
let
	f = Figure(resolution=(700, 600))
	ax = Axis(
		f[1,1],
		xlabel=L"Z,m", 
		ylabel=L"Ψ", 
		# aspect=DataAspect(),
		title="Ψ interpolated vs original ($(content.rmaxis), Z)."
	)
	ri = searchsorted(r, content.rmaxis)
	original = [Point2f(x,y) for (x,y) in zip(z, content.psirz[ri.stop, :])]
	scatter!(ax, original, label="original")
	rsel = r[ri.stop]
	interpolated = [
		Point2f(y, interpolated_psi(rsel, y)) for y in range(z[1], z[end], length=200)
	]
	lines!(ax, interpolated, label="interpolated", color=:red)
	axislegend()
	f
end

# ╔═╡ 79fa01b3-1640-4cc4-8858-2bd982568971
let
	boundary_values = [
		interpolated_psi(ri, zi) for (ri, zi) in zip(content.rbbbs, content.zbbbs)
	]
	lines(boundary_values)
end

# ╔═╡ 45af3d57-db5f-43e2-90bc-2579511e2b83
LBPX, LBPZ = lowest_boundary_point(content)

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
	ψ = create_normalized_psi_interpolator(content)
	Ψ_min, Ψ_max = extrema(ψ(r, z))
	levels=range(Ψ_min, Ψ_max, length=15)
	r_fine = range(r[1], r[end], 10length(r))
	z_fine = range(z[1], z[end], 10length(z))
	cntr = contourf!(ax,
		r_fine, z_fine, ψ, 
		levels=levels, 
		colormap=cgrad(cmap("D8")), 
		linestyle="-",
		linecolor=:black,
		linewidth=2
	)
	cntr1 = contour!(ax,
		r_fine, z_fine, ψ, 
		levels=[1.0], 
		color=:yellow,
		alpha=0.25,
		# colormap=:grays, 
		linewidth=4,
	)
	rbbs_points = [Point2f(x,y) for (x,y) in zip(content.rbbbs, content.zbbbs)]
	rlim_points = [Point2f(x,y) for (x,y) in zip(content.rlim, content.zlim)]
	scatter!(ax, content.rmaxis, content.zmaxis, color=:gray60, marker=:cross, label="Magnetic axis")
	scatter!(ax, LBPX, LBPZ, color=:gray90, marker=:diamond, label="boundary bottom")
	lines!(ax, rbbs_points, label="Plasma boundary")
	lines!(ax, rlim_points, label="Limiter")
	# plot(;aspect_ratio=:equal, xlabel="R,m", ylabel="Z,m", xlim=(0.0,3.0), ylim=(-2.0, 2.0))
	# plot!(content.rbbbs, content.zbbbs, label="plasma boundary")
	# plot!(content.rlim, content.zlim, label="limiter")
	# resize_to_layout!(f)
	Colorbar(f[1,2], cntr, label=L"Ψ(R,Z)")
	separation_value = LBPZ - 0.05
	lines!(ax, [r[1], r[end]], [separation_value, separation_value], color=:black, label="Ψ separation value")
	axislegend()
	f
end

# ╔═╡ 6deec15c-ffb5-411a-947f-ac86b60a2d13


# ╔═╡ 520d792e-139f-45d4-9f89-1dafd7f4eee0
# example with contour labels

let
	function name_contours!(ax,cplot,value)
    beginnings = Point2f[]; colors = RGBAf[]
    # First plot in contour is the line plot, first arguments are the points of the contour
    segments = cplot.plots[1][1][]
    #@info segments[1]
    for (i, p) in enumerate(segments)
        # the segments are separated by NaN, which signals that a new contour starts
        if isnan(p)
            push!(beginnings, segments[i-1])
        end
    end
    sc = scatter!(ax, beginnings, markersize=30, color=(:white, 0.1), strokecolor=:white)
    translate!(sc, 0, 0, 1)
    # Reshuffle the plot order, so that the scatter plot gets drawn before the line plot
    delete!(ax, sc)
    delete!(ax, cplot)
    push!(ax.scene, sc)
    push!(ax.scene, cplot)
    anno = text!(ax, [(string(value), p) for (i, p) in enumerate(beginnings)], 
                       align=(:center, :center), textsize=10)

    # move, so that text is in front
    translate!(anno, 0, 0, 2) 
end

x = range(-3, 3, length=200)
y = range(-2, 2, length=100)
z = 10(@. x^2 + y'^2)
fig, ax, hp = heatmap(x, y, z)
levels = 0:10:100
for contour_value in levels
        contour_plot = contour!(ax,x,y, z, color = :black, levels = [contour_value])
        name_contours!(ax,contour_plot,contour_value)
end
fig
end

# ╔═╡ Cell order:
# ╟─c9a17fb4-3802-11ed-325c-8b2be110f038
# ╟─b4318e67-2e90-4592-835f-e47fa872852f
# ╠═ea134bdf-17ec-4280-933d-b7b2f4c323bf
# ╠═af1f348e-5cc6-4310-979c-4d5ef89e8a41
# ╠═63826b68-1a83-4ea4-b505-d774745a2624
# ╠═9a211d3c-bfcf-4b21-af66-27700f453856
# ╠═76c71444-c280-4c59-a65b-7f8b0623068c
# ╠═0ecaec62-3802-4f91-90ce-3d8680fec694
# ╠═96716227-0cfd-47c3-82de-bb98b3042a1e
# ╠═eb21a90d-5bc7-4558-9ebd-69ad6decffee
# ╠═c11ee525-3423-4958-8063-0346d6d6fa53
# ╠═5f8ce35c-a55f-4067-a4e1-e93da32dbc57
# ╠═3450d86e-ec15-4504-b049-f3500509c62a
# ╠═04b21833-1c88-4732-9cc5-61ecf45986b4
# ╠═fff49e68-b186-4e94-85ec-025970551d15
# ╠═73152261-f0e2-4cec-8716-ba46acdbbb38
# ╠═79fa01b3-1640-4cc4-8858-2bd982568971
# ╠═45af3d57-db5f-43e2-90bc-2579511e2b83
# ╠═044231f1-efd6-4d98-9c77-3e97723fa574
# ╠═ef57b24e-187f-44f7-a162-e4efc48079b5
# ╠═6deec15c-ffb5-411a-947f-ac86b60a2d13
# ╠═520d792e-139f-45d4-9f89-1dafd7f4eee0
