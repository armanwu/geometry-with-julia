
using GLMakie
using GeometryBasics
using Random
using Colors

# Initialize the 3D visualization environment
fig = Figure(size=(800, 800))

# Configure the 3D camera and viewing angle
ax = Axis3(fig[1, 1],
    aspect=:data,
    perspectiveness=0.2,
    azimuth=0.35π,
    elevation=0.15π
)

# Hide axis decorations and spines
hidedecorations!(ax)
hidespines!(ax)

# Define the spatial boundaries
limits!(ax, -60, 60, -60, 60, 0, 90)

# Display the visualization window
display(fig)

# Generate an aggressive shard geometry
function create_aggressive_shard(center)

    # Generate three randomly displaced base vertices
    p1 = center + Point3f(rand(-35:35), rand(-35:35), rand(-5:5))
    p2 = center + Point3f(rand(-35:35), rand(-35:35), rand(-5:5))
    p3 = center + Point3f(rand(-35:35), rand(-35:35), rand(-5:5))

    # Generate a randomly displaced elevated apex
    apex = center + Point3f(rand(-55:55), rand(-55:55), rand(60:85))

    # Assemble the four vertices of the shard
    vertices = [p1, p2, p3, apex]

    # Define the triangular faces of the geometry
    faces = [
        TriangleFace(1, 2, 4),
        TriangleFace(2, 3, 4),
        TriangleFace(3, 1, 4),
        TriangleFace(1, 2, 3)
    ]

    # Construct and return the triangular mesh
    return GeometryBasics.Mesh(vertices, faces)
end

# Define the architectural shard color palette
shard_palette = [
    RGBAf(0.5, 0.6, 0.7, 0.95),
    RGBAf(0.3, 0.4, 0.5, 0.95),
    RGBAf(0.7, 0.8, 0.9, 0.9),
    RGBAf(0.2, 0.2, 0.3, 1.0)
]

# Generate and visualize eight randomly shaped shards
@async begin
    for i in 1:8

        # Generate a new shard at the origin
        shard = create_aggressive_shard(Point3f(0, 0, 0))

        # Render the shard with a randomly selected color
        mesh!(ax, shard,
            color=rand(shard_palette),
            shading=true
        )

        # Highlight the triangular edges with white wireframes
        wireframe!(ax, shard,
            color=:white,
            linewidth=2.0
        )

        # Introduce a short delay for sequential generation
        sleep(0.3)
    end
end
