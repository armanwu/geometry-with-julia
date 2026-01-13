using GLMakie
using GeometryBasics

posisi = Point3f[]
warna = Float64[]

for x in -2:2, y in -2:2, z in 0:20

    jarak = sqrt(x^2 + y^2)
    batas = 2.5 - (z * 0.1)

    if jarak <= batas
        push!(posisi, Point3f(x, y, z))
        push!(warna, z)
    end

end

fig = Figure(size=(600, 600))
ax = Axis3(fig[1, 1], title="Menara Voxel")

meshscatter!(ax, posisi,
    marker=Rect3f(Vec3f(-0.5), Vec3f(1)),
    color=warna,
    markersize=0.9,
    colormap=:plasma
)

display(fig)