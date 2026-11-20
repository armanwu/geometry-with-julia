
using GLMakie
using GeometryBasics
using Colors
using Random
using FileIO
using MeshIO

# 1. Package Imports and Generation Settings

project_name = "flux_vaults"
export_directory = joinpath(pwd(), "exports")

building_length = 100
rib_count = 30
curve_resolution = 30

default_azimuth = 0.4π
default_elevation = 0.2π

used_seeds = Set{Int}()

# 2. Seed Identification System

# Generate a unique random seed between 1 and 10000
function generate_unique_seed(used_seeds)

    # Check seed availability
    length(used_seeds) >= 10000 &&
        error("All available seeds have been used.")

    random_device = RandomDevice()

    seed = rand(random_device, 1:10000)

    while seed in used_seeds
        seed = rand(random_device, 1:10000)
    end

    return seed
end

# 3. Geometry Generation Function

function generate_building(seed::Int)

    # Initialize a reproducible random number generator
    rng = MersenneTwister(seed)

    # Initialize geometry containers
    points = Point3f[]
    faces = GLTriangleFace[]
    ribs_data = Vector{Point3f}[]

    # Generate individual curved ribs along the building length
    for i in 1:rib_count

        # Define the position and random dimensions of each rib
        position_x = (i - 1) * (building_length / rib_count)
        width = rand(rng, 5.0:15.0)
        height = rand(rng, 4.0:20.0)
        offset_y = rand(rng, -5.0:5.0)

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

# 4. Camera Framing Function

function frame_geometry!(ax, mesh; reset_orientation=false)

    # Extract mesh vertex coordinates
    vertices = GeometryBasics.coordinates(mesh)

    isempty(vertices) && error("Geometry contains no vertices.")

    # Calculate the geometry bounding box
    x_min = minimum(p[1] for p in vertices)
    x_max = maximum(p[1] for p in vertices)

    y_min = minimum(p[2] for p in vertices)
    y_max = maximum(p[2] for p in vertices)

    z_min = minimum(p[3] for p in vertices)
    z_max = maximum(p[3] for p in vertices)

    # Add margins around the geometry
    x_padding = max((x_max - x_min) * 0.08, 1.0)
    y_padding = max((y_max - y_min) * 0.08, 1.0)
    z_padding = max((z_max - z_min) * 0.08, 1.0)

    # Restore the original camera orientation when requested
    if reset_orientation
        ax.azimuth[] = default_azimuth
        ax.elevation[] = default_elevation
    end

    # Apply the calculated geometry limits
    limits!(
        ax,
        x_min - x_padding, x_max + x_padding,
        y_min - y_padding, y_max + y_padding,
        z_min - z_padding, z_max + z_padding
    )

    return nothing
end

# 5. Initial Geometry

initial_seed = generate_unique_seed(used_seeds)
push!(used_seeds, initial_seed)

building_mesh = generate_building(initial_seed)

current_mesh_ref = Ref(building_mesh)
current_seed_ref = Ref(initial_seed)

mesh_observable = Observable(building_mesh)

println("====================================")
println("JULIA GENERATIVE DESIGN SYSTEM")
println("====================================")
println("Current Seed: ", initial_seed)
println("Geometry successfully generated.")

# 6. GLMakie Visualization

fig = Figure(
    size=(1500, 900),
    backgroundcolor=:white
)

# Display the project title
title_label = Label(
    fig,
    "FLUX VAULTS",
    fontsize=24,
    font=:bold,
    halign=:left
)

fig[1, 1:4] = title_label

# Display the current seed above the viewport
seed_label = Label(
    fig,
    "CURRENT SEED: $(initial_seed)",
    fontsize=18,
    font=:bold,
    halign=:right
)

fig[1, 5:6] = seed_label

# Create the main 3D viewport
ax = Axis3(
    fig[2, 1:6],
    aspect=:data,
    azimuth=default_azimuth,
    elevation=default_elevation,
    viewmode=:fitzoom,
    backgroundcolor=:white,
    protrusions=0,
    xypanelvisible=false,
    xzpanelvisible=false,
    yzpanelvisible=false
)

# Hide all axis decorations
hidedecorations!(ax)
hidespines!(ax)

# Preserve the original ground plane
wireframe!(
    ax,
    Rect3f(Point3f(-10, -30, 0), Vec3f(120, 60, 0)),
    linewidth=0.0
)

# Render the translucent building surface
mesh!(
    ax,
    mesh_observable,
    color=(:teal, 0.5),
    transparency=true,
    shading=true
)

# Display the structural wireframe
wireframe!(
    ax,
    mesh_observable,
    color=(:grey30, 0.4),
    linewidth=1.0
)

# Frame the initial geometry
frame_geometry!(
    ax,
    building_mesh;
    reset_orientation=true
)

# 7. Interactive Control Panel

# Generate new geometry button
generate_button = Button(
    fig,
    label="GENERATE NEW",
    width=175
)
fig[3, 1] = generate_button

# Seed input textbox
seed_input = Textbox(
    fig,
    placeholder="ENTER SEED (1-10000)",
    validator=r"^[0-9]{1,5}$",
    width=175
)
fig[3, 2] = seed_input

# Reproduce seed button
reproduce_button = Button(
    fig,
    label="REPRODUCE SEED",
    width=175
)
fig[3, 3] = reproduce_button

# Export OBJ button
export_button = Button(
    fig,
    label="EXPORT OBJ",
    width=175
)
fig[3, 4] = export_button

# Reset camera button
reset_button = Button(
    fig,
    label="RESET VIEW",
    width=175
)
fig[3, 5] = reset_button

# Operation status display
status_label = Label(
    fig,
    "READY | Initial geometry generated.",
    fontsize=13,
    halign=:left
)
fig[4, 1:6] = status_label

# 8. Button Callbacks

# Update the active geometry and seed information
function update_geometry!(
    seed,
    mesh_observable,
    current_mesh_ref,
    current_seed_ref,
    seed_label,
    ax
)

    # Generate geometry using the selected seed
    new_mesh = generate_building(seed)

    # Update the currently displayed geometry
    mesh_observable[] = new_mesh

    # Store the active mesh and seed
    current_mesh_ref[] = new_mesh
    current_seed_ref[] = seed

    # Update the seed display
    seed_label.text[] = "CURRENT SEED: $(seed)"

    # Automatically frame the updated geometry
    frame_geometry!(ax, new_mesh)

    # Print the active seed in the Julia console
    println("Current Seed: ", seed)

    return nothing
end

# Generate a new geometry using a unique random seed
on(generate_button.clicks) do _

    try

        new_seed = generate_unique_seed(used_seeds)

        update_geometry!(
            new_seed,
            mesh_observable,
            current_mesh_ref,
            current_seed_ref,
            seed_label,
            ax
        )

        push!(used_seeds, new_seed)

        status_label.text[] = "SUCCESS | New geometry generated. Seed: $(new_seed)"

    catch exception

        status_label.text[] = "ERROR | $(sprint(showerror, exception))"

        @error "Generation failed" exception=(exception, catch_backtrace())
    end
end

# Reproduce geometry using a previously recorded seed
on(reproduce_button.clicks) do _

    try

        # Read the submitted seed input
        raw_seed = seed_input.stored_string[]

        raw_seed === nothing &&
            error("Please enter a seed.")

        # Convert and validate the seed
        seed = tryparse(Int, strip(raw_seed))

        seed === nothing &&
            error("Invalid seed. Enter an integer between 1 and 10000.")

        # Restrict the seed range
        1 <= seed <= 10000 ||
            error("Seed must be between 1 and 10000.")

        # Regenerate the exact geometry
        update_geometry!(
            seed,
            mesh_observable,
            current_mesh_ref,
            current_seed_ref,
            seed_label,
            ax
        )

        push!(used_seeds, seed)

        status_label.text[] = "SUCCESS | Geometry reproduced. Seed: $(seed)"

    catch exception

        status_label.text[] = "ERROR | $(sprint(showerror, exception))"

        @error "Seed reproduction failed" exception=(exception, catch_backtrace())

    end
end

# Restore the original camera orientation and framing
on(reset_button.clicks) do _

    try

        frame_geometry!(
            ax,
            current_mesh_ref[];
            reset_orientation=true
        )

        status_label.text[] = "SUCCESS | Camera orientation and framing restored."

    catch exception

        status_label.text[] = "ERROR | $(sprint(showerror, exception))"

        @error "Camera reset failed" exception=(exception, catch_backtrace())
    end
end

# 9. OBJ Export

function export_current_mesh(mesh, seed)

    # Create the export directory
    mkpath(export_directory)

    # Generate the seed-based OBJ filename
    filename = "$(project_name)_seed_$(seed).obj"

    filepath = joinpath(export_directory, filename)

    # Export the actual active geometry
    FileIO.save(filepath, mesh)

    return filepath
end

# Export the currently displayed geometry
on(export_button.clicks) do _

    try

        filepath = export_current_mesh(
            current_mesh_ref[],
            current_seed_ref[]
        )

        println("OBJ Export Completed: ", filepath)

        status_label.text[] = "SUCCESS | OBJ exported: $(basename(filepath))"

    catch exception

        status_label.text[] = "ERROR | $(sprint(showerror, exception))"

        @error "OBJ export failed" exception=(exception, catch_backtrace())
    end
end

# 10. Final Display

display(fig)
