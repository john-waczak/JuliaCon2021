using Bootstrap
using CSV
using CategoricalArrays
using Chain
using DataFrames
using GLM
using Random
using Plots
using Statistics
using StatsPlots
using Downloads

ENV["LINES"] = 20
ENV["COLUMNS"] = 1000


# -----------------------------------------------------------------------------------------
# 0: Loading the Data

Downloads.download("https://vincentarelbundock.github.io/Rdatasets/csv/Ecdat/Participation.csv", "participation.csv")


readlines("participation.csv")


# GOAL: create a model to predict :lfp (labor force participation)
# begin by reading the data into a dataframe
df_raw = CSV.read("participation.csv", DataFrame)  # source file, destination types... one could use other tabular formats (maybe JuliaDB?)

# inspect the contents
describe(df_raw)

# use the select() function to transform the dataframe
df = select(df_raw,
            :lfp => (x -> recode(x, "yes"=> 1, "no"=> 0)) => :lfp,
            :lnnlinc,
            :age,
            :age => ByRow(x-> x^2) => :age²,  # perform squaring operation row-wise (we don't want to square a vector)
            Between(:educ, :noc),  # select all columns between :educ and :noc
            :foreign => categorical => :foreign  # convert :foreign to :categorical data
            )

# notice, now we see that the :foreign column has categorical type.
# note, much of this can be simplified using MLJ's "scientific type" system
describe(df)


# -----------------------------------------------------------------------------------------
# 1: Exploratory Data Analysis
# we use the @chain macro for efficient piping
# groupby function

@chain df beginj
    groupby(:lfp) # in other words, sort the dataframe based on the values in :lfp column
    combine([:lnnlinc, :age, :educ, :nyc, :noc] .=> mean) # now compute mean of each column by grouping
end

# more examples here: https://bkamins.github.io/julialang/2021/07/09/multicol.html

# instead of specifying columns manually, just apply the operation to all columns of relevant type
@chain df begin
    groupby(:lfp)
    combine(names(df, Real) .=> mean)
end

# see number of rows corresponding to :lfp and :foreign column
@chain df begin
    groupby([:lfp, :foreign])
    combine(nrow) # i.e. combine result of nrow function
end

# more examples of reshaping: https://bkamins.github.io/julialang/2021/05/28/pivot.html
# ex: cross tabulate number of rows between :lfp variables and :foreign variables
@chain df begin
    groupby([:lfp, :foreign])
    combine(nrow)
    unstack(:lfp, :foreign, :nrow) # this does the tabulation
end



# grouped dataframes are their own type
gd = groupby(df, :lfp)
# access each group by standard indexing
size(gd)
gd[1]

# or index by value
gd[(lfp=0,)]


# plot the pdf of the age column for each group
@df df density(:age, group=:lfp)



