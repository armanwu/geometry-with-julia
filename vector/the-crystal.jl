using GLMakie
using GeometryBasics
using Random
using Colors

function bikin_kristal(pusat_x, pusat_y)
    tinggi = rand(25:45)
    puncak = Poiint3f(pusat_x + rand(-20:20), pusat_y + rand(-20:20), tinggi)
    lebar = rand(15:25)

    alas_1 = Point3f(pusat_x + rand(-lebar:lebar), pusat_y + rand(-lebar:lebar), 0)
    alas_2 = Point3f(pusat_x + rand(-lebar:lebar), pusat_y + rand(-lebar:lebar), 0)
    alas_3 = Point3f(pusat_x + rand(-lebar:lebar), pusat_y + rand(-lebar:lebar), 0)

    points = [alas_1, alas_2, alas_3, puncak]
    faces = [
        TriangleFace(1, 2, 4), TriangleFace(2,3,4)
        
    ]