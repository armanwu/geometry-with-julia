
using GLMakie
using GeometryBasics
using Colors
using Random

# Initialize the 3D visualization environment
fig = Figure(size=(1000, 600), backgroundcolor=:grey10)
ax = Axis3(fig[1, 1], aspect=:data, azimuth=0.4π, elevation=0.2π)

hidedecorations!(ax)
hidespines!(ax)

# Create the ground plane
wireframe!(ax, Rect3f(Point3f(-10, -30, 0), Vec3f(120, 60, 0)),
    linewidth=0.0
)

# Generate a parametric building structure using a series of irregular ribs
function generate_building()
    # Define the main geometric parameters
    building_length = 100
    rib_count = 30
    curve_resolution = 30

    # Initialize geometry containers
    points = Point3f[]
    faces = GLTriangleFace[]
    ribs_data = Vector{Point3f}[]

    # Generate individual curved ribs along the building length
    for i in 1:rib_count
        # Define the position and random dimensions of each rib
        position_x = (i - 1) * (building_length / rib_count)
        width = rand(5.0:15.0)
        height = rand(4.0:20.0)
        offset_y = rand(-5.0:5.0)

        # Generate points along a semicircular profile
        rib_points = Point3f[]

        for j in 1:curve_resolution
            theta = π * (j - 1) / (curve_resolution - 1)

            y = offset_y - (width * cos(theta))
            z = height * sin(theta)

            push!(rib_points, Point3f(position_x, y, z))
        end

        # Store the generated rib geometry
        push!(ribs_data, rib_points)
    end

    # Connect adjacent ribs to generate the building surface
    index_counter = 1

    for i in 1:(rib_count-1)
        current_rib = ribs_data[i]
        next_rib = ribs_data[i+1]

        # Construct triangular faces between neighboring ribs
        for j in 1:(curve_resolution-1)
            p1 = current_rib[j]
            p2 = next_rib[j]
            p3 = next_rib[j+1]
            p4 = current_rib[j+1]

            # Add vertices to the geometry
            push!(points, p1, p2, p3, p4)

            # Define two triangular faces for each surface segment
            push!(faces, GLTriangleFace(index_counter, index_counter + 1, index_counter + 2))
            push!(faces, GLTriangleFace(index_counter + 2, index_counter + 3, index_counter))

            index_counter += 4
        end
    end

    # Return the completed building mesh
    return GeometryBasics.Mesh(points, faces)
end

# Generate the building geometry
building_mesh = generate_building()

# Render the translucent building surface
mesh!(ax, building_mesh,
    color=(:teal, 0.5),
    transparency=true,
    shading=true
)

# Display the structural wireframe
wireframe!(ax, building_mesh,
    color=(:white, 0.4),
    linewidth=1.0
)

# Display the final 3D visualization
display(fig)
