using Pkg                 # Load package manager
Pkg.add("JuliaFormatter") # Install JuliaFormatter

using JuliaFormatter      # Load JuliaFormatter
format("."; verbose=true) # Format all files 

Pkg.rm("JuliaFormatter")  # Remove JuliaFormatter
