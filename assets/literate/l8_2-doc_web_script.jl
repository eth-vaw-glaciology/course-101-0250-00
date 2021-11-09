# This file was generated, do not modify it.

"""
    transform(r, θ) = (r*cos(θ), r*sin(θ))

Transform polar to cartesian coordinates.
"""
transform(r, θ) = (r*cos(θ), r*sin(θ))

"Typical size of beer crate"
const BEERBOX = 12

?BEERBOX

"""
    transform(r, θ) = (r*cos(θ), r*sin(θ))

Transform polar to cartesian coordinates.

# Example
```jldoctest
julia> transform(4.5, pi/5)
(3.6405764746872635, 2.6450336353161292)
```
"""
transform(r, θ) = (r*cos(θ), r*sin(θ))

?transform

