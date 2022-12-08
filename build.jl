#!/bin/bash
#=
exec julia --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' "${BASH_SOURCE[0]}" "$@"
=#

using Pkg
Pkg.activate(".")
Pkg.build(; verbose = true)
Pkg.test(coverage=true)


# # Install dependencies
# using Pkg 
# Pkg.activate("docs")
# Pkg.develop(PackageSpec(path=pwd()))
# Pkg.instantiate()
# # Build and deploy
# include("docs/make.jl")