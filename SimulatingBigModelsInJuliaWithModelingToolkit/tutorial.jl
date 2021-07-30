using Symbolics, ModelingToolkit, Plots, DifferentialEquations
using BenchmarkTools

# define variables
@variables x y

# expressions are exactly as you would think
x^2+y^2

# common derivative operations
Symbolics.derivative(x^2 + y^2, x)
Symbolics.gradient(x^2 + y^2, [x, y])
Symbolics.jacobian([x^2 + y^2; y^2], [x, y])

# other operations  # i.e. replace x with y^2
substitute(sin(x)^2 + 2 + cos(x)^2, Dict(x=>y^2))

# substitute numerical value
substitute(sin(x)^2 + 2 + cos(x)^2, Dict(x=>1.0))

# simplify expression to 3 (the analytic value)
simplify(sin(x)^2 + 2 + cos(x)^2)

# direct simplification is performed
2x-x # x

ex = x^2 + y^2 + sin(x)

ex + ex
ex / ex
ex^2/ex


# compare terms
isequal(ex^2/ex, ex)

# what if we have stochasticity?
foo(x, y) = x * rand() + y
@register foo(x,y) # this tells symbolic not trace further into function
Symbolics.derivative(foo(hypot(x, y), y), x)
# this leaves stops the derivative at foo(x,y) and returns result with differential using the chain rule
# since we don't know how to take (d foo/ dx)


# figure out the type that x is representing
SymbolicUtils.symtype(Symbolics.value(x))


# tell symbolics that z is a complex number
@variables z::Complex

# automatically perform correct algebra
z^2

real(z^2)

z'z # i.e. z_conj * z


# xs is a symbolic vector of length 10
@variables xs[1:10]

xs[1]

sum(xs)  # lazy representation of sum operation

# eagerly evaluate summation
sum(collect(xs))



# Rosenbrock function
rosenbrock(xs) = sum(1:length(xs)-1) do i
    100*(xs[i+1] - xs[i]^2)^2 + (1-xs[i])^2
end

N = 100
xs = ones(N)  # location of minimum

rosenbrock(xs)

# check that it is a minimum via small perturbations to check concavity
rosenbrock(xs + 1e-6*rand(N))
rosenbrock(xs + 1e-2*rand(N))


# passing symbolic variables to julia functions produces symbolic functions
@variables xs[1:N]
rosenbrock(xs)

xs = collect(xs)  # expand into eager represenation
rxs = rosenbrock(xs)
# compute gradient of rosenbrock
grad = Symbolics.gradient(rxs, xs)
hess = Symbolics.jacobian(grad, xs)
# or
hess = Symbolics.hessian(rxs, xs) # Hessian is zeroes.
hess_sparse = Symbolics.sparsehessian(rxs, xs)  # we could also do sparse jacobian.

# check that it worked
size(hess_sparse)
hess_sparse[1,1]

# to get just the sparsity pattern we can do this:
hes_sparsity = Symbolics.hessian_sparsity(rxs, xs)
hes_sparsity[1,1]

# plot the sparsity matrix
spy(hes_sparsity)


@benchmark Symbolics.hessian($rxs, $xs)
@benchmark Symbolics.sparsehessian($rxs, $xs)


foop, fip = build_function(grad, xs, expression=false) # out of place, in place


aa = rand(N)
out = similar(aa) # create output vector
fip(out, aa) # apply in place function of gradients to aa
out


foop(aa) ≈ out


using ForwardDiff

# evaluate the Jacobian via forward-mode AD to check
ForwardDiff.gradient(rosenbrock, aa) ≈ out



