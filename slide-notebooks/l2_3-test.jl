#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 2_
md"""
# ODEs & PDEs: reaction - diffusion - advection
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We may want to write a single "monolithic" `reaction_1D.jl` code to perform these steps that looks as following
"""

using Plots
@views function reaction_1D()
    ## Physics
    Lx   = 10.0
    ξ    = 10.0
    Ceq  = 0.5
    ttot = 20.0
    ## Numerics
    nx   = 128
    ## Derived numerics
    dx   = Lx/nx
    dt   = ξ/2.0
    nt   = cld(ttot, dt)
    xc   = LinRange(dx/2, Lx-dx/2, nx)
    ## Array initialisation
    C    =  rand(Float64, nx)
    Ci   =  copy(C)
    dCdt = zeros(Float64, nx)
    ## Time loop
    for it = 1:nt
        #tag I am a tag
        #hint #dCdt .= rate of change
        #hint #C    .= update rule
        #sol dCdt .= .-(C .- Ceq)./ξ
        #sol C    .= C .+ C .* dt
        IJulia.clear_output(true); display(plot(xc, C, lw=2, xlims=(xc[1], xc[end]), ylims=(0.0, 1.0), xlabel="Lx", ylabel="Concentration", title="time = $(it*dt)", framestyle=:box, label="Concentration"))
        sleep(0.1)
    end
    IJulia.clear_output(true); plot!(xc, Ci, lw=2, label="C initial")
    IJulia.clear_output(true); display(plot!(xc, Ceq*ones(nx), lw=2, label="Ceq"))
    return
end

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# Let's execute it and visualise output
#nb reaction_1D()

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
So, excellent, we have our first 1D ODE solver up and running in Julia :-)
"""

#src #md # 👉 [Download the `reaction_1D.jl` script](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/)
