using GLMakie
using LinearAlgebra

function get_circle(angle, radius)
    return (radius * cos(angle), radius * sin(angle))
end

function get_square(angle, radius)
    x = radius * sign(cos(angle)) * (abs(cos(angle))^0.2)
    y = radius * sign(sin(angle)) * (abs(sin(angle))^0.2)
    scale = 1.0 / max(abs(cos(angle)), abs(sin(angle)))
    return (radius * cos(angle) * scale, radius * sin(angle) * scale)
end

n_u = 100
n_v = 40
u_range = range(0, stop=2pi, length=n_u)
v_range = range(0, stop=40, length=n_v)

X = zeros(n_u, n_v)
Y = zeros(n_u, n_v)
Z = zeros(n_u, n_v)

for (i, u) in enumerate(u_range)
    for (j, v) in enumerate(v_range)
        t = v / 40.0
        radius = 5.0
        cx, cy = get_circle(u, radius)
        sx, sy = get_square(u + (v * 0.05), radius)
        final_x = (cx * (1.0 - t)) + (sx * t)
        final_y = (cy * (1.0 - t)) + (sy * t)

        X[i, j] = final_x
        Y[i, j] = final_y
        Z[i, j] = v
    end
end

fig = Figure(size=(800, 600))
ax = LScene(fig[1, 1])

surface!(ax, X, Y, Z,
    colormap=:ice,
    shading=FastShading,
    transparency=false
)

wireframe!(ax, X, Y, Z, color=(:white, 0.2), linewidth=0.5, transparency=true)

display(fig)