using GLMakie
using GeometryBasics
using Random
using Colors
using FileIO
using MeshIO

# Initial generation settings
generate_new = true
saved_seed = 847999

# Initialize the seed
initial_seed = generate_new ? rand(1:999999) : saved_seed

# Generate the Chaos Crystal geometry
function chaos_crystal(seed)

    # Define the main parameters
    resolution = 12
    base_radius = 12

    rng = MersenneTwister(seed)

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
            random_radius = base_radius + rand(rng, -5.0:15.0)

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

    # Create triangular faces
    for i in 1:(resolution-1)
        for j in 1:(resolution-1)

            p1 = grid_points[i, j]
            p2 = grid_points[i, j+1]
            p3 = grid_points[i+1, j+1]
            p4 = grid_points[i+1, j]

            push!(points, p1, p2, p3, p4)

            # Divide each quadrilateral into two triangles
            current = length(points) - 3

            push!(
                faces,
                GLTriangleFace(current, current + 3, current + 2),
                GLTriangleFace(current + 2, current + 1, current)
            )
        end
    end

    # Calculate geometry boundaries
    x_bounds = extrema(p[1] for p in points)
    y_bounds = extrema(p[2] for p in points)
    z_bounds = extrema(p[3] for p in points)

    return GeometryBasics.Mesh(points, faces),
    (x_bounds, y_bounds, z_bounds)
end

# Calculate camera limits
function fit_camera!(ax, bounds)

    x_bounds, y_bounds, z_bounds = bounds

    geometry_size = maximum((
        x_bounds[2] - x_bounds[1],
        y_bounds[2] - y_bounds[1],
        z_bounds[2] - z_bounds[1]
    ))

    padding = max(geometry_size * 0.07, 1.0)

    limits!(
        ax,
        x_bounds[1] - padding,
        x_bounds[2] + padding,
        y_bounds[1] - padding,
        y_bounds[2] + padding,
        z_bounds[1] - padding,
        z_bounds[2] + padding
    )
end

# Generate the initial crystal
initial_mesh, initial_bounds = chaos_crystal(initial_seed)

# Store the current geometry and seed
current_mesh = Observable(initial_mesh)
current_seed = Observable(initial_seed)

# Create interface text
seed_text = Observable("CHAOS CRYSTAL  |  SEED: $initial_seed")
status_text = Observable("Ready")
entered_seed = Observable("")

# Create the figure
fig = Figure(
    size=(1200, 800),
    backgroundcolor=:white
)

Label(
    fig[1, 1],
    seed_text,
    fontsize=24,
    tellwidth=false
)

# Create the 3D viewport
ax = Axis3(
    fig[2, 1],
    aspect=:data,
    azimuth=(-π / 2),
    elevation=0.10π,
    perspectiveness=0,
    viewmode=:fitzoom,
    backgroundcolor=:white,
    xgridvisible=false,
    ygridvisible=false,
    zgridvisible=false,
    xspinesvisible=false,
    yspinesvisible=false,
    zspinesvisible=false
)

# Hide axis decorations and spines
hidedecorations!(ax)
hidespines!(ax)

# Display the solid geometry
mesh!(
    ax,
    current_mesh,
    color=(RGB(0.50, 0.70, 0.68), 0.9),
    shading=true
)

# Display the mesh edges
wireframe!(
    ax,
    current_mesh,
    color=(:black, 0.28),
    linewidth=1.2
)

# Fit the initial geometry
fit_camera!(ax, initial_bounds)

# Create the control panel
controls = GridLayout(tellwidth=false)
fig[3, 1] = controls

# Generate button
generate_button = Button(
    fig,
    label="Generate New",
    width=150
)

# Seed input field
seed_input = Textbox(
    fig,
    placeholder="Enter seed (1-999999)",
    validator=r"^[1-9][0-9]{0,5}$",
    width=190
)

# Reproduce button
reproduce_button = Button(
    fig,
    label="Reproduce Seed",
    width=150
)

# Export button
export_button = Button(
    fig,
    label="Export OBJ",
    width=130
)

# Reset camera button
reset_button = Button(
    fig,
    label="Reset View",
    width=130
)

# Arrange the controls
controls[1, 1:5] = [
    generate_button,
    seed_input,
    reproduce_button,
    export_button,
    reset_button
]

# Display status information
Label(
    fig[4, 1],
    status_text,
    fontsize=13,
    tellwidth=false
)

# Store submitted seed input
on(seed_input.stored_string) do value
    entered_seed[] = value
end

# Generate a new random geometry
on(generate_button.clicks) do n

    new_seed = rand(1:999999)

    new_mesh, new_bounds = chaos_crystal(new_seed)

    current_mesh[] = new_mesh
    current_seed[] = new_seed

    seed_text[] = "CHAOS CRYSTAL  |  SEED: $new_seed"

    fit_camera!(ax, new_bounds)

    status_text[] = "New geometry generated successfully."

    println("NEW CHAOS CRYSTAL SEED: ", new_seed)
end

# Reproduce a previously saved geometry
on(reproduce_button.clicks) do n

    if isempty(entered_seed[])

        status_text[] = "Please enter a seed and press Enter."

    else

        selected_seed = tryparse(Int, entered_seed[])

        if isnothing(selected_seed) ||
            !(1 <= selected_seed <= 999999)

            status_text[] = "Invalid seed number."

        else

            selected_mesh, selected_bounds =
                chaos_crystal(selected_seed)

            current_mesh[] = selected_mesh
            current_seed[] = selected_seed

            seed_text[] = "CHAOS CRYSTAL  |  SEED: $selected_seed"

            fit_camera!(ax, selected_bounds)

            status_text[] = "Geometry reproduced successfully."

            println("REPRODUCED SEED: ", selected_seed)
        end
    end
end

# Export the selected geometry as OBJ
on(export_button.clicks) do n

    filename = "chaos_crystal_seed_$(current_seed[]).obj"

    try
        save(filename, current_mesh[])

        status_text[] = "Exported: $filename"

        println("OBJ EXPORTED: ", abspath(filename))

    catch error
        status_text[] = "Export failed. Check the Julia console."

        showerror(stderr, error)
        println()
    end
end

# Reset the camera position
on(reset_button.clicks) do n

    ax.azimuth[] = -π / 2
    ax.elevation[] = 0.10π

    reset_limits!(ax)

    status_text[] = "Camera view reset."
end

# Display the interface
println("CHAOS CRYSTAL CONTROL PANEL")
println("CURRENT SEED: ", initial_seed)

display(fig)