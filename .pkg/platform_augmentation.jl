using Base.BinaryPlatforms

try
    using CUDA_Compiler_jll
catch
    # during initial package installation, CUDA_Compiler_jll may not be available.
    # in that case, we just won't select an artifact.
end

function cuda_comparison_strategy(_a::String, _b::String, a_requested::Bool, b_requested::Bool)
    # if either isn't a version number (e.g. "none"), perform a simple equality check
    a = tryparse(VersionNumber, _a)
    b = tryparse(VersionNumber, _b)
    if a === nothing || b === nothing
        return _a == _b
    end

    # if both are explicitly requested, require equality
    if a_requested && b_requested
        return Base.thisminor(a) == Base.thisminor(b)
    end

    # otherwise, an artifact is compatible with a JIT stack from the same major
    # series that is at least as new as the artifact's minimum toolkit
    function is_compatible(artifact::VersionNumber, host::VersionNumber)
        artifact.major == host.major &&
        Base.thisminor(artifact) <= Base.thisminor(host)
    end
    if a_requested
        is_compatible(b, a)
    else
        is_compatible(a, b)
    end
end

function augment_platform!(platform::Platform)
    if !@isdefined(CUDA_Compiler_jll)
        # don't set to nothing or Pkg will download any artifact
        platform["cuda"] = "none"
    elseif !haskey(platform, "cuda")
        # CUDA_Compiler_jll owns driver inspection and preference handling.
        CUDA_Compiler_jll.augment_platform!(platform)
    end
    BinaryPlatforms.set_compare_strategy!(platform, "cuda", cuda_comparison_strategy)

    return platform
end