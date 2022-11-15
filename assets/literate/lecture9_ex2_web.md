<!--This file was generated, do not modify it.-->
## Exercise 2 - **Automatic documentation in Julia**

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

3. Make the Literate-based workflow to automatically build on GitHub using GitHub Actions. For this, you need to add the `.github/workflow` folder (the one containing your `CI.yml` for testing) following `Literate.yml` script
```yml
name: Run Literate.jl
# adapted from https://lannonbr.com/blog/2019-12-09-git-commit-in-actions

on: push

jobs:
  lit:
    runs-on: ubuntu-latest
    steps:
      # Checkout the branch
      - uses: actions/checkout@v2

      - uses: julia-actions/setup-julia@v1
        with:
          version: '1.8'
          arch: x64

      - uses: actions/cache@v1
        env:
          cache-name: cache-artifacts
        with:
          path: ~/.julia/artifacts
          key: ${{ runner.os }}-test-${{ env.cache-name }}-${{ hashFiles('**/Project.toml') }}
          restore-keys: |
            ${{ runner.os }}-test-${{ env.cache-name }}-
            ${{ runner.os }}-test-
            ${{ runner.os }}-

      - uses: julia-actions/julia-buildpkg@v1

      - name: run Literate
        run: |
          cd PorousConvection
          julia --color=yes --project -e 'using Pkg; Pkg.instantiate()'
          julia --color=yes --project -e 'cd("scripts"); include("literate-script.jl")'
          cd ..

      - name: setup git config
        run: |
          # setup the username and email. I tend to use 'GitHub Actions Bot' with no email by default
          git config user.name "GitHub Actions Bot"
          git config user.email "<>"

      - name: commit
        run: |
          # Stage the file, commit and push
          git add PorousConvection/scripts/md/*
          git commit -m "Commit markdown files from Literate"
          git push origin main
```

4. That's all! Head to the [Project section in Logistics](/logistics/#project) for a check-list about what you should hand in for this first project.

