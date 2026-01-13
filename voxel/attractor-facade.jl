using GLMakie
using GeometryBasics

posisi = Point3f[]
ukuran_box = Vec3f[]
warna = Float64[]

range_x = -10:20
range_z = 0:20

magnet_x = 5
magnet_z = 10

for x in range_x, z in range_z
    y = 0
    jarak = sqrt((x - magnet_x)^2 + (z - magnet_z)^2)
    skala = 0.1 + (jarak * 0.05)

    if skala > 0.8
        skala = 0.8
    end

    push!(posisi, Point3f(x, y, z))
    push!(ukuran_box, Vec3f(skala, 0.2, skala))
    push!(warna, skala)
end

fig = Figure(size=(800, 800))
ax = Axis3(fig[1, 1], aspect=:data)

meshscatter!(ax, posisi,
    marker=Rect3f(Vec3f(-0.5, -0.5, -0.5), Vec3f(1, 1, 1)),
    markersize=ukuran_box,
    color=warna,
    colormap=:magma
)

display(fig)