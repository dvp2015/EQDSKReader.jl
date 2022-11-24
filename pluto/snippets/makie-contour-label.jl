# example with contour labels
using GLMakie

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
