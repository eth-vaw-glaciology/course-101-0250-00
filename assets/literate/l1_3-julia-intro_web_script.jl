# This file was generated, do not modify it.

using OrdinaryDiffEq, Plots

function lorenz(x, p, t)
    σ = 10
    β = 8/3
    ρ = 28
    [σ*(x[2]-x[1]),
     x[1]*(ρ-x[3]) - x[2],
     x[1]*x[2] - β*x[3]]
end

# integrate dx/dt = lorenz(t,x) numerically from t=0 to t=50 and starting point x₀
tspan = (0.0, 50.0)
x₀ = [2.0, 0.0, 0.0]
sol = solve(ODEProblem(lorenz, x₀, tspan), Tsit5())

plot(sol, idxs=(1,2,3)) # plot Lorenz attractor

# ?cos

a = 4
b = "a string"
c = b # now b and c bind to the same value

#

1     # 64 bit integer (or 32 bit if on a 32-bit OS)
1.5   # Float64
1//2  # Rational

typeof(1.5)

"a string", (1, 3.5) # and tuple

[1, 2, 3,] # array of eltype Int

Dict("a"=>1, "b"=>cos)

a = [2, 3]
b = [4, 5]
[a ; b]

push!(b, 1)
push!(b, 3, 4)

[1:10; [4,5]]

a = rand(3,3)

a[1,2], a[2,1]

[ a[1,2], a[2,1] ]

a[1]
a[1,1]

a[end]
a[end, end]

a[end, 1:end]

a[1:2, 1:2]

a = [1 4; 3 4] # note, this is another way to define a Matrix
c = a
a[1, 2] = 99
@assert c[1,2] == a[1,2]

c = a
c[1] = 8
@assert a[1]==8 # as c and a are the same thing
@assert a===c  # note the triple `=`

a = rand(3,4)
b = a[1:3, 1:2]
b[1] = 99
@assert a[1] != b[1]

a = rand(3,4)
b = @view a[1:3, 1:2]
b[1] = 99

@assert a[1] == 99

typeof([1, 2]), typeof([1.0, 2.0])

String["one", "two"]

a = Int[]
push!(a, 1) ## works
push!(a, 1.0) ## works
push!(a, 1.5) ## errors as 1.5 cannot be converted to an Int

a = []
push!(a, 5)
push!(a, "a")

[1][1] = 1.5 ## errors

a = Array{Any}(undef, 3, 3)

size(a)

a = "Where are the flowers"
if startswith(a, "Wh")
  b = "Likely a question"
elseif startswith(a, "The")
  b = "Likely a noun"
else
  b = "no idea"
end

a > 5 ? "really big" : "not so big"

for i = 1:3
    println(i)
end

for i in ["dog", "cat"] ## `in` and `=` are equivalent for writing loops
    println(i)
end

i = 1
while i<4
    println(i)
    i += 1
end

function fn(a, b)
  if a> b
    return a
  else
    return b
  end
end

mymap(fn, a) = [fn(aa) for aa in a]
mymap(sin, 1:10)

sin.(1:10)

(1:10) .+ (1:10)'

x,y = 0:0.1:pi, -pi:0.1:pi
sin.(x) .+ cos.(y')

map(x -> sin(x) + cos(x), 1:10)

struct Rock end
struct Paper end
struct Scissors end
### of course structs could have fields as well
# struct Rock
#     color
#     name::String
#     density::Float64
# end

# define multi-method
play(::Rock, ::Paper) = "Paper wins"
play(::Rock, ::Scissors) = "Rock wins"
play(::Scissors, ::Paper) = "Scissors wins"
play(a, b) = play(b, a) # commutative

play(Scissors(), Rock())

struct Pond end
play(::Rock, ::Pond) = "Pond wins"
play(::Paper, ::Pond) = "Paper wins"
play(::Scissors, ::Pond) = "Pond wins"

play(Scissors(), Pond())

combine(::Rock, ::Paper) = "Paperweight"
combine(::Paper, ::Scissors) = "Two pieces of papers"
# ...

combine(Rock(), Paper())

using Plots
plot( (1:10).^2 )

# Install a package (maybe not a too big one, UnPack.jl is good that way),
# use it, query help on the package itself:

