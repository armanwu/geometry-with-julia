using GLMakie
using GeometryBasics
using Colors

# --- 1. SETUP KANVAS ---
fig = Figure(size=(800, 780))
ax = Axis3(fig[1, 1], aspect=:data, azimuth=0.2π, elevation=0.1π)
hidedecorations!(ax);
hidespines!(ax);

wireframe!(ax, Rect3f(Point3f(-40, -40, 0), Vec3f(80, 80, 0)),
    color=(:white, 0.1), linewidth=0.5)

# --- 2. FUNGSI MEMBUAT LANTAI (VERSI SEGITIGA/TRIANGLE) ---
function bikin_lantai_aman(z_pos, lebar, rotasi_rad, tebal)

    half = lebar / 2
    # Definisi 4 titik dasar di pusat
    p1 = Point3f(-half, -half, 0)
    p2 = Point3f(half, -half, 0)
    p3 = Point3f(half, half, 0)
    p4 = Point3f(-half, half, 0)

    raw_points = [p1, p2, p3, p4]
    final_points = Point3f[]

    c = cos(rotasi_rad)
    s = sin(rotasi_rad)

    # Generate 8 Titik (4 Bawah, 4 Atas)
    for h in [0, tebal]
        for p in raw_points
            rx = p[1] * c - p[2] * s
            ry = p[1] * s + p[2] * c
            push!(final_points, Point3f(rx, ry, z_pos + h))
        end
    end

    # --- PERBAIKAN: GUNAKAN SEGITIGA ---
    # GPU lebih stabil dengan GLTriangleFace daripada QuadFace
    # Urutan titik: 1-2-3-4 (Bawah), 5-6-7-8 (Atas)

    faces = [
        # Alas (Bawah) -> Pecah jadi 2 segitiga
        GLTriangleFace(1, 2, 3), GLTriangleFace(1, 3, 4),
        # Atap (Atas)
        GLTriangleFace(5, 6, 7), GLTriangleFace(5, 7, 8),
        # Depan
        GLTriangleFace(1, 2, 6), GLTriangleFace(1, 6, 5),
        # Kanan
        GLTriangleFace(2, 3, 7), GLTriangleFace(2, 7, 6),
        # Belakang
        GLTriangleFace(3, 4, 8), GLTriangleFace(3, 8, 7),
        # Kiri
        GLTriangleFace(4, 1, 5), GLTriangleFace(4, 5, 8)
    ]

    return GeometryBasics.Mesh(final_points, faces)
end

# --- 3. EKSEKUSI ---
# Kita hilangkan @async dulu agar debugging lebih mudah
println("Mulai Membangun...")

jumlah_lantai = 60
tinggi_per_lantai = 1.2

for i in 1:jumlah_lantai

    progress = i / jumlah_lantai

    # Matematika Bentuk
    z = (i - 1) * (tinggi_per_lantai + 0.3)

    # Gembung (Sinus)
    kurva_gembung = sin(progress * π)
    lebar_saat_ini = 15.0 + (kurva_gembung * 15.0)

    # Putar (Twist)
    rotasi_saat_ini = progress * 0.5π

    # Buat Mesh
    lantai_mesh = bikin_lantai_aman(z, lebar_saat_ini, rotasi_saat_ini, tinggi_per_lantai)

    # Warna Gradasi
    warna = RGBAf(0.2 + (progress * 0.6), 0.5, 1.0 - (progress * 0.5), 0.9)

    mesh!(ax, lantai_mesh, color=warna, shading=FastShading)
    wireframe!(ax, lantai_mesh, color=(:black, 0.3), linewidth=0.5)

    # Trik agar update layar terlihat animasi tanpa @async
    sleep(0.02)
end

display(fig)
println("Selesai!")