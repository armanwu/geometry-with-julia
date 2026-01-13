using GLMakie
using GeometryBasics

function putar_titik(x, y, sudut_derajat)
    rad = deg2rad(sudut_derajat)
    x_baru = x * cos(rad) - y * sin(rad)
    y_baru = y * sin(rad) + y * cos(rad)
    return x_baru, y_baru
end

posisi = Point3f[]
warna = Float64[]

range_x = -5:5
range_y = -5:5
tinggi_total = 40

for z in 0:tinggi_total
    sudut_putar = z * 3

    for x in range_x, y in range_y

        if abs(x) > 2 || abs(y) > 2
            x_putar, y_putar = putar_titik(x, y, sudut_putar)
            push!(posisi, Point3f(x_putar, y_putar, z))
            push!(warna, x + y)
        end

    end

end

fig = Figure(size=(600, 800))
ax = Axis3(fig[1, 1], aspect=:data)

meshscatter!(ax, posisi,
    marker = Rect3f(Vec3f(-0.5, -0.5, 0), Vec3f(1, 1, 1)),
    color = warna,
    colormap = :viridis,
    markersize = 1.0
)

display(fig)