using GLMakie
using GeometryBasics
using LinearAlgebra

nx, ny = 20, 12
grid_x = range(-10, 10, length=nx)
grid_y = range(-6, 6, length=ny)

panel_centers = Point2f[]
for y in grid_y
    for x in grid_x
        push!(panel_centers, Point2f(x, y))
    end
end

sizes_live = Observable(fill(Vec2f(0.9, 0.9), length(panel_centers)))

sun_pos = Observable(Point2f(0, 0))

function update_panels(matahari)
    new_sizes = Vec2f[]

    for center in panel_centers
        dist = norm(center - matahari)
        faktor = clamp(dist / 8.0, 0.1, 1.0)
        push!(new_sizes, Vec2f(faktor * 0.9, faktor * 0.9))
    end
    return new_sizes
end

fig = Figure(size=(900, 600))
ax = Axis(fig[1, 1], aspect=DataAspect())

meshscatter!(ax, panel_centers,
    marker=Rect2f(Vec2f(-0.5), Vec2f(1)),
    markersize=sizes_live,
    color=:cyan,
    shading=NoShading
)

scatter!(ax, sun_pos, color=:red, markersize=30, glowwidth=20, glowcolor=(:red, 0.5))

display(fig)

@async begin
    println("Matahari bergerak..")
    for t in 0:0.5:20
        mx = sin(t) * 8
        my = sin(t * 2) * 4
        posisi_baru = Point2f(mx, my)

        sun_pos[] = posisi_baru
        sizes_live[] = update_panels(posisi_baru)

        sleeo(0.02)
    end
    Println("Selesai!")
end