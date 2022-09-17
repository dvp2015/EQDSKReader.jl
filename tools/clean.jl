#!/usr/bin/env julia --project=$(dirname BASH_SOURCE[0])

module Clean

using Glob

const HERE = dirname(dirname(@__FILE__))

function clean()
    files_to_delete = glob("**/*.cov", HERE)
    foreach(rm, files_to_delete)
end    

export clean

end

using .Clean

clean()
