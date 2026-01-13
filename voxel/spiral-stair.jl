using GLMakie
using GeometryBasics

function putar_titik(x, y, sudut_derajat)
    rad = deg2rad(sudut_derajat)
    x_baru = x * cos(rad) - y * sin(rad)
    y_baru = x * sin(rad) + y * cos(rad)
    return x_baru, y_baru
end

posisi = Point3f[]
rotasi_anak_tangga = Vec3f[]

radius = 4.0
jumlah_anak_tangga = 30
tinggi_per_step = 0.5
sudut_per_step = 15

for i in 1:jumlah_anak_tangga
    z = i * tinggi_per_step
    sudut_sekarang = i * sudut_per_step
    x_awal = radius
    y_awal = 0
    x_jadi, y_jadi = putar_titik(x_awal, y_awal, sudut_sekarang)
    push!(posisi, Point3f(x_jadi, y_jadi, z))
    push!(rotasi_anak_tangga, Vec3f(0, 0, deg2rad(sudut_sekarang)))
end

fig = Figure(size=(800, 800))
ax = Axis3(fig[1, 1], title="Latihan Santai: Spiral Staircase", aspect=:data)

meshscatter!(ax, posisi,
    marker=Rect3f(Vec3f(0, -1, 0), Vec3f(30, 15, 2)),
    rotation=rotasi_anak_tangga, color=1:jumlah_anak_tangga, # Warna pelangi sesuai urutan
    colormap=:turbo
)

display(fig)