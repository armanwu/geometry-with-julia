using GLMakie
using LinearAlgebra

function get_circle(angle, radius)
    return (radius * cos(angle), radius * sin(angle))
end

function get_square(angle, radius)
    scale = 1.0 / max(abs(cos(angle)), abs(sin(angle)))
    return (radius * cos(angle) * scale, radius * sin(angle) * scale)
end

n_u = 100
n_v = 60
u_range = range(0, stop=2pi, length=n_u)
v_range = range(0, stop=40, length=n_v)

X_final = zeros(n_u, n_v)
Y_final = zeros(n_u, n_v)
Z_final = zeros(n_u, n_v)


for (i, u) in enumerate(u_range)
    for (j, v) in enumerate(v_range)
        t = v / 40.0
        radius = 5.0

        cx, cy = get_circle(u, radius)
        sx, sy = get_square(u + (v * 0.05), radius)

        # Morphing: Linear Interpolation (Lerp)
        final_x = (cx * (1.0 - t)) + (sx * t)
        final_y = (cy * (1.0 - t)) + (sy * t)

        X_final[i, j] = final_x
        Y_final[i, j] = final_y
        Z_final[i, j] = v
    end
end

# --- 3. SIAPKAN OBSERVABLE (Wadah Animasi) ---
# Awalnya kita isi dengan NaN (Not a Number)
# NaN di GLMakie artinya "Jangan digambar/Transparan"
X_live = Observable(fill(NaN, n_u, n_v))
Y_live = Observable(fill(NaN, n_u, n_v))
Z_live = Observable(fill(NaN, n_u, n_v))

# --- 4. VISUALISASI ---
fig = Figure(size=(800, 800))
ax = LScene(fig[1, 1])


wireframe!(ax, Rect3f(Vec3f(-6, -6, 0), Vec3f(12, 12, 40)), color=(:grey30, 0.1), transparency=true)

# Surface menggunakan data 'Live'
s = surface!(ax, X_live, Y_live, Z_live,
    colormap=:ice,
    shading=FastShading,
    transparency=false
)
# Wireframe pelapis (Opsional)
wireframe!(ax, X_live, Y_live, Z_live, color=(:white, 0.1), linewidth=0.5, transparency=true)

display(fig)

# --- 5. ANIMASI LOOP (THE PRINTING PROCESS) ---
@async begin
    println("Mulai mencetak Morphing Tower...")

    # Loop layer demi layer (dari bawah ke atas)
    # Loop 'j' merepresentasikan ketinggian (v)
    for j in 1:n_v

        # COPY-PASTE DATA:
        # Ambil satu cincin (baris) dari Blueprint, masukkan ke Live
        X_live[][:, j] = X_final[:, j]
        Y_live[][:, j] = Y_final[:, j]
        Z_live[][:, j] = Z_final[:, j]

        # Beritahu Makie untuk update gambar
        notify(X_live)
        notify(Y_live)
        notify(Z_live)

        # Delay biar terlihat prosesnya
        sleep(0.08)
    end
    println("Selesai!")
end