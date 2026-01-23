using GLMakie
using GeometryBasics
using Random
using Colors

fig = Figure(size=(800, 800))
batas_pandang = (-10, 60, -10, 60, 0, 30)
ax = Axis3(fig[1, 1],
    aspect=:data,
    limits=batas_pandang,
    perspectiveness=0.05,
    azimuth=0.25π,
    elevation=0.2π
)
hidedecorations!(ax);
hidespines!(ax);
display(fig)

ukuran_blok = 10.0
tinggi_per_lantai = 4.0
jumlah_grid_x = 4
jumlah_grid_y = 4

warna_palet = [
    RGBAf(0.0, 0.8, 0.9, 0.9), # Cyan Solid
    RGBAf(0.0, 0.5, 0.6, 0.9), # Teal Solid
    RGBAf(0.2, 0.7, 0.6, 0.9), # Tosca Solid
    RGBAf(0.6, 0.65, 0.7, 0.9) # Abu Solid
]

@async begin
    for x in 1:jumlah_grid_x
        for y in 1:jumlah_grid_y
            lantai_maksimal = rand(1:3)
            for z in 1:lantai_maksimal
                pos_x = (x - 1) * ukuran_blok * 1.2
                pos_y = (y - 1) * ukuran_blok * 1.2
                pos_z = (z - 1) * tinggi_per_lantai

                geser_x = rand(-3.0:3.0)
                geser_y = rand(-3.0:3.0)

                titik_sudut = Point3f(pos_x + geser_x, pos_y + geser_y, pos_z)
                dimensi = Vec3f(ukuran_blok, ukuran_blok, tinggi_per_lantai)

                kotak = Rect3f(titik_sudut, dimensi)

                mesh!(ax, kotak, color=rand(warna_palet), shading=true)
                wireframe!(ax, kotak, color=:black, linewidth=1.0)

                sleep(0.1)
            end
        end
        sleep(0.2)
    end
end