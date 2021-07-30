
# this is annoying
my_long_variable = 3
println("my_long_variable = ", my_long_variable)


function myshow(y)
    println("the value is $y")
end

a = 1
b = 2

myshow(a + b)

# but what if we want to know *whose* value that is? The solution is to use a macro

y = 3
@show y  # this is a macro

@show a + b  # macros can access the name of the variable somehow

# this is replacing the old code with new code, i.e. *code generation*












