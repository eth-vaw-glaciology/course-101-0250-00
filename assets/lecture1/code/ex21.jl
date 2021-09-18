# This file was generated, do not modify it. # hide
a = [1 4; 3 4] # note, this is another way to define a Matrix
c = a
a[1, 2] = 99
@assert c[1,2] == a[1,2]
@assert b[1] != a[1,2]