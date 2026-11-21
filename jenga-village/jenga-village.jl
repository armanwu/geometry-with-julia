
using GLMakie
using GeometryBasics
using Random
using Colors

# Initialize the random generation system
seed = 2026
rng = MersenneTwister(seed)

# Initialize the 3D visualization environment
fig = Figure(
    size=(900, 900),
    backgroundcolor=:white
)

view_limits = (-15, 60, -15, 60, 0, 25)

ax = Axis3(
    fig[1, 1],
    aspect=:data,
    limits=view_limits,
    perspectiveness=0.05,
    azimuth=0.25π,
    elevation=0.2π
)

# Hide axis decorations and spines
hidedecorations!(ax)
hidespines!(ax)

# Display the visualization window
display(fig)

# Define the basic architectural parameters
block_size = 10.0
floor_height = 4.0

grid_count_x = 4
grid_count_y = 4

grid_spacing = 1.3

min_floors = 1
max_floors = 3

# Define the generative transformation parameters
rotation_angles = [0, 15, 30, 45, 90]

length_factors = [1.0, 1.0, 1.3, 1.5, 1.8]
width_factors = [0.7, 0.8, 1.0, 1.0]

max_displacement = 2.5

# Define the architectural color palette
color_palette = [
    RGBAf(0.0, 0.8, 0.9, 0.9),
    RGBAf(0.0, 0.5, 0.6, 0.9),
    RGBAf(0.2, 0.7, 0.6, 0.9),
    RGBAf(0.6, 0.65, 0.7, 0.9)
]

# Create a rotated architectural block
function create_rotated_block!(
    ax,
    center_x,
    center_y,
    base_z,
    length_x,
    width_y,
    height_z,
    angle,
    block_color
)

    # Convert the rotation angle to radians
    theta = deg2rad(angle)

    # Calculate the rotation components
    cos_theta = cos(theta)
    sin_theta = sin(theta)

    # Define the local block corners
    local_corners = [
        (-length_x / 2, -width_y / 2),
        (length_x / 2, -width_y / 2),
        (length_x / 2, width_y / 2),
        (-length_x / 2, width_y / 2)
    ]

    # Rotate the block corners around the vertical axis
    rotated_corners = Point3f[]

    for (local_x, local_y) in local_corners

        rotated_x =
            center_x +
                local_x * cos_theta -
                local_y * sin_theta

        rotated_y =
            center_y +
                local_x * sin_theta +
                local_y * cos_theta

        push!(
            rotated_corners,
            Point3f(rotated_x, rotated_y, base_z)
        )

    end

    # Generate the bottom and top vertices
    vertices = Point3f[]

    for point in rotated_corners
        push!(vertices, point)
    end

    for point in rotated_corners
        push!(
            vertices,
            Point3f(point[1], point[2], base_z + height_z)
        )
    end

    # Define the triangular faces of the block
    faces = [
        1 3 2;
        1 4 3;
        5 6 7;
        5 7 8;
        1 2 6;
        1 6 5;
        2 3 7;
        2 7 6;
        3 4 8;
        3 8 7;
        4 1 5;
        4 5 8
    ]

    # Convert the face indices into triangle faces
    triangle_faces = [
        TriangleFace{Int}(
            faces[i, 1],
            faces[i, 2],
            faces[i, 3]
        )
        for i in 1:size(faces, 1)
    ]

    # Construct the rotated block geometry
    block_mesh = GeometryBasics.Mesh(
        vertices,
        triangle_faces
    )

    # Render the architectural mass
    mesh!(
        ax,
        block_mesh,
        color=block_color,
        shading=true
    )

    # Define the twelve visible block edges
    edge_pairs = [
        (1, 2), (2, 3), (3, 4), (4, 1),
        (5, 6), (6, 7), (7, 8), (8, 5),
        (1, 5), (2, 6), (3, 7), (4, 8)
    ]

    # Draw the architectural outlines
    for (start_index, end_index) in edge_pairs

        lines!(
            ax,
            [
                vertices[start_index],
                vertices[end_index]
            ],
            color=:black,
            linewidth=1.0
        )

    end

end

# Generate the architectural village asynchronously
@async begin

    # Iterate through the horizontal village grid
    for x in 1:grid_count_x
        for y in 1:grid_count_y

            # Randomly determine the building height
            floor_count = rand(
                rng,
                min_floors:max_floors
            )

            # Calculate the building grid position
            base_x = (x - 1) * block_size * grid_spacing
            base_y = (y - 1) * block_size * grid_spacing

            # Generate the stacked building masses
            for z in 1:floor_count

                # Calculate the vertical position
                pos_z = (z - 1) * floor_height

                # Generate random horizontal displacements
                offset_x = (
                    rand(rng) * 2 - 1
                ) * max_displacement

                offset_y = (
                    rand(rng) * 2 - 1
                ) * max_displacement

                # Generate random block dimensions
                length_factor = rand(rng, length_factors)
                width_factor = rand(rng, width_factors)

                length_x = block_size * length_factor
                width_y = block_size * width_factor

                # Randomly select a rotation angle
                rotation_angle = rand(
                    rng,
                    rotation_angles
                )

                # Calculate the center of the architectural mass
                center_x =
                    base_x + block_size / 2 + offset_x

                center_y =
                    base_y + block_size / 2 + offset_y

                # Randomly select the architectural color
                block_color = rand(
                    rng,
                    color_palette
                )

                # Generate the transformed architectural block
                create_rotated_block!(
                    ax,
                    center_x,
                    center_y,
                    pos_z,
                    length_x,
                    width_y,
                    floor_height,
                    rotation_angle,
                    block_color
                )

                # Animate the construction sequence
                sleep(0.1)

            end

        end

        # Pause between village grid columns
        sleep(0.2)

    end

end
