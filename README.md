# Calculator
Calculator for PMF and CDF of at-least-one-of-each probability.

Requires Lua 5.3+

MatLab 2018b+ if using Plot.m


# How to Run
Download Markov.lua and its dependency, AbsorbMarkovTranslate.lua

Plot.m is optional


Run Markov.lua, it will prompt user for a set of probabilities

After running, Markov.lua will display the expected value and its standard deviation, and create data.txt and probs.txt

data.txt contains the PMF and CDF

probs.txt contains the user inputed probabilities


Plot.m requires data.txt and probs.txt, and will plot the PMF and CDF

# Example
> \> Markov.lua
> 
> Probabilities:
> 
> \> 0.5, 1/2
>
> Expected Number of Trials:		3.0
> 
> Standard Dev. of Expectation:	1.4142135623731
>
> Calculating Distribution...
> 
> Done!
> 
> \>

## If Using Plot.m
https://i.imgur.com/eafhkmv.png


# How it Works
As the file names suggest, the calculator uses Absorbing Markov Chains (https://en.wikipedia.org/wiki/Absorbing_Markov_chain) to find the exact expectation, standard deviation, and PMF and CDF of the probability distribution. Matrix multiplication runs in O(n^3) time, where n = 2 ^ (# of probabilities), which translates to O(n^3) run time for finding the expectation and standard deviation as they use Blockwise Inversion. The PMF and CDF are calculated up to 99.99% probability, so run time is Omega(n^4) at least.
