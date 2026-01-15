using GLMakie
using GeometryBasics
using Random
using Colors

function bikin_kristal(pusat_x, pusat_y)
    tinggi = rand(25:45)
    puncak = Point3f(pusat_x + rand(-20:20), pusat_y + rand(-20:20), tinggi)
    lebar = rand(15:25)

    alas_1 = Point3f(pusat_x + rand(-lebar:lebar), pusat_y + rand(-lebar:lebar), 0)
    alas_2 = Point3f(pusat_x + rand(-lebar:lebar), pusat_y + rand(-lebar:lebar), 0)
    alas_3 = Point3f(pusat_x + rand(-lebar:lebar), pusat_y + rand(-lebar:lebar), 0)

    points = [alas_1, alas_2, alas_3, puncak]
    faces = [
        TriangleFace(1, 2, 4), TriangleFace(2, 3, 4),
        TriangleFace(3, 1, 4), TriangleFace(1, 2, 3)
    ]
    return GeometryBasics.Mesh(points, faces)
end

fig = Figure(size=(800, 800), backgroundcolor=:white)

ax = Axis3(fig[1, 1],
    aspect=:data,
    perspectiveness=0.8,
    azimuth=0.3π,
    elevation=0.1π
)

jumlah_pecahan = 8
posisi_x = rand(-5:5, jumlah_pecahan)
posisi_y = rand(-5:5, jumlah_pecahan)

warna_palet = [
    RGBAf(0.0, 0.8, 0.9, 0.5),
    RGBAf(0.0, 0.5, 0.6, 0.5),
    RGBAf(0.2, 0.7, 0.6, 0.5),
    RGBAf(0.6, 0.65, 0.7, 0.5),
    RGBAf(0.2, 0.3, 0.4, 0.6)
]

for i in 1:jumlah_pecahan
    kristal = bikin_kristal(posisi_x[i], posisi_y[i])

    mesh!(ax, kristal,
        color=rand(warna_palet),
        transparency=true,
        shading=true
    )

    wireframe!(ax, kristal, color=:black, linewidth=1.0)
end

display(fig)