
using GLMakie
using GeometryBasics
using LinearAlgebra

# Define the voxel grid boundaries
x_range = -5:5
y_range = -5:5
z_range = 0:20

# Define the spherical cutting tool
cutter_center = Point3f(5, 5, 10)
cutter_radius = 7.0

# Initialize observable data for real-time visualization
voxels_live = Observable(Point3f[])
colors_live = Observable(Float64[])

# Create the visualization figure and 3D scene
fig = Figure(size=(1000, 1000))
ax = LScene(fig[1, 1])

# Define the site boundary as a transparent wireframe box
site_bounds = Rect3f(Vec3f(-7, -7, 0), Vec3f(14, 14, 21))
wireframe!(ax, site_bounds, color=:grey30, linewidth=0.2, transparency=true)

# Visualize voxels using individual cube markers
# Color intensity represents the distance from the cutting tool center
meshscatter!(ax, voxels_live,
    marker=Rect3f(Vec3f(-0.5), Vec3f(1)),
    markersize=1.0,
    color=colors_live,
    colormap=:ice,
    colorrange=(0, 15),
)

# Display the initial visualization
display(fig)

# Execute the voxel generation process asynchronously
@async begin
    println("Starting voxel generation...")

    # Create temporary arrays to store voxel positions and colors
    temp_voxels = Point3f[]
    temp_colors = Float64[]

    # Iterate through the entire 3D voxel grid
    for z in z_range
        for x in x_range
            for y in y_range

                # Define the current voxel position
                point = Point3f(x, y, z)

                # Calculate the Euclidean distance from the cutting tool center
                distance = norm(point - cutter_center)

                # Retain voxels located outside the spherical cutting region
                if distance > cutter_radius
                    push!(temp_voxels, point)
                    push!(temp_colors, distance)

                    # Update the visualization in real time
                    voxels_live[] = temp_voxels
                    colors_live[] = temp_colors

                    # Introduce a short delay for progressive visualization
                    sleep(0.00001)
                end
            end
        end

        # Allow the rendering process to refresh between layers
        sleep(0.00001)
    end

    println("Voxel generation completed!")
end
