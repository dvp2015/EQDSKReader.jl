#!/bin/bash
#=
exec julia --project=scripts/ --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' "${BASH_SOURCE[0]}" "$@"
=#

using LiveServer
serve(dir="docs/build")'
