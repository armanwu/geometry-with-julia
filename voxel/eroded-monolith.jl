using GLMakie
using GeometryBasics
using LinearAlgebra

range_x = -5:5
range_y = -5:5
range_z = 0:20
center_pahat = Point3f(5, 5, 10)
radius_pahat = 7.0

voxels_live = Observable(Point3f[])
colors_live = Observable(Float64[])

fig = Figure(size=(800, 800))
ax = LScene(fig[1, 1])

batas_lahan = Rect3f(Vec3f(-7, -7, 0), Vec3f(14, 14, 21))
wireframe!(ax, batas_lahan, color=:grey30, linewidth=0.2, transparency=true)

meshscatter!(ax, voxels_live,
    marker=Rect3f(Vec3f(-0.5), Vec3f(1)),
    markersize=1.0,
    color=colors_live,
    colormap=:ice,
    colorrange=(0, 15),
)

display(fig)

@async begin
    println("Mulai Membangun...")

    temp_voxels = Point3f[]
    temp_colors = Float64[]

    for z in range_z
        for x in range_x
            for y in range_y

                p = Point3f(x, y, z)
                dist = norm(p - center_pahat)

                if dist > radius_pahat
                    push!(temp_voxels, p)
                    push!(temp_colors, dist)

                    voxels_live[] = temp_voxels
                    colors_live[] = temp_colors

                    sleep(0.00001)
                end
            end
        end
        sleep(0.00001)
    end
    println("Selesai!")
end