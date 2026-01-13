using GLMakie
using GeometryBasics

tinggi_total = 100
jumlah_kolom = 25
pusat_pinggang = 50

fig = Figure(size=(800, 800), backgroundcolor=:white)
ax = LScene(fig[1, 1])

for i in 1:jumlah_kolom
    garis_tiang = Point3f[]

    for z in 0:tinggi_total
        jarak_dari_tengah = abs(z - pusat_pinggang)
        radius = 6.0 + (jarak_dari_tengah * 0.50)
        sudut = (i / jumlah_kolom) * 2pi + (z * 0.1)
        x = radius * cos(sudut)
        y = radius * sin(sudut)
        push!(garis_tiang, Point3f(x, y, z))
    end

    lines!(ax, garis_tiang,
        color=:teal,
        linewidth=3,
        transparency=true
    )
end

display(fig)