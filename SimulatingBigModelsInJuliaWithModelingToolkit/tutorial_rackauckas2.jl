using ModelingToolkit, NonlinearSolve

@parameters t
@variables u1(t) u2(t) u3(t) u4(t) u5(t)

eqs = [
        0 ~ u1 - sin(u5),
        0 ~ u2 - cos(u1),
        0 ~ u3 - hypot(u1, u2),
        0 ~ u4 - hypot(u2, u3),
        0 ~ u5 - hypot(u4, u1)
]

sys = NonlinearSystem(eqs, [u1, u2, u3, u4, u5], [])

simple_sys = structural_simplify(sys)

equations(simple_sys)

prob = NonlinearProblem(simple_sys, [u5=>0.0])
sol = solve(prob, NewtonRaphson())

sol[u5]
sol[u1]



# stochastic differential equations
using ModelingToolkit, DifferentialEquations

@parameters t σ ρ β
@variables x(t) y(t) z(t)
D = Differential(t)

eqs = [
        D(x) ~ σ*(y-x),
        D(y) ~ x*(ρ-z)-y,
        D(z) ~ x*y - β*z
       ]

noise_eqs = [0.1*x, 0.1*y, 0.1*z]

de = SDESystem(eqs, noise_eqs, t, [x, y, z], [σ, ρ, β])

u0map = [x=> 1.0, y=> 0.0, z=>0.0]
parammap = [σ => 10.0, ρ => 28.0, β => 8/3]

prob = SDEProblem(de, u0map, (0.0, 100.0), parammap)

sol = solve(prob)
plot(sol, vars=(x,y,z))


# ------------ optimization problem ----------------------
using ModelingToolkit, GalacticOptim, Optim

@variables x y
@parameters a b
loss = (a-x)^2 + b * (y -x^2)^2

sys = OptimizationSystem(loss, [x,y], [a,b])

# initial guess
u0 = [x=>1.0, y=>2.0]
p = [a => 6.0, b=> 7.0]

prob = OptimizationProblem(sys, u0, grad=true, hess=true)
sol = solve(prob) # doesn't work yet


# ------------ dsl demo via Catalyst ---------------------
using DifferentialEquations, Catalyst, Latexify, ModelingToolkit, Plots

repressilator = @reaction_network begin
    hillr(P₃,α,K,n), ∅ --> m₁
    hillr(P₁,α,K,n), ∅ --> m₂
    hillr(P₂,α,K,n), ∅ --> m₃
    (δ,γ), m₁ ↔ ∅
    (δ,γ), m₂ ↔ ∅
    (δ,γ), m₃ ↔ ∅
    β, m₁ --> m₁ + P₁
    β, m₂ --> m₂ + P₂
    β, m₃ --> m₃ + P₃
    μ, P₁ --> ∅
    μ, P₂ --> ∅
    μ, P₃ --> ∅
end α K n δ γ β μ;

