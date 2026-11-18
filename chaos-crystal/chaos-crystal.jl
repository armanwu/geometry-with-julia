using GLMakie
using GeometryBasics
using Random

fig = Figure(size=(800, 800))

ax = Axis3(
    fig[1, 1],
    aspect=:data,
    azimuth=(-π / 2),
    elevation=0,
    perspectiveness=0
)

hidedecorations!(ax)
hidespines!(ax)

wireframe!(
    ax,
    Rect3f(Point3f(-30, -30, 0), Vec3f(60, 60, 0)),
    color=(:white, 0.1),
    linewidth=0.0
)

function chaos_crystal()

    resolution = 12
    base_radius = 12

    points = Point3f[]
    faces = GLTriangleFace[]

    grid_points = Matrix{Point3f}(undef, resolution, resolution)

    for i in 1:resolution
        for j in 1:resolution

            theta = π * (i - 1) / (resolution - 1)
            phi = 2π * (j - 1) / (resolution - 1)

            random_radius = base_radius + rand(-5.0:15.0)

            x = random_radius * sin(theta) * cos(phi)
            y = random_radius * sin(theta) * sin(phi)
            z = random_radius * cos(theta)

            final_z = max(z + 10, 0)

            grid_points[i, j] = Point3f(x, y, final_z)
        end
    end

    index(i, j) = (i - 1) * resolution + j

    for i in 1:(resolution-1)
        for j in 1:(resolution-1)

            p1 = grid_points[i, j]
            p2 = grid_points[i, j+1]
            p3 = grid_points[i+1, j+1]
            p4 = grid_points[i+1, j]

            push!(points, p1, p2, p3, p4)

            current = length(points) - 3

            push!(
                faces,
                GLTriangleFace(current, current + 1, current + 2),
                GLTriangleFace(current + 2, current + 3, current)
            )
        end
    end

    return GeometryBasics.Mesh(points, faces)
end

crystal_mesh = chaos_crystal()

mesh!(
    ax,
    crystal_mesh,
    color=(:cyan, 0.7),
    shading=true
)

wireframe!(
    ax,
    crystal_mesh,
    color=(:black, 0.3),
    linewidth=1.5
)

display(fig)