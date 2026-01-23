using GLMakie
using GeometryBasics
using Random
using Colors

fig = Figure(size=(800, 800))
ax = Axis3(fig[1, 1], aspect=:data, perspectiveness=0.2, azimuth=0.35π, elevation=0.15π)
hidedecorations!(ax);
hidespines!(ax);

limits!(ax, -60, 60, -60, 60, 0, 90)

display(fig)

function bikin_shard_agresif(pusat)
    p1 = pusat + Point3f(rand(-35:35), rand(-35:35), rand(-5:5))
    p2 = pusat + Point3f(rand(-35:35), rand(-35:35), rand(-5:5))
    p3 = pusat + Point3f(rand(-35:35), rand(-35:35), rand(-5:5))

    puncak = pusat + Point3f(rand(-55:55), rand(-55:55), rand(60:85))

    pts = [p1, p2, p3, puncak]
    fcs = [TriangleFace(1, 2, 4), TriangleFace(2, 3, 4), TriangleFace(3, 1, 4), TriangleFace(1, 2, 3)]
    return GeometryBasics.Mesh(pts, fcs)
end

palet_libeskind = [
    RGBAf(0.5, 0.6, 0.7, 0.95),
    RGBAf(0.3, 0.4, 0.5, 0.95),
    RGBAf(0.7, 0.8, 0.9, 0.9),
    RGBAf(0.2, 0.2, 0.3, 1.0)
]

@async begin
    for i in 1:8
        shard = bikin_shard_agresif(Point3f(0, 0, 0))
        mesh!(ax, shard, color=rand(palet_libeskind), shading=true)
        wireframe!(ax, shard, color=:white, linewidth=2.0)

        sleep(0.3)
    end
end