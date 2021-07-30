using ModelingToolkit
using Plots
using DifferentialEquations
using LinearAlgebra

@parameters t σ ρ β  # add metadata to variables, i.e. this is a parameter!
@variables x(t) y(t) z(t)  # time-dependent variables
D = Differential(t)

D(x)  # dx/dt

eqs = [ D(D(x)) ~ σ * (y-x),
        D(y) ~ x*(ρ-z) - y,
        D(z) ~ x*y - β*z]

# generate an ode system from the equationsj
sys = ODESystem(eqs)

# what are the equations?
equations(sys)


# but ODE solver want's things in first order form...
# So just lower the order!
sys = ode_order_lowering(sys)
equations(sys)
# now we have 4 - first order ODEs

# define the initial conditions
u0 = [D(x) => 2.0,
      x => 1.0,
      y => 0.0,
      z => 0.0]

# define parameter values
p = [σ => 28.0,
     ρ => 10.0,
     β => 8/3]


# build the ODE problem, i.e. translate from Symbolic to Numeric
tspan = (0.0, 100.0)

prob = ODEProblem(sys, u0, tspan, p, jac=true, sparse=true)  # build analytic jacobian function and use sparse arrays

sol = solve(prob, Tsit5())


states(sys)  # what is the ordering of the solution vector


# HYPE: we can use variables to index solution object!!!!!
sol[x]  # get time series for x
sol[D(x)]

# what if you want to interpolate
sol(50.0, idxs=y)  # i.e. what is y(t) for t=50.0

plot(sol, vars=(x, y))



# ----- Lorenz equations --------------

eqs = [D(x) ~ σ*(y-x),
       D(y) ~ x*(ρ-z) - y,
       D(z) ~ x*y - β*z]


# same symbolic equations
@named lorenz1 = ODESystem(eqs)
@named lorenz2 = ODESystem(eqs)

# define a mixture between the two

@variables a(t)
@parameters γ

# define the connection by an algebraic equation
connections = [0 ~ lorenz1.x + lorenz2.y + a*γ]


# indep var, array of state variables, array of parameters and the systems of odes these relate
connected = ODESystem(connections, t, [a], [γ], systems=[lorenz1, lorenz2])
equations(connected)


# define initial conditions, parameters, timespan
u0 = [lorenz1.x => 1.0, lorenz1.y => 0.0, lorenz1.z => 0.0, lorenz2.x => 0.0, lorenz2.y => 1.0, lorenz2.z => 0.0, a=> 2.0]
p = [lorenz1.σ => 10.0, lorenz1.ρ => 28.0, lorenz1.β => 8/2, lorenz2.σ => 10.0, lorenz2.ρ => 28.0, lorenz2.β => 8/3, γ => 2.0]
tspan = (0.0, 100.0)

prob = ODEProblem(connected, u0, tspan, p)

sol = solve(prob)

plot(sol, vars=(a, lorenz1.x, lorenz2.z))



# --------------- Using MTK without using MTK ------------------------
# naive version that allocates array instead of using inplace f(du, u, p, t)
function rober(u, p, t)
    y₁, y₂, y₃ = u
    k₁, k₂, k₃ = p
    [-k₁*y₁+k₃*y₂*y₃, k₁*y₁-k₂*y₂^2-k₃*y₂*y₃, k₂*y₂^2]
end


prob = ODEProblem(rober, [1.0, 0.0, 0.0], (0.0, 1e5), (0.04, 3e7, 1e4))
# turn it into an internal MTK problem defined symbolically
sys = modelingtoolkitize(prob)
equations(sys)


# redefine the problem to use the symbolic jacobian
prob_jac = ODEProblem(sys, [1.0, 0.0, 0.0], (0.0, 1e5), (0.04, 3e7, 1e4), jac=true)


using BenchmarkTools

@btime sol = solve(prob)
@btime sol = solve(prob_jac)




#----------- problems with Algebraic Constraints-------------------
function pendulum!(du, u, p, t)
    x, dx, y, dy, T = u
    g, L = p
    du[1] = dx
    du[2] = T*x
    du[3] = dy
    du[4] = T*y -g
    du[5] = x^2 + y^2 - L^2 # the length
    return nothing
end

# Mu' = f
pendulum_fun! = ODEFunction(pendulum!, mass_matrix=Diagonal([1,1,1,1,0]))
u0 = [1.0, 0, 0, 0, 0]
p = [9.8, 1]
tspan = (0, 10.0)

pendulum_prob = ODEProblem(pendulum_fun!, u0, tspan, p)

# this doesn't work for technical reasons about DAE's. We need to refactor it into a nicer form
sol = solve(pendulum_prob, Rodas4(), abstol=1e-8, reltol=1e-8)

# convert to symbolic representation
traced_sys = modelingtoolkitize(pendulum_prob)
equations(traced_sys)
# lower dae index and simplify
pendulum_sys = structural_simplify(dae_index_lowering(traced_sys)) # this is just being explicit, we could have just done structural simplify
equations(pendulum_sys)

prob = ODAEProblem(pendulum_sys, Pair[], tspan)
sol = solve(prob, Tsit5(), abstol=1e-8, reltol=1e-8)
plot(sol, vars=states(traced_sys))
