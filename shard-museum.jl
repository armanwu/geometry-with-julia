using GLMakie
using GeometryBasics
using Random
using Colors

fig = Figure(size=(960, 1000))
ax = Axis3(fig[1, 1], aspect=:data, azimuth=0.6π, elevation=0.15π)
hidedecorations!(ax); hidespines!(ax)

function bikin_prisma_tajam(pusat_x, pusat_y, tinggi, kemiringan_x, kemiringan_y, rotasi_z)
    
    lebar_alas = rand(15.0:25.0)
    
    p_alas = [
        Point3f(pusat_x + rand(-5:5),            pusat_y + rand(-5:5), 0),
        Point3f(pusat_x + lebar_alas,            pusat_y + rand(-5:5), 0),
        Point3f(pusat_x + rand(0:5),             pusat_y + lebar_alas, 0)
    ]
    
    # TITIK PUNCAK (Digeser jauh biar miring ekstrem)
    # Puncak tidak harus lancip 1 titik, bisa juga bidang kecil (potongan)
    
    offset_x = kemiringan_x * tinggi
    offset_y = kemiringan_y * tinggi
    
    p_atap = [
        p + Point3f(offset_x, offset_y, tinggi) for p in p_alas
    ]
    
    # ROTASI MANUAL (Z-Axis) untuk titik atap saja (Twist Effect)
    # atau putar semuanya. Kita putar titik atap sedikit biar makin 'sakit' bentuknya.
    c = cos(rotasi_z)
    s = sin(rotasi_z)
    
    # Fungsi putar titik terhadap pusat rata-rata atap
    center_atap = sum(p_atap) / 3
    p_atap_final = Point3f[]
    
    for p in p_atap
        dx = p[1] - center_atap[1]
        dy = p[2] - center_atap[2]
        rx = dx*c - dy*s + center_atap[1]
        ry = dx*s + dy*c + center_atap[2]
        push!(p_atap_final, Point3f(rx, ry, p[3]))
    end
    
    # GABUNG & JAHIT
    # Urutan: Alas(1-2-3), Atap(4-5-6)
    all_points = [p_alas; p_atap_final]
    
    faces = [
        # Alas & Atap
        GLTriangleFace(1, 2, 3), GLTriangleFace(4, 6, 5),
        # Dinding Samping (Perlu logika urutan melingkar)
        GLTriangleFace(1, 2, 5), GLTriangleFace(1, 5, 4),
        GLTriangleFace(2, 3, 6), GLTriangleFace(2, 6, 5),
        GLTriangleFace(3, 1, 4), GLTriangleFace(3, 4, 6)
    ]
    
    return GeometryBasics.Mesh(all_points, faces)
end

# --- 3. KOMPOSISI ---
println("Membangun Museum Dekonstruksi...")

palet_titanium = [
    RGBAf(0.6, 0.65, 0.7, 0.9), # Zinc Grey
    RGBAf(0.5, 0.55, 0.6, 0.9), # Dark Metal
    RGBAf(0.7, 0.75, 0.8, 0.8), # Light Aluminium
    RGBAf(0.2, 0.25, 0.3, 0.95) # Contrast Dark
]

# Kita buat 4 Massa yang saling menabrak di tengah (0,0)
konfigurasi = [
    # (x, y, tinggi, miring_x, miring_y, rotasi)
    (0, 0, 35.0,  0.4,  0.2,  0.2), # Massa Utama
    (-10, 5, 25.0, -0.5,  0.1, -0.3), # Tabrakan dari kiri
    (5, -10, 20.0,  0.1, -0.6,  0.5), # Tabrakan dari depan
    (0, 0, 45.0, -0.2, -0.2, 0.8)     # Menara Jarum (Spire)
]

for (i, config) in enumerate(konfigurasi)
    
    x, y, h, mx, my, rot = config
    
    # Bikin Geometri
    shard = bikin_prisma_tajam(x, y, h, mx, my, rot)
    
    # 1. Render Massa Solid
    warna = palet_titanium[mod1(i, 4)]
    mesh!(ax, shard, color=warna, shading=FastShading, 
          specular=Vec3f(0.8), shininess=10.0f0) # Kilap Logam
    
    # 2. Render Garis Tepi (PENTING untuk Libeskind)
    wireframe!(ax, shard, color=(:white, 0.6), linewidth=1.5)
    
    # 3. "The Cuts" (Jendela Sayatan)
    # Kita gambar garis acak di permukaan massanya
    # Trik visual: Ambil bounding box acak di sekitar massa
    for _ in 1:5
        p_start = Point3f(x + rand(-5:5), y + rand(-5:5), rand(2:h-5))
        # Garis miring tajam
        p_end = p_start + Point3f(rand(-5:5), rand(-5:5), rand(-5:5))
        lines!(ax, [p_start, p_end], color=:black, linewidth=3.0)
    end
end

# Manusia Skala (Kecil sekali dibanding gedung)
# mesh!(ax, Rect3f(Point3f(15, 15, 0), Vec3f(0.5, 0.5, 1.8)), color=:red)

display(fig)