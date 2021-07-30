using Random, Statistics, LinearAlgebra, Dates #Shipped with Julia
using Distributions, StatsBase #Core statistics
using CSV, DataFrames #Basic Data
using Plots, StatsPlots, LaTeXStrings, Measures #Plotting and Output
using HypothesisTests, KernelDensity, GLM, Lasso, Clustering, MultivariateStats #Statistical/ML methods
using Flux, Metalhead #Deep learning
using Combinatorics, SpecialFunctions, Roots #Mathematical misc.
using RDatasets, MLDatasets #Example datasets
#uncomment if using R:  using RCall #Interface with R


# fix the random seed for reproducibility of random number sequences
fix_seed!() = Random.seed!(42)
fix_seed!()

readdir("./data")


# common operations
data = rand(Normal(), 5)  # 5 numbers selected from normal distributions
length(data)
size(data)
typeof(data)

n = length(data)
sum(data)/n


+(data...)/n  # + is just a function


# running mean formula
mn = 0  # initial value
for i ∈ 1:length(data)
    mn = (1/i)*data[i] + ((i-1)/i)*mn
end
mn


"""

My mean function. Works like this (inside)

"""
function my_mean(input_data)
    mn = 0  # initial value
    for (i,d) ∈ enumerate(input_data)
        mn = (1/i)*input_data[i] + ((i-1)/i)*mn
    end
    return mn
end


my_mean(data)


data = rand(Normal(), n) + im*rand(Normal(), n)
mean(data)
my_mean(data) # it just works!


methods(my_mean)
length(methods(mean)) # there are many different dispatches of mean

@which mean(data)

