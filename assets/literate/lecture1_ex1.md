<!--This file was generated, do not modify it.-->
## Exercise 1 - **Money in the bank**

👉 [Download the notebook to get started with this exercise!](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/lecture1/lecture1_ex1.ipynb)

The goal of this exercise is to familiarise with:
- array initialisation
- `for` loop
- indexing
- update rule
- basic visualisation

You are managing assets from a client which has an initial wealth `M_init` of 20kCHF. Your client's business generates yearly savings `M_save` of 500CHF.

```julia:ex1
M_init  = 20000.0   # initial wealth
M_save  = 500.0;    # yearly savings
```

### Question 1

Model the wealth evolution of your client for the coming 35 years `tot_yrs`:

```julia:ex2
tot_yrs = 35;       # number of years
```

To do so, we will first initialise a one dimensional array (vector) to store the wealth evolution of the client and check that the vector `M_evol1` has the correct `length` (or size):

```julia:ex3
M_evol1 = zeros(tot_yrs)
length(M_evol1)
```

We then need to initialise that vector with the initial wealth of the client:

```julia:ex4
M_evol1[1] = M_init;
```

Now we have to define the core of our simulator; predicting the wealth evolution. To do so, we will define the the wealth fo the current year `it` as the wealth from previous year `it-1` plus the amount of saving `M_save` and repeat this for `tot_yrs` (taking care about the start value of the iterator):

```julia:ex5
for it=2:tot_yrs
    M_evol1[it] =  M_evol1[it-1] + M_save
end
```

Now, we want to print the wealth of our client after `tot_yrs`

```julia:ex6
println("Wealth after $(tot_yrs) years: $(M_evol1[end]) CHF")
```

Perfect. However, the client is interested in a graphical evolution as he needs this to convince future investors.

```julia:ex7
using Plots
plot(M_evol1 ./ 1000, linewidth=3,
     xlabel="time, yrs", ylabel="savings, kchf", label="without interest",
     framestyle=:box, legend=:topleft, foreground_color_legend = nothing)
```

### Question 2

The bank you are working for offers actually a yearly interest rate `intrst` of 0.6% for all premium client, a category your client belongs to. Repeat the exercise from Question 1 including now the interest rate.

Create a new vector `M_evol2` to store the wealth evolution with interest rate and assign the initial wealth:

```julia:ex8
intrst     = 0.006     # fixed interest rate
M_evol2    = zeros(tot_yrs)
M_evol2[1] = M_init;
```

Then, update the prediction formula within the time loop to account for the interest rate (replacing the `??`)

```julia:ex9
# TO DO: add correct formula !
for it=2:tot_yrs
    M_evol2[it] = M_evol2[it-1] + M_save
end
```

\note{Each year, the total wealth is the wealth of previous year plus the percentage proportional to the interest rate.}

Report the total wealth of the client after `tot_yrs`:

```julia:ex10
println("Wealth after $(tot_yrs) years with interest rate: $(M_evol2[end]) CHF")
```

And display the graphical evolution on top of previous one:

```julia:ex11
plot!(M_evol2 ./ 1000, linewidth=3, label="with interest")
```

Finally, quantify the difference in the final wealth with and without interest rate:

```julia:ex12
∆evo = M_evol2[end] - M_evol1[end]
println("∆evo = $(round(∆evo, sigdigits=5))")
```

### Question 3

Great job, your client is very happy and could use the financial prediction you made to convince the investors to further support his business. Your client now wants to know the final wealth after 35 years given the fact he plans a one time expense `expns` of 1125CHF in 20 years. Provide the final wealth and a graphical evolution for both cases with and without interest rate.

### Question 4

The final task you'll have to perform for your client before transferring his dossier to another department within the bank is to predict his wealth evolution taking market's randomness into account.

Define a yearly variable interest rate of 0.5% +/- 1%. Report the final wealth as well as a graphical evolution of your client's wealth taking the random market evolution into account for the coming 35 years.

\note{You can use `randn()` to generate a normally-distributed random number.}

🎉 Good job! You are done with **Exercise 1**

