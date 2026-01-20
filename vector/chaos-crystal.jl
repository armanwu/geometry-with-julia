using GLMakie
using GeometryBasics
using Random
using Colors

fig = Figure(size=(800, 800))
ax = Axis3(fig[1, 1], aspect=:data, azimuth=0.3π, elevation=0.2π)
hidedecorations!(ax);
hidespines!(ax);

wireframe!(ax, Rect3f(Point3f(-30, -30, 0), Vec3f(60, 60, 0)),
    color=(:white, 0.1), linewidth=0.0)

function chaos_crystal()
    resolusi = 12
    radius_dasar = 12

    points = Point3f[]
    faces = GLTriangleFace[]

    grid_points = Matrix{Point3f}(undef, resolusi, resolusi)

    for i in 1:resolusi
        for j in 1:resolusi

            theta = π * (i - 1) / (resolusi - 1)
            phi = 2π * (j - 1) / (resolusi - 1)

            radius_acak = radius_dasar + rand(-5.0:15.0)

            x = radius_acak * sin(theta) * cos(phi)
            y = radius_acak * sin(theta) * sin(phi)
            z = radius_acak * cos(theta)

            z_final = z + 10

            if z_final < 0
                z_final = 0
            end

            grid_points[i, j] = Point3f(x, y, z_final)
        end
    end

    idx(i, j) = (i - 1) * resolusi + j

    for i in 1:(resolusi-1)
        for j in 1:(resolusi-1)
            p1 = grid_points[i, j]
            p2 = grid_points[i, j+1]
            p3 = grid_points[i+1, j+1]
            p4 = grid_points[i+1, j]

            push!(points, p1, p2, p3, p4)

            current = length(points) - 3
            push!(faces, GLTriangleFace(current, current + 1, current + 2))
            push!(faces, GLTriangleFace(current + 2, current + 3, current))
        end
    end

    return GeometryBasics.Mesh(points, faces)
end

mesh_kristal = chaos_crystal()

mesh!(ax, mesh_kristal, color=(:cyan, 0.7), shading=true)

wireframe!(ax, mesh_kristal, color=(:black, 0.3), linewidth=1.5)

display(fig)