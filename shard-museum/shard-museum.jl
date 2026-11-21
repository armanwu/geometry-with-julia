using GLMakie
using GeometryBasics
using Random
using Colors

# Initialize the 3D visualization environment
fig = Figure(
    size=(960, 1000),
    backgroundcolor=:white
)

# Configure the 3D architectural visualization
ax = Axis3(
    fig[1, 1],
    aspect=:data,
    azimuth=0.6π,
    elevation=0.15π
)

# Hide axis decorations and spines
hidedecorations!(ax)
hidespines!(ax)

# Generate an inclined and twisted triangular prism
function create_sharp_prism(
    center_x,
    center_y,
    height,
    tilt_x,
    tilt_y,
    rotation_z
)

    # Define the randomized width of the triangular base
    base_width = rand(15.0:25.0)

    # Generate three vertices forming the triangular base
    base_points = [
        Point3f(
            center_x + rand(-5:5),
            center_y + rand(-5:5),
            0
        ),
        Point3f(
            center_x + base_width,
            center_y + rand(-5:5),
            0
        ),
        Point3f(
            center_x + rand(0:5),
            center_y + base_width,
            0
        )
    ]

    # Calculate horizontal displacement based on height and inclination
    offset_x = tilt_x * height
    offset_y = tilt_y * height

    # Generate the upper triangular surface
    roof_points = [
        point + Point3f(offset_x, offset_y, height)
        for point in base_points
    ]

    # Calculate rotation components around the vertical Z-axis
    cos_angle = cos(rotation_z)
    sin_angle = sin(rotation_z)

    # Calculate the geometric center of the upper surface
    roof_center = sum(roof_points) / 3

    # Initialize the collection of rotated upper vertices
    rotated_roof_points = Point3f[]

    # Rotate the upper vertices around their geometric center
    # The triangular base remains stationary
    for point in roof_points

        # Calculate local coordinates relative to the roof center
        dx = point[1] - roof_center[1]
        dy = point[2] - roof_center[2]

        # Apply the rotation transformation
        rotated_x =
            dx * cos_angle -
                dy * sin_angle +
                roof_center[1]

        rotated_y =
            dx * sin_angle +
                dy * cos_angle +
                roof_center[2]

        # Store the transformed upper vertex
        push!(
            rotated_roof_points,
            Point3f(
                rotated_x,
                rotated_y,
                point[3]
            )
        )
    end

    # Combine the base and upper vertices
    # Vertices 1-3 define the triangular base
    # Vertices 4-6 define the transformed upper surface
    all_points = [
        base_points;
        rotated_roof_points
    ]

    # Construct the triangular faces of the prism
    faces = [

        # Bottom triangular surface
        GLTriangleFace(1, 2, 3),

        # Top triangular surface
        GLTriangleFace(4, 6, 5),

        # First lateral surface
        GLTriangleFace(1, 2, 5),
        GLTriangleFace(1, 5, 4),

        # Second lateral surface
        GLTriangleFace(2, 3, 6),
        GLTriangleFace(2, 6, 5),

        # Third lateral surface
        GLTriangleFace(3, 1, 4),
        GLTriangleFace(3, 4, 6)
    ]

    # Construct and return the final architectural mesh
    return GeometryBasics.Mesh(
        all_points,
        faces
    )
end

# Initialize the architectural massing composition
println("Generating Deconstructivist Museum...")

# Define a titanium-inspired metallic color palette
titanium_palette = [

    # Zinc Grey
    RGBAf(0.6, 0.65, 0.7, 0.9),

    # Dark Metal
    RGBAf(0.5, 0.55, 0.6, 0.9),

    # Light Aluminium
    RGBAf(0.7, 0.75, 0.8, 0.8),

    # Contrast Dark
    RGBAf(0.2, 0.25, 0.3, 0.95)
]

# Define four intersecting architectural masses
# Each configuration contains:
# center_x, center_y, height, tilt_x, tilt_y, rotation_z

mass_configurations = [

    # Primary architectural mass
    (0, 0, 35.0, 0.4, 0.2, 0.2),

    # Secondary mass intersecting from the left
    (-10, 5, 25.0, -0.5, 0.1, -0.3),

    # Secondary mass intersecting from the front
    (5, -10, 20.0, 0.1, -0.6, 0.5),

    # Tall inclined architectural spire
    (0, 0, 45.0, -0.2, -0.2, 0.8)
]

# Generate the architectural composition
for (index, configuration) in enumerate(mass_configurations)

    # Extract geometric transformation parameters
    center_x, center_y, height, tilt_x, tilt_y, rotation_z = configuration

    # Generate the inclined and twisted triangular prism
    architectural_mass = create_sharp_prism(
        center_x,
        center_y,
        height,
        tilt_x,
        tilt_y,
        rotation_z
    )

    # Select the corresponding metallic material color
    material_color = titanium_palette[
        mod1(index, length(titanium_palette))
    ]

    # Render the solid architectural geometry
    # FastShading provides basic surface illumination
    # Specular controls the intensity of reflected highlights
    # Shininess controls the appearance of metallic reflections
    mesh!(
        ax,
        architectural_mass,
        color=material_color,
        shading=FastShading,
        specular=Vec3f(0.8),
        shininess=10.0f0
    )

    # Highlight the geometric edges using a white wireframe
    # The wireframe emphasizes angularity and geometric fragmentation
    wireframe!(
        ax,
        architectural_mass,
        color=(:white, 0.6),
        linewidth=1.5
    )
end

# Optional human-scale reference
# Uncomment the following code to display a human-scale marker

# mesh!(
#     ax,
#     Rect3f(
#         Point3f(15, 15, 0),
#         Vec3f(0.5, 0.5, 1.8)
#     ),
#     color=:red
# )

# Display the final architectural composition
display(fig)