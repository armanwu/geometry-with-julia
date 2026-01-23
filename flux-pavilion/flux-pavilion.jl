using GLMakie
using GeometryBasics
using Colors
using Random

fig = Figure(size=(1000, 600), backgroundcolor=:grey10)
ax = Axis3(fig[1, 1], aspect=:data, azimuth=0.4π, elevation=0.2π)
hidedecorations!(ax);
hidespines!(ax);

# Lantai
wireframe!(ax, Rect3f(Point3f(-10, -30, 0), Vec3f(120, 60, 0)),
    linewidth=0.0
)

function bikin_bangunan()
    panjang_bangunan = 100
    jumlah_ribs = 30
    resolusi_lengkung = 30

    points = Point3f[]
    faces = GLTriangleFace[]
    ribs_data = Vector{Point3f}[]

    for i in 1:jumlah_ribs
        pos_x = (i - 1) * (panjang_bangunan / jumlah_ribs)
        lebar = rand(5.0:15.0)
        tinggi = rand(4.0:20.0)
        geser_y = rand(-5.0:5.0)

        rib_points = Point3f[]
        for j in 1:resolusi_lengkung
            theta = π * (j - 1) / (resolusi_lengkung - 1)
            y = geser_y - (lebar * cos(theta))
            z = tinggi * sin(theta)

            push!(rib_points, Point3f(pos_x, y, z))
        end
        push!(ribs_data, rib_points)
    end

    idx_counter = 1
    for i in 1:(jumlah_ribs-1)
        rib_ini = ribs_data[i]
        rib_depan = ribs_data[i+1]

        for j in 1:(resolusi_lengkung-1)
            p1 = rib_ini[j]
            p2 = rib_depan[j]
            p3 = rib_depan[j+1]
            p4 = rib_ini[j+1]

            push!(points, p1, p2, p3, p4)
            push!(faces, GLTriangleFace(idx_counter, idx_counter + 1, idx_counter + 2))
            push!(faces, GLTriangleFace(idx_counter + 2, idx_counter + 3, idx_counter))
            idx_counter += 4
        end
    end

    return GeometryBasics.Mesh(points, faces)
end

mesh_bangunan = bikin_bangunan()

mesh!(ax, mesh_bangunan, color=(:teal, 0.5), transparency=true, shading=true)
wireframe!(ax, mesh_bangunan, color=(:white, 0.4), linewidth=1.0)

display(fig)