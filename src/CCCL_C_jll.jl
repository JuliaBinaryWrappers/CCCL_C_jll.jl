# Use baremodule to shave off a few KB from the serialized `.ji` file
baremodule CCCL_C_jll
using Base
using Base: UUID
using LazyArtifacts
Base.include(@__MODULE__, joinpath("..", ".pkg", "platform_augmentation.jl"))
import JLLWrappers

JLLWrappers.@generate_main_file_header("CCCL_C")
JLLWrappers.@generate_main_file("CCCL_C", Base.UUID("14f6ea6c-a097-5a94-acf5-bdf9db277d4c"))
end  # module CCCL_C_jll
