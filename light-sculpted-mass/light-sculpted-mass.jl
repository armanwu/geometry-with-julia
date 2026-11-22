
using GLMakie
using GeometryBasics
using Random
using Colors
using Dates
using Statistics

# Define the geographic location
const LATITUDE = -6.9175
const LONGITUDE = 107.6191
const UTC_OFFSET = 7.0

# Define the initial design settings
const INITIAL_SEED = 2026
const INITIAL_DATE = Date(2026, 11, 22)
const INITIAL_HOUR = 9
const INITIAL_MINUTE = 0

# Define the analytical grid resolution
const GROUND_MIN = -80.0
const GROUND_MAX = 80.0
const GROUND_STEP = 2.5
const SURFACE_STEP = 3.0

# Define the daily solar analysis period
const SUN_START_HOUR = 5
const SUN_END_HOUR = 19
const SUN_INTERVAL = 30
const MAX_SUN_HOURS = 14.0

# Define the architectural material
const CONCRETE_COLOR = RGBf(0.80, 0.81, 0.79)
const CONCRETE_DIFFUSE = Vec3f(0.85, 0.85, 0.85)
const CONCRETE_SPECULAR = Vec3f(0.02, 0.02, 0.02)
const CONCRETE_SHININESS = 8f0

# Define the analytical color palette
const SOLAR_PALETTE = RGBf[
    RGBf(0.13, 0.22, 0.50),
    RGBf(0.13, 0.50, 0.78),
    RGBf(0.28, 0.73, 0.62),
    RGBf(0.95, 0.79, 0.26),
    RGBf(0.83, 0.30, 0.18)
]

const NEUTRAL_GROUND = RGBf(0.92, 0.91, 0.88)
const SHADOW_COLOR = RGBf(0.44, 0.48, 0.52)
const SUNLIT_COLOR = RGBf(0.92, 0.89, 0.83)

# Define an axis-aligned architectural solid
struct BoxVolume
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64
    zmin::Float64
    zmax::Float64
end

# Create a solid from its center and dimensions
function make_box(cx, cy, width, depth, zmin, zmax)

    return BoxVolume(
        cx - width / 2,
        cx + width / 2,
        cy - depth / 2,
        cy + depth / 2,
        zmin,
        zmax
    )
end

# Check whether a point lies inside a solid
function inside_box(x, y, z, box::BoxVolume)

    return (
        box.xmin <= x <= box.xmax &&
            box.ymin <= y <= box.ymax &&
            box.zmin <= z <= box.zmax
    )
end

# Evaluate the final constructive solid geometry
function inside_solid(x, y, z, additions, cutters)

    occupied = any(
        b -> inside_box(x, y, z, b),
        additions
    )

    if !occupied
        return false
    end

    removed = any(
        b -> inside_box(x, y, z, b),
        cutters
    )

    return !removed
end

# Create an empty geometry container
function new_geometry()

    return (
        Point3f[],
        TriangleFace{Int}[]
    )
end

# Add a quadrilateral surface
function add_quad!(geo, a, b, c, d)

    vertices, faces = geo
    base = length(vertices)

    append!(vertices, Point3f[a, b, c, d])

    push!(
        faces,
        TriangleFace(base + 1, base + 2, base + 3)
    )

    push!(
        faces,
        TriangleFace(base + 1, base + 3, base + 4)
    )

    return nothing
end

# Convert geometry into a renderable mesh
function build_mesh(geo)

    return GeometryBasics.Mesh(
        geo[1],
        geo[2]
    )
end

# Generate a monumental architectural composition
function generate_architecture(seed)

    rng = MersenneTwister(seed)

    additions = BoxVolume[]
    cutters = BoxVolume[]

    # Select the architectural composition family
    composition = rand(rng, 1:4)

    names = (
        "Carved Monolith",
        "Shifted Monoliths",
        "Terraced Monolith",
        "Light Canyon"
    )

    # Generate the dominant primary mass
    base_width = rand(rng, 60.0:1.0:72.0)
    base_depth = rand(rng, 43.0:1.0:54.0)
    base_height = rand(rng, 22.0:1.0:30.0)

    push!(
        additions,
        make_box(
            0.0, 0.0,
            base_width,
            base_depth,
            0.0,
            base_height
        )
    )

    # Generate the secondary monolithic mass
    side = rand(rng, (-1.0, 1.0))

    secondary_x = side * rand(rng, 13.0:1.0:21.0)
    secondary_y = rand(rng, 3.0:1.0:12.0)

    secondary_width = rand(rng, 28.0:1.0:37.0)
    secondary_depth = rand(rng, 30.0:1.0:41.0)
    secondary_height = rand(rng, 32.0:1.0:42.0)

    # Apply composition-specific transformations
    if composition == 2

        secondary_x *= 1.30
        secondary_y += 5.0

    elseif composition == 3

        secondary_height *= 1.15

    elseif composition == 4

        secondary_x *= 0.75
        secondary_y += 7.0
    end

    push!(
        additions,
        make_box(
            secondary_x,
            secondary_y,
            secondary_width,
            secondary_depth,
            0.0,
            secondary_height
        )
    )

    # Generate a massive projecting gallery
    extension_level = rand(rng, 17.0:1.0:24.0)

    extension_x = -side * rand(rng, 10.0:1.0:18.0)
    extension_y = rand(rng, -11.0:1.0:-4.0)

    extension_width = rand(rng, 35.0:1.0:48.0)
    extension_depth = rand(rng, 23.0:1.0:33.0)
    extension_height = rand(rng, 11.0:1.0:17.0)

    if composition == 1

        extension_x *= 1.15

    elseif composition == 3

        extension_level += 6.0

    elseif composition == 4

        extension_y -= 5.0
    end

    push!(
        additions,
        make_box(
            extension_x,
            extension_y,
            extension_width,
            extension_depth,
            extension_level,
            extension_level + extension_height
        )
    )

    # Generate the central open-air courtyard
    courtyard_x = rand(rng, -8.0:1.0:8.0)
    courtyard_y = rand(rng, 1.0:1.0:8.0)

    courtyard_width = rand(rng, 15.0:1.0:23.0)
    courtyard_depth = rand(rng, 18.0:1.0:27.0)

    if composition == 2

        courtyard_x += 7.0 * side

    elseif composition == 4

        courtyard_width *= 0.75
        courtyard_depth *= 1.25
    end

    courtyard = make_box(
        courtyard_x,
        courtyard_y,
        courtyard_width,
        courtyard_depth,
        -1.0,
        70.0
    )

    push!(cutters, courtyard)

    # Carve the monumental entrance
    entrance_width = rand(rng, 10.0:1.0:16.0)
    entrance_height = rand(rng, 12.0:1.0:19.0)

    entrance_y =
        courtyard_y - courtyard_depth / 2 - 11.0

    push!(
        cutters,
        make_box(
            courtyard_x,
            entrance_y,
            entrance_width,
            28.0,
            -1.0,
            entrance_height
        )
    )

    # Carve a large roof terrace
    terrace_x = -side * rand(rng, 20.0:1.0:28.0)
    terrace_y = rand(rng, 9.0:1.0:18.0)

    terrace_width = rand(rng, 19.0:1.0:26.0)
    terrace_depth = rand(rng, 18.0:1.0:27.0)
    terrace_level = rand(rng, 13.0:1.0:20.0)

    push!(
        cutters,
        make_box(
            terrace_x,
            terrace_y,
            terrace_width,
            terrace_depth,
            terrace_level,
            70.0
        )
    )

    # Carve a deep vertical light slot
    slot_x = secondary_x + rand(rng, -5.0:1.0:5.0)
    slot_y = secondary_y + rand(rng, -4.0:1.0:4.0)

    slot_width = rand(rng, 3.5:0.5:6.5)
    slot_depth = rand(rng, 16.0:1.0:25.0)
    slot_bottom = rand(rng, 11.0:1.0:18.0)

    push!(
        cutters,
        make_box(
            slot_x,
            slot_y,
            slot_width,
            slot_depth,
            slot_bottom,
            70.0
        )
    )

    # Generate one optional lateral recess
    if composition == 2 || composition == 4

        push!(
            cutters,
            make_box(
                side * 30.0,
                rand(rng, -8.0:1.0:4.0),
                rand(rng, 15.0:1.0:22.0),
                rand(rng, 19.0:1.0:27.0),
                -1.0,
                rand(rng, 12.0:1.0:19.0)
            )
        )
    end

    return (
        additions=additions,
        cutters=cutters,
        courtyard=courtyard,
        name=names[composition]
    )
end

# Generate the CSG coordinate partitions
function csg_partition(design)

    all_boxes = vcat(
        design.additions,
        design.cutters
    )

    xs = sort(unique(vcat(
        [b.xmin for b in all_boxes],
        [b.xmax for b in all_boxes]
    )))

    ys = sort(unique(vcat(
        [b.ymin for b in all_boxes],
        [b.ymax for b in all_boxes]
    )))

    zs = sort(unique(vcat(
        [b.zmin for b in all_boxes],
        [b.zmax for b in all_boxes]
    )))

    nx = length(xs) - 1
    ny = length(ys) - 1
    nz = length(zs) - 1

    occupied = falses(nx, ny, nz)

    volume = 0.0

    # Evaluate each partition cell
    for i in 1:nx, j in 1:ny, k in 1:nz

        cx = (xs[i] + xs[i+1]) / 2
        cy = (ys[j] + ys[j+1]) / 2
        cz = (zs[k] + zs[k+1]) / 2

        occupied[i, j, k] = inside_solid(
            cx, cy, cz,
            design.additions,
            design.cutters
        )

        if occupied[i, j, k]

            volume +=
                (xs[i+1] - xs[i]) *
                    (ys[j+1] - ys[j]) *
                    (zs[k+1] - zs[k])
        end
    end

    return (
        xs=xs,
        ys=ys,
        zs=zs,
        occupied=occupied,
        volume=volume
    )
end

# Subdivide a building face into analytical patches
function add_surface_patches!(
    geo,
    centers,
    normals,
    areas,
    a, b, c, d,
    normal
)

    edge_u = sqrt(sum(
        (Float64(b[i]) - Float64(a[i]))^2
        for i in 1:3
    ))

    edge_v = sqrt(sum(
        (Float64(d[i]) - Float64(a[i]))^2
        for i in 1:3
    ))

    nu = max(1, ceil(Int, edge_u / SURFACE_STEP))
    nv = max(1, ceil(Int, edge_v / SURFACE_STEP))

    function point_at(u, v)

        return Point3f(
            a[1] + u * (b[1] - a[1]) +
                v * (d[1] - a[1]),
            a[2] + u * (b[2] - a[2]) +
                v * (d[2] - a[2]),
            a[3] + u * (b[3] - a[3]) +
                v * (d[3] - a[3])
        )
    end

    patch_area = edge_u * edge_v / (nu * nv)

    for i in 1:nu, j in 1:nv

        u1 = (i - 1) / nu
        u2 = i / nu

        v1 = (j - 1) / nv
        v2 = j / nv

        p1 = point_at(u1, v1)
        p2 = point_at(u2, v1)
        p3 = point_at(u2, v2)
        p4 = point_at(u1, v2)

        add_quad!(geo, p1, p2, p3, p4)

        center = point_at(
            (u1 + u2) / 2,
            (v1 + v2) / 2
        )

        push!(
            centers,
            (
                Float64(center[1]),
                Float64(center[2]),
                Float64(center[3])
            )
        )

        push!(normals, normal)
        push!(areas, patch_area)
    end

    return nothing
end

# Generate the external CSG building surfaces
function generate_building_surfaces(design)

    partition = csg_partition(design)

    xs = partition.xs
    ys = partition.ys
    zs = partition.zs

    occupied = partition.occupied

    nx, ny, nz = size(occupied)

    geo = new_geometry()

    centers = NTuple{3,Float64}[]
    normals = NTuple{3,Float64}[]
    areas = Float64[]

    p(x, y, z) = Point3f(x, y, z)

    # Construct outward-facing boundary surfaces
    for i in 1:nx, j in 1:ny, k in 1:nz

        if !occupied[i, j, k]
            continue
        end

        x1, x2 = xs[i], xs[i+1]
        y1, y2 = ys[j], ys[j+1]
        z1, z2 = zs[k], zs[k+1]

        # Negative X face
        if i == 1 || !occupied[i-1, j, k]

            add_surface_patches!(
                geo, centers, normals, areas,
                p(x1, y1, z1),
                p(x1, y1, z2),
                p(x1, y2, z2),
                p(x1, y2, z1),
                (-1.0, 0.0, 0.0)
            )
        end

        # Positive X face
        if i == nx || !occupied[i+1, j, k]

            add_surface_patches!(
                geo, centers, normals, areas,
                p(x2, y1, z1),
                p(x2, y2, z1),
                p(x2, y2, z2),
                p(x2, y1, z2),
                (1.0, 0.0, 0.0)
            )
        end

        # Negative Y face
        if j == 1 || !occupied[i, j-1, k]

            add_surface_patches!(
                geo, centers, normals, areas,
                p(x1, y1, z1),
                p(x2, y1, z1),
                p(x2, y1, z2),
                p(x1, y1, z2),
                (0.0, -1.0, 0.0)
            )
        end

        # Positive Y face
        if j == ny || !occupied[i, j+1, k]

            add_surface_patches!(
                geo, centers, normals, areas,
                p(x2, y2, z1),
                p(x1, y2, z1),
                p(x1, y2, z2),
                p(x2, y2, z2),
                (0.0, 1.0, 0.0)
            )
        end

        # Bottom face
        if k == 1 || !occupied[i, j, k-1]

            add_surface_patches!(
                geo, centers, normals, areas,
                p(x1, y2, z1),
                p(x2, y2, z1),
                p(x2, y1, z1),
                p(x1, y1, z1),
                (0.0, 0.0, -1.0)
            )
        end

        # Top face
        if k == nz || !occupied[i, j, k+1]

            add_surface_patches!(
                geo, centers, normals, areas,
                p(x1, y1, z2),
                p(x2, y1, z2),
                p(x2, y2, z2),
                p(x1, y2, z2),
                (0.0, 0.0, 1.0)
            )
        end
    end

    return (
        mesh=build_mesh(geo),
        centers=centers,
        normals=normals,
        areas=areas,
        volume=partition.volume
    )
end


# Extract architectural edges from the CSG boundary
function generate_architectural_edges(design)

    partition = csg_partition(design)

    xs = partition.xs
    ys = partition.ys
    zs = partition.zs

    occupied = partition.occupied

    nx, ny, nz = size(occupied)

    # Store unique geometric edges
    edge_set = Set{
        Tuple{NTuple{3,Float64},NTuple{3,Float64}}
    }()

    # Register each edge only once
    function add_edge!(a, b)

        p1 = (
            Float64(a[1]),
            Float64(a[2]),
            Float64(a[3])
        )

        p2 = (
            Float64(b[1]),
            Float64(b[2]),
            Float64(b[3])
        )

        if p1 == p2
            return nothing
        end

        edge = isless(p1, p2) ?
               (p1, p2) : (p2, p1)

        push!(edge_set, edge)

        return nothing
    end

    # Register the four boundary edges of a face
    function add_face_edges!(a, b, c, d)

        add_edge!(a, b)
        add_edge!(b, c)
        add_edge!(c, d)
        add_edge!(d, a)

        return nothing
    end

    # Process every occupied CSG cell
    for i in 1:nx, j in 1:ny, k in 1:nz

        if !occupied[i, j, k]
            continue
        end

        x1, x2 = xs[i], xs[i+1]
        y1, y2 = ys[j], ys[j+1]
        z1, z2 = zs[k], zs[k+1]

        p(x, y, z) = (x, y, z)

        # Negative X boundary
        if i == 1 || !occupied[i-1, j, k]

            add_face_edges!(
                p(x1, y1, z1), p(x1, y1, z2),
                p(x1, y2, z2), p(x1, y2, z1)
            )
        end

        # Positive X boundary
        if i == nx || !occupied[i+1, j, k]

            add_face_edges!(
                p(x2, y1, z1), p(x2, y2, z1),
                p(x2, y2, z2), p(x2, y1, z2)
            )
        end

        # Negative Y boundary
        if j == 1 || !occupied[i, j-1, k]

            add_face_edges!(
                p(x1, y1, z1), p(x2, y1, z1),
                p(x2, y1, z2), p(x1, y1, z2)
            )
        end

        # Positive Y boundary
        if j == ny || !occupied[i, j+1, k]

            add_face_edges!(
                p(x2, y2, z1), p(x1, y2, z1),
                p(x1, y2, z2), p(x2, y2, z2)
            )
        end

        # Bottom boundary
        if k == 1 || !occupied[i, j, k-1]

            add_face_edges!(
                p(x1, y2, z1), p(x2, y2, z1),
                p(x2, y1, z1), p(x1, y1, z1)
            )
        end

        # Top boundary
        if k == nz || !occupied[i, j, k+1]

            add_face_edges!(
                p(x1, y1, z2), p(x2, y1, z2),
                p(x2, y2, z2), p(x1, y2, z2)
            )
        end
    end

    # Convert unique edges into line segments
    segments = Point3f[]

    for (a, b) in edge_set

        push!(segments, Point3f(a...))
        push!(segments, Point3f(b...))
    end

    return segments
end


# Calculate approximate solar position
function solar_position(datetime)

    day_number = dayofyear(datetime)

    year_length =
        isleapyear(year(datetime)) ? 366 : 365

    local_hour =
        Dates.hour(datetime) +
            Dates.minute(datetime) / 60

    gamma = 2π / year_length * (
        day_number - 1 +
            (local_hour - 12) / 24
    )

    equation_of_time = 229.18 * (
        0.000075 +
            0.001868 * cos(gamma) -
            0.032077 * sin(gamma) -
            0.014615 * cos(2 * gamma) -
            0.040849 * sin(2 * gamma)
    )

    declination =
        0.006918 -
            0.399912 * cos(gamma) +
            0.070257 * sin(gamma) -
            0.006758 * cos(2 * gamma) +
            0.000907 * sin(2 * gamma) -
            0.002697 * cos(3 * gamma) +
            0.00148 * sin(3 * gamma)

    solar_minutes =
        local_hour * 60 +
            equation_of_time +
            4 * LONGITUDE -
            60 * UTC_OFFSET

    hour_angle = deg2rad(
        solar_minutes / 4 - 180
    )

    lat = deg2rad(LATITUDE)

    sin_elevation =
        sin(lat) * sin(declination) +
            cos(lat) * cos(declination) *
            cos(hour_angle)

    elevation = rad2deg(
        asin(clamp(sin_elevation, -1.0, 1.0))
    )

    azimuth = mod(
        rad2deg(
            atan(
                sin(hour_angle),
                cos(hour_angle) * sin(lat) -
                    tan(declination) * cos(lat)
            )
        ) + 180,
        360
    )

    return azimuth, elevation
end

# Convert solar angles to ENU coordinates
# X = East, Y = North, Z = Up
function sun_vector(azimuth, elevation)

    az = deg2rad(azimuth)
    el = deg2rad(elevation)

    return (
        cos(el) * sin(az),
        cos(el) * cos(az),
        sin(el)
    )
end

# Calculate ray intersection with a box
function ray_box_interval(origin, direction, box)

    lower = (box.xmin, box.ymin, box.zmin)
    upper = (box.xmax, box.ymax, box.zmax)

    tmin = 0.0
    tmax = Inf

    for axis in 1:3

        o = origin[axis]
        d = direction[axis]

        if abs(d) < 1.0e-10

            if o < lower[axis] || o > upper[axis]
                return nothing
            end

        else

            t1 = (lower[axis] - o) / d
            t2 = (upper[axis] - o) / d

            tmin = max(tmin, min(t1, t2))
            tmax = min(tmax, max(t1, t2))

            if tmax <= tmin
                return nothing
            end
        end
    end

    return (tmin, tmax)
end

# Test whether a solar ray is blocked by the CSG solid
function ray_blocked(origin, direction, design)

    events = Float64[0.0]

    has_addition = false

    # Collect additive volume intersections
    for box in design.additions

        hit = ray_box_interval(
            origin,
            direction,
            box
        )

        if hit !== nothing

            has_addition = true

            push!(
                events,
                hit[1],
                hit[2]
            )
        end
    end

    if !has_addition
        return false
    end

    # Include subtraction boundaries
    for box in design.cutters

        hit = ray_box_interval(
            origin,
            direction,
            box
        )

        if hit !== nothing

            push!(
                events,
                hit[1],
                hit[2]
            )
        end
    end

    sort!(events)
    unique!(events)

    # Test every interval between successive events
    for i in 1:(length(events)-1)

        t1 = events[i]
        t2 = events[i+1]

        if t2 - t1 <= 1.0e-7
            continue
        end

        t = (t1 + t2) / 2

        x = origin[1] + direction[1] * t
        y = origin[2] + direction[2] * t
        z = origin[3] + direction[3] * t

        if inside_solid(
            x, y, z,
            design.additions,
            design.cutters
        )
            return true
        end
    end

    return false
end

# Check direct sunlight on a ground point
function ground_receives_sun(x, y, direction, design)

    if direction[3] <= 0.0
        return false
    end

    origin = (x, y, 0.08)

    return !ray_blocked(
        origin,
        direction,
        design
    )
end

# Check direct sunlight on a building surface
function surface_receives_sun(
    center,
    normal,
    direction,
    design
)

    if direction[3] <= 0.0
        return false
    end

    incidence =
        normal[1] * direction[1] +
            normal[2] * direction[2] +
            normal[3] * direction[3]

    if incidence <= 1.0e-6
        return false
    end

    origin = (
        center[1] + normal[1] * 0.08,
        center[2] + normal[2] * 0.08,
        center[3] + normal[3] * 0.08
    )

    return !ray_blocked(
        origin,
        direction,
        design
    )
end

# Generate the analytical ground mesh
function generate_ground_grid()

    geo = new_geometry()

    centers = NTuple{2,Float64}[]

    step = GROUND_STEP

    for x in GROUND_MIN:step:(GROUND_MAX-step)
        for y in GROUND_MIN:step:(GROUND_MAX-step)

            push!(
                centers,
                (x + step / 2, y + step / 2)
            )

            add_quad!(
                geo,
                Point3f(x, y, -0.15),
                Point3f(x + step, y, -0.15),
                Point3f(x + step, y + step, -0.15),
                Point3f(x, y + step, -0.15)
            )
        end
    end

    return (
        mesh=build_mesh(geo),
        centers=centers
    )
end

# Generate sun directions at fixed time intervals
function daily_sun_vectors(date)

    vectors = NTuple{3,Float64}[]

    start_minutes = SUN_START_HOUR * 60
    end_minutes = SUN_END_HOUR * 60

    time_range = range(
        start_minutes,
        stop=end_minutes - SUN_INTERVAL,
        step=SUN_INTERVAL
    )

    for minutes in time_range

        midpoint = minutes + SUN_INTERVAL ÷ 2

        datetime = DateTime(date) + Minute(midpoint)

        azimuth, elevation = solar_position(datetime)

        if elevation > 0.0

            push!(
                vectors,
                sun_vector(azimuth, elevation)
            )
        end
    end

    return vectors
end

# Calculate direct sun hours on ground samples
function calculate_ground_hours(design, date, centers)

    values = zeros(Float64, length(centers))

    directions = daily_sun_vectors(date)
    dt = SUN_INTERVAL / 60

    for (i, center) in enumerate(centers)

        x, y = center

        # Mark building footprints as invalid analysis cells
        if inside_solid(
            x, y, 0.05,
            design.additions,
            design.cutters
        )
            values[i] = NaN
            continue
        end

        for direction in directions

            if ground_receives_sun(
                x, y,
                direction,
                design
            )
                values[i] += dt
            end
        end
    end

    return values
end

# Calculate direct sun hours on building surfaces
function calculate_surface_hours(design, date, surfaces)

    values = zeros(
        Float64,
        length(surfaces.centers)
    )

    directions = daily_sun_vectors(date)
    dt = SUN_INTERVAL / 60

    for i in eachindex(surfaces.centers)

        center = surfaces.centers[i]
        normal = surfaces.normals[i]

        # Exclude downward-facing building surfaces
        if normal[3] < -0.5
            values[i] = NaN
            continue
        end

        for direction in directions

            if surface_receives_sun(
                center,
                normal,
                direction,
                design
            )
                values[i] += dt
            end
        end
    end

    return values
end

# Convert sun hours into a heatmap color
function heatmap_color(hours)

    if !isfinite(hours)
        return NEUTRAL_GROUND
    end

    t = Float32(clamp(
        hours / MAX_SUN_HOURS,
        0.0,
        1.0
    ))

    position = t * 4f0

    index = clamp(
        floor(Int, position) + 1,
        1, 4
    )

    fraction = clamp(
        position - Float32(index - 1),
        0f0,
        1f0
    )

    a = SOLAR_PALETTE[index]
    b = SOLAR_PALETTE[index+1]

    return RGBf(
        (1f0 - fraction) * a.r + fraction * b.r,
        (1f0 - fraction) * a.g + fraction * b.g,
        (1f0 - fraction) * a.b + fraction * b.b
    )
end

# Expand each analytical color to four vertices
function expand_colors(cell_colors)

    result = RGBf[]

    sizehint!(
        result,
        4 * length(cell_colors)
    )

    for color in cell_colors

        append!(
            result,
            (color, color, color, color)
        )
    end

    return result
end

# Calculate instantaneous ground shadow colors
function shadow_ground_colors(
    design,
    centers,
    azimuth,
    elevation
)

    direction = sun_vector(azimuth, elevation)

    colors = RGBf[]

    for (x, y) in centers

        exposed = ground_receives_sun(
            x, y,
            direction,
            design
        )

        push!(
            colors,
            exposed ? SUNLIT_COLOR : SHADOW_COLOR
        )
    end

    return colors
end

# Calculate courtyard daily solar statistics
function courtyard_statistics(design, date)

    courtyard = design.courtyard
    directions = daily_sun_vectors(date)

    values = Float64[]
    dt = SUN_INTERVAL / 60

    for x in range(
        courtyard.xmin + 1,
        courtyard.xmax - 1,
        length=9
    )
        for y in range(
            courtyard.ymin + 1,
            courtyard.ymax - 1,
            length=9
        )

            if inside_solid(
                x, y, 0.05,
                design.additions,
                design.cutters
            )
                continue
            end

            hours = 0.0

            for direction in directions

                if ground_receives_sun(
                    x, y,
                    direction,
                    design
                )
                    hours += dt
                end
            end

            push!(values, hours)
        end
    end

    if isempty(values)

        return (
            average=0.0,
            minimum=0.0,
            maximum=0.0,
            shaded_percent=0.0
        )
    end

    return (
        average=mean(values),
        minimum=minimum(values),
        maximum=maximum(values),
        shaded_percent=
        100 * count(h -> h < 3.0, values) /
            length(values)
    )
end

# Calculate area-weighted building solar statistics
function surface_statistics(surfaces, hours)

    valid = [
        i for i in eachindex(hours)
              if isfinite(hours[i]) &&
            surfaces.normals[i][3] > -0.5
    ]

    if isempty(valid)

        return (
            average=0.0,
            minimum=0.0,
            maximum=0.0,
            shaded_percent=0.0
        )
    end

    total_area = sum(
        surfaces.areas[i]
        for i in valid
    )

    average = sum(
        hours[i] * surfaces.areas[i]
        for i in valid
    ) / max(total_area, 1.0e-9)

    shaded_area = sum(
        surfaces.areas[i]
        for i in valid
        if hours[i] < 3.0
    )

    return (
        average=average,
        minimum=minimum(hours[i] for i in valid),
        maximum=maximum(hours[i] for i in valid),
        shaded_percent=
        100 * shaded_area / total_area
    )
end

# Calculate the preliminary massing quality index
function evaluate_design(design, surfaces, courtyard_stats)

    original_design = (
        additions=design.additions,
        cutters=BoxVolume[]
    )

    original_volume =
        csg_partition(original_design).volume

    void_ratio = clamp(
        1 - surfaces.volume / max(original_volume, 1.0),
        0.0,
        1.0
    )

    volumes = [
        (b.xmax - b.xmin) *
            (b.ymax - b.ymin) *
            (b.zmax - b.zmin)
        for b in design.additions
    ]

    dominance = maximum(volumes) / sum(volumes)

    void_score = 100 * clamp(
        1 - abs(void_ratio - 0.25) / 0.25,
        0.0,
        1.0
    )

    dominance_score = 100 * clamp(
        1 - abs(dominance - 0.50) / 0.50,
        0.0,
        1.0
    )

    sun_score = 100 * clamp(
        1 - abs(courtyard_stats.average - 5.0) / 5.0,
        0.0,
        1.0
    )

    score =
        0.35 * void_score +
            0.30 * dominance_score +
            0.35 * sun_score

    return (
        score=score,
        void_ratio=void_ratio,
        dominance=dominance,
        volume=surfaces.volume
    )
end

# Create the geographic compass
function create_compass!(ax)

    ox, oy = -56.0, -55.0
    oz = 0.20f0

    radius = 5.0

    lines!(
        ax,
        Point3f[
            Point3f(ox - radius, oy, oz),
            Point3f(ox + radius, oy, oz)
        ],
        color=:gray35,
        linewidth=2
    )

    lines!(
        ax,
        Point3f[
            Point3f(ox, oy - radius, oz),
            Point3f(ox, oy + radius, oz)
        ],
        color=:gray35,
        linewidth=2
    )

    lines!(
        ax,
        Point3f[
            Point3f(ox, oy, oz),
            Point3f(ox, oy + radius, oz)
        ],
        color=:darkred,
        linewidth=4
    )

    for (letter, dx, dy) in (
        ("N", 0.0, 7.0),
        ("E", 7.0, 0.0),
        ("S", 0.0, -7.0),
        ("W", -7.0, 0.0)
    )

        text!(
            ax,
            letter,
            position=Point3f(
                ox + dx,
                oy + dy,
                oz + 0.1
            ),
            color=:black,
            fontsize=16,
            align=(:center, :center)
        )
    end

    return nothing
end

# Initialize the application figure
fig = Figure(
    size=(1900, 960),
    backgroundcolor=:white,
    figure_padding=8,
    fontsize=12
)

# Allocate width between viewport and dashboard
colsize!(fig.layout, 1, Relative(0.65))
colgap!(fig.layout, 10)

# Create the 3D architectural viewport
ax = Axis3(
    fig[1, 1],
    aspect=:data,
    viewmode=:fitzoom,
    azimuth=0.34π,
    elevation=0.25π,
    perspectiveness=0.18,
    protrusions=0,
    backgroundcolor=RGBf(0.97, 0.97, 0.97)
)

hidedecorations!(ax)
hidespines!(ax)

# Initialize the lighting environment
set_ambient_light!(
    ax,
    RGBf(0.35, 0.35, 0.36)
)

set_directional_light!(
    ax;
    color=RGBf(1.0, 0.96, 0.89),
    direction=Vec3f(-0.5, -0.5, -0.7),
    camera_relative=false
)

# Generate the initial design
initial_design = generate_architecture(INITIAL_SEED)

initial_surfaces = generate_building_surfaces(
    initial_design
)

ground_grid = generate_ground_grid()

# Calculate initial daily solar exposure
initial_ground_hours = calculate_ground_hours(
    initial_design,
    INITIAL_DATE,
    ground_grid.centers
)

initial_surface_hours = calculate_surface_hours(
    initial_design,
    INITIAL_DATE,
    initial_surfaces
)

initial_courtyard_stats = courtyard_statistics(
    initial_design,
    INITIAL_DATE
)

initial_surface_stats = surface_statistics(
    initial_surfaces,
    initial_surface_hours
)

initial_scores = evaluate_design(
    initial_design,
    initial_surfaces,
    initial_courtyard_stats
)

initial_datetime =
    DateTime(INITIAL_DATE) +
        Hour(INITIAL_HOUR) +
        Minute(INITIAL_MINUTE)

initial_azimuth, initial_elevation =
    solar_position(initial_datetime)

# Store current architectural state
current_design = Ref(initial_design)
current_surfaces = Ref(initial_surfaces)
current_date = Ref(INITIAL_DATE)

current_ground_hours = Ref(initial_ground_hours)
current_surface_hours = Ref(initial_surface_hours)

current_seed = Observable(INITIAL_SEED)
current_name = Observable(initial_design.name)

current_courtyard_stats =
    Observable(initial_courtyard_stats)

current_surface_stats =
    Observable(initial_surface_stats)

current_scores = Observable(initial_scores)

solar_azimuth_obs = Observable(initial_azimuth)
solar_elevation_obs = Observable(initial_elevation)

# Define the available analysis modes
analysis_mode = Ref(:combined)
camera_mode = Ref(:massing)

analysis_label = Observable(
    "Combined Building + Ground Sun Hours"
)

# Initialize geometry observables
building_mesh_obs = Observable(initial_surfaces.mesh)

# Initialize ground and building heatmap colors
initial_ground_colors = [
    heatmap_color(h)
    for h in initial_ground_hours
]

initial_surface_colors = [
    heatmap_color(h)
    for h in initial_surface_hours
]

ground_colors_obs = Observable(
    expand_colors(initial_ground_colors)
)

surface_colors_obs = Observable(
    expand_colors(initial_surface_colors)
)

# Control the two architectural rendering modes
concrete_visible = Observable(false)
surface_visible = Observable(true)

# Render the ground analysis
mesh!(
    ax,
    ground_grid.mesh,
    color=ground_colors_obs,
    shading=false
)

# Render the concrete building
mesh!(
    ax,
    building_mesh_obs,
    color=CONCRETE_COLOR,
    shading=true,
    diffuse=CONCRETE_DIFFUSE,
    specular=CONCRETE_SPECULAR,
    shininess=CONCRETE_SHININESS,
    visible=concrete_visible
)

# Render the building surface heatmap
mesh!(
    ax,
    building_mesh_obs,
    color=surface_colors_obs,
    shading=false,
    visible=surface_visible
)


# Generate architectural edge geometry
initial_edges = generate_architectural_edges(
    initial_design
)

# Store edge geometry for interactive updates
edges_obs = Observable(initial_edges)

# Control architectural edge visibility
edges_visible = Observable(true)

# Display architectural boundary lines
linesegments!(
    ax,
    edges_obs,
    color=RGBf(0.18, 0.20, 0.22),
    linewidth=1.5,
    visible=edges_visible
)


# Display geographic orientation
create_compass!(ax)

# Define architectural framing modes
function fit_building!(design; mode=:massing)

    boxes = design.additions

    xmin = minimum(b.xmin for b in boxes)
    xmax = maximum(b.xmax for b in boxes)

    ymin = minimum(b.ymin for b in boxes)
    ymax = maximum(b.ymax for b in boxes)

    zmax = maximum(b.zmax for b in boxes)

    if mode == :massing

        margin = 5.0

        limits!(
            ax,
            xmin - margin, xmax + margin,
            ymin - margin, ymax + margin,
            -1.0, zmax + 3.0
        )

    elseif mode == :solar

        limits!(
            ax,
            -78.0, 78.0,
            -78.0, 78.0,
            -2.0,
            max(zmax + 5.0, 48.0)
        )

    else

        limits!(
            ax,
            -59.0, 59.0,
            -59.0, 59.0,
            -2.0,
            zmax + 5.0
        )
    end

    return nothing
end

# Create a compact, always-visible dashboard on the right
# Two columns reduce height without hiding any controls
panel = GridLayout()
fig[1, 2] = panel
rowgap!(panel, 7)
colgap!(panel, 12)

# Display the application identity above both columns
Label(
    panel[1, 1:2],
    "LIGHT SCULPTED MASS",
    fontsize=19,
    font=:bold,
    halign=:left
)

Label(
    panel[2, 1:2],
    "BANDUNG | INTEGRATED SOLAR ANALYSIS",
    fontsize=11,
    color=:gray45,
    halign=:left
)

# Split controls into two independent compact columns
left_panel = GridLayout()
right_panel = GridLayout()
panel[3, 1] = left_panel
panel[3, 2] = right_panel

rowgap!(left_panel, 6)
rowgap!(right_panel, 6)
colgap!(left_panel, 7)
colgap!(right_panel, 7)

# Use equal dashboard column widths
colsize!(panel, 1, Relative(0.49))
colsize!(panel, 2, Relative(0.49))

# Keep the control groups at the top of their columns
# All original callbacks continue using the same widget names

# Generative design controls
Label(left_panel[1, 1:2], "GENERATIVE DESIGN",
    fontsize=13, font=:bold, halign=:left)

Label(left_panel[2, 1], "Seed", halign=:left)
seed_input = Textbox(
    left_panel[2, 2],
    placeholder="1-10000",
    validator=s -> begin
        n = tryparse(Int, strip(s))
        n !== nothing && 1 <= n <= 10000
    end,
    width=125,
    height=28
)

generate_button = Button(left_panel[3, 1],
    label="Generate New", height=30, fontsize=11)
reproduce_button = Button(left_panel[3, 2],
    label="Reproduce Seed", height=30, fontsize=11)

Label(left_panel[4, 1:2],
    lift((s, n) -> "Seed $s | $n", current_seed, current_name),
    fontsize=11, halign=:left)

# Bandung date and time controls
Label(left_panel[6, 1:2], "SOLAR SIMULATION",
    fontsize=13, font=:bold, halign=:left)

Label(left_panel[7, 1], "Date", halign=:left)
date_input = Textbox(
    left_panel[7, 2],
    placeholder="YYYY-MM-DD",
    validator=s -> begin
        try
            Date(strip(s), dateformat"yyyy-mm-dd")
            true
        catch
            false
        end
    end,
    width=125,
    height=28
)

apply_date_button = Button(left_panel[8, 1],
    label="Apply Date", height=30, fontsize=11)
date_label = Observable(string(INITIAL_DATE))
Label(left_panel[8, 2], date_label,
    fontsize=11, halign=:left)

Label(left_panel[9, 1], "Hour", halign=:left)
hour_slider = Slider(left_panel[9, 2],
    range=0:23, startvalue=INITIAL_HOUR)

Label(left_panel[10, 1], "Minute", halign=:left)
minute_slider = Slider(left_panel[10, 2],
    range=0:5:55, startvalue=INITIAL_MINUTE)

Label(left_panel[11, 1:2],
    lift(
        (h, m) -> "Time: " * lpad(string(h), 2, '0') * ":" *
            lpad(string(m), 2, '0') * " WIB",
        hour_slider.value, minute_slider.value
    ),
    fontsize=11, halign=:left
)

# Place all time presets on one compact row
time_controls = GridLayout()
left_panel[12, 1:2] = time_controls
colgap!(time_controls, 4)
morning_button = Button(time_controls[1, 1],
    label="09:00", height=28, fontsize=11)
noon_button = Button(time_controls[1, 2],
    label="12:00", height=28, fontsize=11)
afternoon_button = Button(time_controls[1, 3],
    label="15:00", height=28, fontsize=11)

# Camera controls remain visible without scrolling
Label(left_panel[14, 1:2], "VIEW CONTROLS",
    fontsize=13, font=:bold, halign=:left)

camera_controls = GridLayout()
left_panel[15, 1:2] = camera_controls
rowgap!(camera_controls, 4)
colgap!(camera_controls, 5)

massing_button = Button(camera_controls[1, 1],
    label="Massing", height=29, fontsize=11)
solar_button = Button(camera_controls[1, 2],
    label="Solar View", height=29, fontsize=11)
top_button = Button(camera_controls[2, 1],
    label="Top View", height=29, fontsize=11)
fit_button = Button(camera_controls[2, 2],
    label="Fit Building", height=29, fontsize=11)

# Architectural edge visibility
edge_button = Button(left_panel[16, 1:2],
    label="Show / Hide Edges", height=29, fontsize=11)
on(edge_button.clicks) do _
    edges_visible[] = !edges_visible[]
end

# Right column: analysis mode controls
Label(right_panel[1, 1:2], "SOLAR ANALYSIS",
    fontsize=13, font=:bold, halign=:left)

analysis_controls = GridLayout()
right_panel[2, 1:2] = analysis_controls
rowgap!(analysis_controls, 4)
colgap!(analysis_controls, 5)
shadow_button = Button(analysis_controls[1, 1],
    label="Shadow", height=29, fontsize=11)
ground_button = Button(analysis_controls[1, 2],
    label="Ground Hours", height=29, fontsize=11)
building_button = Button(analysis_controls[2, 1],
    label="Building Hours", height=29, fontsize=11)
combined_button = Button(analysis_controls[2, 2],
    label="Combined Hours", height=29, fontsize=11)

Label(right_panel[3, 1:2], analysis_label,
    fontsize=10, halign=:left)

# Five-color direct sun hours legend
legend_grid = GridLayout()
right_panel[4, 1:2] = legend_grid
colgap!(legend_grid, 2)
for i in 1:5
    Box(legend_grid[1, i], color=SOLAR_PALETTE[i], height=12)
end
Label(right_panel[5, 1:2],
    "0 h     3.5 h     7 h     10.5 h     14 h",
    fontsize=10, halign=:left)

# Solar orientation and exposure summary
Label(right_panel[7, 1:2], "SOLAR POSITION",
    fontsize=13, font=:bold, halign=:left)
Label(right_panel[8, 1:2],
    lift((a, e) ->
        "Az $(round(a, digits=1)) deg | El $(round(e, digits=1)) deg",
        solar_azimuth_obs, solar_elevation_obs
    ),
    fontsize=11, halign=:left)

Label(right_panel[10, 1:2], "SOLAR PERFORMANCE",
    fontsize=13, font=:bold, halign=:left)

Label(right_panel[11, 1], "Courtyard Average", fontsize=11)
Label(right_panel[11, 2],
    lift(s -> "$(round(s.average, digits=2)) h", current_courtyard_stats),
    fontsize=11)
Label(right_panel[12, 1], "Building Average", fontsize=11)
Label(right_panel[12, 2],
    lift(s -> "$(round(s.average, digits=2)) h", current_surface_stats),
    fontsize=11)
Label(right_panel[13, 1], "Building Min / Max", fontsize=11)
Label(right_panel[13, 2],
    lift(s -> "$(round(s.minimum, digits=1)) / $(round(s.maximum, digits=1)) h",
        current_surface_stats),
    fontsize=11)
Label(right_panel[14, 1], "Building Below 3h", fontsize=11)
Label(right_panel[14, 2],
    lift(s -> "$(round(s.shaded_percent, digits=1))%", current_surface_stats),
    fontsize=11)

# Architectural quality metrics
Label(right_panel[16, 1:2], "DESIGN EVALUATION",
    fontsize=13, font=:bold, halign=:left)
Label(right_panel[17, 1], "AMQI", fontsize=11)
Label(right_panel[17, 2],
    lift(s -> "$(round(s.score, digits=1)) / 100", current_scores),
    fontsize=11)
Label(right_panel[18, 1], "Solid-Void Ratio", fontsize=11)
Label(right_panel[18, 2],
    lift(s -> "$(round(s.void_ratio * 100, digits=1))%", current_scores),
    fontsize=11)

# Read the current simulation datetime
function simulation_datetime()

    return DateTime(current_date[]) +
        Hour(hour_slider.value[]) +
        Minute(minute_slider.value[])
end

# Update the directional sunlight
function update_surface_light!(azimuth, elevation)

    sx, sy, sz = sun_vector(
        azimuth,
        elevation
    )

    direction = Vec3f(
        Float32(-sx),
        Float32(-sy),
        Float32(-sz)
    )

    intensity =
        elevation > 0.0 ? 1f0 : 0f0

    set_directional_light!(
        ax;
        color=RGBf(
            intensity,
            intensity * 0.96f0,
            intensity * 0.89f0
        ),
        direction=direction,
        camera_relative=false
    )

    return nothing
end

# Update the selected analysis visualization
function update_analysis_display!()

    design = current_design[]

    if analysis_mode[] == :shadow

        # Show instantaneous ground shadows
        ground_colors = shadow_ground_colors(
            design,
            ground_grid.centers,
            solar_azimuth_obs[],
            solar_elevation_obs[]
        )

        ground_colors_obs[] =
            expand_colors(ground_colors)

        concrete_visible[] = true
        surface_visible[] = false

        analysis_label[] = "Instantaneous Shadow Study"

    elseif analysis_mode[] == :ground

        # Show ground sun hours only
        ground_colors = [
            heatmap_color(h)
            for h in current_ground_hours[]
        ]

        ground_colors_obs[] =
            expand_colors(ground_colors)

        concrete_visible[] = true
        surface_visible[] = false

        analysis_label[] = "Daily Ground Sun Hours"

    elseif analysis_mode[] == :building

        # Show surface sun hours with a neutral ground
        ground_colors_obs[] = expand_colors(
            fill(
                NEUTRAL_GROUND,
                length(ground_grid.centers)
            )
        )

        surface_colors = [
            heatmap_color(h)
            for h in current_surface_hours[]
        ]

        surface_colors_obs[] =
            expand_colors(surface_colors)

        concrete_visible[] = false
        surface_visible[] = true

        analysis_label[] = "Building Surface Sun Hours"

    elseif analysis_mode[] == :combined

        # Show sun hours on both building and ground
        ground_colors = [
            heatmap_color(h)
            for h in current_ground_hours[]
        ]

        surface_colors = [
            heatmap_color(h)
            for h in current_surface_hours[]
        ]

        ground_colors_obs[] =
            expand_colors(ground_colors)

        surface_colors_obs[] =
            expand_colors(surface_colors)

        concrete_visible[] = false
        surface_visible[] = true

        analysis_label[] = "Combined Building + Ground Sun Hours"
    end

    return nothing
end

# Update the instantaneous solar position
function update_solar_time!()

    datetime = simulation_datetime()

    azimuth, elevation = solar_position(datetime)

    solar_azimuth_obs[] = azimuth
    solar_elevation_obs[] = elevation

    update_surface_light!(
        azimuth,
        elevation
    )

    update_analysis_display!()

    return nothing
end

# Recalculate daily solar performance
function update_daily_analysis!()

    design = current_design[]
    surfaces = current_surfaces[]
    date = current_date[]

    # Calculate ground solar exposure
    current_ground_hours[] =
        calculate_ground_hours(
            design,
            date,
            ground_grid.centers
        )

    # Calculate building surface solar exposure
    current_surface_hours[] =
        calculate_surface_hours(
            design,
            date,
            surfaces
        )

    # Calculate courtyard statistics
    courtyard_stats =
        courtyard_statistics(design, date)

    # Calculate building surface statistics
    surface_stats =
        surface_statistics(
            surfaces,
            current_surface_hours[]
        )

    current_courtyard_stats[] = courtyard_stats
    current_surface_stats[] = surface_stats

    # Update the architectural quality index
    current_scores[] = evaluate_design(
        design,
        surfaces,
        courtyard_stats
    )

    update_solar_time!()

    return nothing
end

# Generate a new architectural design
function update_design!(seed)

    design = generate_architecture(seed)

    surfaces = generate_building_surfaces(design)

    current_design[] = design
    current_surfaces[] = surfaces

    current_seed[] = seed
    current_name[] = design.name

    building_mesh_obs[] = surfaces.mesh

    # Regenerate architectural boundaries
    edges_obs[] = generate_architectural_edges(design)

    fit_building!(
        design;
        mode=camera_mode[]
    )

    update_daily_analysis!()

    return nothing
end

# Generate a random design
on(generate_button.clicks) do _

    update_design!(rand(1:10000))
end

# Reproduce the specified seed
on(reproduce_button.clicks) do _

    raw = strip(seed_input.stored_string[])
    selected = tryparse(Int, raw)

    if selected !== nothing &&
        1 <= selected <= 10000

        update_design!(selected)

    else

        update_design!(current_seed[])
    end
end

# Apply the selected simulation date
on(apply_date_button.clicks) do _

    selected = try
        Date(
            strip(date_input.stored_string[]),
            dateformat"yyyy-mm-dd"
        )
    catch
        nothing
    end

    if selected !== nothing

        current_date[] = selected
        date_label[] = string(selected)

        update_daily_analysis!()
    end
end

# Update lighting when the time changes
onany(
    hour_slider.value,
    minute_slider.value
) do _, _

    update_solar_time!()
end

# Select the morning simulation
on(morning_button.clicks) do _

    set_close_to!(hour_slider, 9)
    set_close_to!(minute_slider, 0)
end

# Select the midday simulation
on(noon_button.clicks) do _

    set_close_to!(hour_slider, 12)
    set_close_to!(minute_slider, 0)
end

# Select the afternoon simulation
on(afternoon_button.clicks) do _

    set_close_to!(hour_slider, 15)
    set_close_to!(minute_slider, 0)
end

# Activate instantaneous shadow analysis
on(shadow_button.clicks) do _

    analysis_mode[] = :shadow
    update_analysis_display!()
end

# Activate ground sun hours analysis
on(ground_button.clicks) do _

    analysis_mode[] = :ground
    update_analysis_display!()
end

# Activate building surface sun hours analysis
on(building_button.clicks) do _

    analysis_mode[] = :building
    update_analysis_display!()
end

# Activate combined solar exposure analysis
on(combined_button.clicks) do _

    analysis_mode[] = :combined
    update_analysis_display!()
end

# Activate the architectural massing camera
on(massing_button.clicks) do _

    camera_mode[] = :massing

    ax.azimuth[] = 0.34π
    ax.elevation[] = 0.25π

    fit_building!(
        current_design[];
        mode=:massing
    )
end

# Activate the wide solar analysis camera
on(solar_button.clicks) do _

    camera_mode[] = :solar

    ax.azimuth[] = 0.34π
    ax.elevation[] = 0.31π

    fit_building!(
        current_design[];
        mode=:solar
    )
end

# Activate the top-down camera
on(top_button.clicks) do _

    camera_mode[] = :top

    ax.azimuth[] = 0.5π
    ax.elevation[] = 0.499π

    fit_building!(
        current_design[];
        mode=:top
    )
end

# Fit the current architecture to the viewport
on(fit_button.clicks) do _

    fit_building!(
        current_design[];
        mode=camera_mode[]
    )
end

# Apply the initial camera framing
fit_building!(
    initial_design;
    mode=:massing
)

# Initialize the solar simulation
update_solar_time!()

# Display the complete architectural application
display(fig)
