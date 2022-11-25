#!/usr/bin/env julia --project=@.

using Pkg
Pkg.activate(".")
Pkg.build(; verbose = true)
Pkg.test(coverage=true)