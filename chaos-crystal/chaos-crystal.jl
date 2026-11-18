using GLMakie
using GeometryBasics
using Random
using Colors

# Create the 3D drawing environment
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

# Create the ground plane
wireframe!(
    ax,
    Rect3f(Point3f(-30, -30, 0), Vec3f(60, 60, 0)),
    color=(:white, 0.1),
    linewidth=0.0
)

# Generate the Chaos Crystal geometry
function chaos_crystal()

    # Define the main parameters
    resolution = 12
    base_radius = 12

    # Initialize mesh data
    points = Point3f[]
    faces = GLTriangleFace[]

    # Create a grid to store 3D points
    grid_points = Matrix{Point3f}(undef, resolution, resolution)

    # Generate points using spherical coordinates
    for i in 1:resolution
        for j in 1:resolution

            theta = π * (i - 1) / (resolution - 1)
            phi = 2π * (j - 1) / (resolution - 1)

            # Apply random radius variation
            random_radius = base_radius + rand(-5.0:15.0)

            # Convert spherical coordinates into Cartesian coordinates
            x = random_radius * sin(theta) * cos(phi)
            y = random_radius * sin(theta) * sin(phi)
            z = random_radius * cos(theta)

            # Raise the geometry above ground
            final_z = max(z + 10, 0)

            grid_points[i, j] = Point3f(x, y, final_z)
        end
    end

    # Close the spherical surface
    for i in 1:resolution
        grid_points[i, resolution] = grid_points[i, 1]
    end

    # Connect the top and bottom poles
    for j in 1:resolution
        grid_points[1, j] = grid_points[1, 1]
        grid_points[resolution, j] = grid_points[resolution, 1]
    end

    # Connect neighboring points to create triangular faces
    for i in 1:(resolution-1)
        for j in 1:(resolution-1)

            p1 = grid_points[i, j]
            p2 = grid_points[i, j+1]
            p3 = grid_points[i+1, j+1]
            p4 = grid_points[i+1, j]

            push!(points, p1, p2, p3, p4)

            # Divide each quadrilateral into two outward-facing triangles
            current = length(points) - 3

            push!(
                faces,
                GLTriangleFace(current, current + 3, current + 2),
                GLTriangleFace(current + 2, current + 1, current)
            )
        end
    end

    # Return the final 3D mesh
    return GeometryBasics.Mesh(points, faces)
end

# Generate the crystal
crystal_mesh = chaos_crystal()

# Display the solid surface
mesh!(
    ax,
    crystal_mesh,
    color=(RGB(0.50, 0.70, 0.68), 0.9),
    shading=true
)

# Display the mesh edges
wireframe!(
    ax,
    crystal_mesh,
    color=(:black, 0.28),
    linewidth=1.2
)

# Render the final result
display(fig)