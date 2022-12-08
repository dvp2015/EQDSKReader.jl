#!/bin/bash
#=
exec julia --project=scripts/ --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' "${BASH_SOURCE[0]}" "$@"
=#

using Documenter, LibGit2
using EQDSKReader
repo = LibGit2.GitRepo(".")
if repo.isdirty()
    @warn "Commit recent changes before running this script. Canceled."
else
    doctest(EQDSKReader, fix=true)
end

# TODO dvp: not tested yet