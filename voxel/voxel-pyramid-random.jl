using GLMakie
using GeometryBasics

posisi = Point3f[]
warna = Float64[]

range_x = -10:10
range_y = -10:10

for x in range_x, y in range_y

    jarak = sqrt(x^2 + y^2)
    tinggi_dasar = 20 - jarak
    variasi = rand(-2:2)
    total_tinggi = round(Int, tinggi_dasar + variasi)

    if total_tinggi < 1
        total_tinggi = 1
    end

    for z in 0:total_tinggi
        push!(posisi, Point3f(x, y, z))

        if z == 0
            push!(warna, 0.0)
        else
            push!(warna, z)
        end
    end

end

fig = Figure(size=(800, 600))
ax = Axis3(fig[1, 1],
    aspect=:data
)

meshscatter!(ax, posisi,
    marker=Rect3f(Vec3f(-0.5, -0.5, 0), Vec3f(1, 1, 1)),
    color=warna,
    colormap=:inferno,
    markersize=0.9
)

display(fig)