using GLMakie

x = range(-10, 10, length=100)
y = range(-10, 10, length=100)

function bikin_ombak(x, y)
    jarak = sqrt(x^2 + y^2)
    z = sin(jarak * 2) / (jarak * 0.1 + 1)
    return z
end

z = [bikin_ombak(i, j) for i in x, j in y]

fig = Figure(size=(800, 600))
ax = Axis3(fig[1, 1], aspect=:data)

surface!(ax, x, y, z,
    colormap = :viridis,
    transparency = true
)

display(fig)