# This file was generated, do not modify it. # hide
a = rand(3,4)
b = @view a[1:3, 1:2]
b[1] = 99