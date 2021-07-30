using AMDGPU

@show AMDGPU.agents()

# easiest way to program GPUs is using array operations

a = ROCArray([1 2 3 4])
