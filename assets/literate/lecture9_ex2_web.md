<!--This file was generated, do not modify it.-->
## Exercise 2 — **Automatic documentation in Julia**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- write some documentation
  - using [doc-strings](https://docs.julialang.org/en/v1/manual/documentation/)
  - using [`Literate.jl`](https://github.com/fredrikekre/Literate.jl)

One task you've already done, namely to update the `README.md` of this set of exercises!

Tasks:
1. Add doc-string to the functions of following scripts:
    - `PorousConvection_3D_xpu.jl`
    - `PorousConvection_3D_multixpu.jl`
2. Add to the `PorousConvection` folder  a `Literate.jl` script called `bin_io_script.jl` that contains and documents following `save_array` and `load_array` functions you may have used in your 3D script

````julia:ex1
"""
Some docstring
"""
function save_array(Aname,A)
    fname = string(Aname,".bin")
    out = open(fname,"w"); write(out,A); close(out)
end

"""
Some docstring
"""
function load_array(Aname,A)
    fname = string(Aname,".bin")
    fid=open(fname,"r"); read!(fid,A); close(fid)
end
````

Add to the `bin_io_script.jl` a `main()` function that will:
- generate a `3x3` array `A` of random numbers
- initialise a second array `B` to hold the read-in results
- call the `save_array` function and save the random number array
- call the `load_array` function and read the random number array in `B`
- return B
- call the main function making and plotting as following

````julia:ex2
B = main()
heatmap(B)
````

3. Make the Literate-based workflow to automatically build on GitHub using GitHub Actions. For this, you need to add to the `.github/workflow` folder (the one containing your `CI.yml` for testing) the `Literate.yml` script which we saw in this lecture's section [Documentation tools: Automating Literate.jl](#documentation_tools_automating_literatejl).

4. That's all! Head to the [Project section in Logistics](/logistics/#project) for a check-list about what you should hand in for this first project.

