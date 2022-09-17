#!/usr/bin/env julia --project=$(dirname BASH_SOURCE[0])

module Clean

using Coverage: clean_folder

const HERE = dirname(dirname(@__FILE__))

function clean()
    clean_folder(HERE)
end    

export clean

end

using .Clean

clean()
