using Pkg
Pkg.add([
    "DFTK", "DoubleFloats", "FiniteDiff", "ForwardDiff",
    "GenericLinearAlgebra", "Infiltrator", "IntervalArithmetic",
    "KrylovKit", "LineSearches", "NLsolve", "Plots", "PyCall",
    "Unitful", "UnitfulAtomic"
])

using PyCall

if !isempty(PyCall.python)
    run(`$(PyCall.python) -m pip install pymatgen`)
end

using DFTK
DFTK.setup_threading() # print threading information


