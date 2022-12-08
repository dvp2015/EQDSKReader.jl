#!/bin/bash
#=
exec julia --project=scripts/ --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' "${BASH_SOURCE[0]}" "$@"
=#

using LibGit2: getconfig, path, GitRepo
using DocumenterTools

DocumenterTools.genkeys(
    user=getconfig("github.user","dvp2015"), 
    repo=basename(path(GitRepo(".")))
)

