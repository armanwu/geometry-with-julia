using GLMakie

n_u = 20
n_v = 60

u_range = range(0, stop=2pi, length=n_u)
v_range = range(0, stop=40, length=n_v)

X = zeros(n_u, n_v)
Y = zeros(n_u, n_v)
Z = zeros(n_u, n_v)

for (i, u) in enumerate(u_range)
    for (j, v) in enumerate(v_range)
        pusat_pinggang = 20
        jarak_dari_tengah = abs(v - pusat_pinggang)
        radius = 4.0 + (jarak_dari_tengah * 0.2)
        sudut_final = u + (v * 0.1)

        x_pos = radius * cos(sudut_final)
        y_pos = radius * sin(sudut_final)
        z_pos = v

        X[i, j] = x_pos
        Y[i, j] = y_pos
        Z[i, j] = z_pos
    end

end

fig = Figure(size=(800, 800))
ax = LScene(fig[1, 1])

surface!(ax, X, Y, Z,
    colormap=:cool,
)

wireframe!(ax, X, Y, Z,
    color=:white,
    linewidth=1.5,
    transparency=true
)

display(fig)