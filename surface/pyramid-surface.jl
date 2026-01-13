using GLMakie

x = -10:0.5:10
y = -10:0.5:10

function rumus_arsitek(x, y)
    
    jarak = sqrt(x^2 + y^2)
    tinggi = (15 - jarak) + (sin(x*2) * 2)
    
    return max(0, tinggi)
end

fig = Figure(size=(800, 600))
ax = Axis3(fig[1, 1], aspect=:data)

surface!(ax, x, y, rumus_arsitek, 
    colormap = :plasma,
    shading = FastShading
)

display(fig)