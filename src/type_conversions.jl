"""
$docstring_as_float
"""
function as_float(value)
    try
        passmissing(convert)(Float64, value)
    catch
        missing # if parsing failure
    end
end

function as_float(value::AbstractString)
    try
        passmissing(parse)(Float64, value)
    catch
        missing # if parsing failure
    end
end

"""
$docstring_as_integer
"""
function as_integer(value)
    try
        passmissing(floor)(value) |>      
        x -> passmissing(convert)(Int64, x)
    catch
        missing # if parsing failure
    end
end

function as_integer(value::AbstractString)
    try
        passmissing(parse)(Float64, value) |>
        x -> passmissing(floor)(x) |>      
        x -> passmissing(convert)(Int64, x)
    catch
        missing # if parsing failure
    end
end

"""
$docstring_as_string
"""
function as_string(value)
  passmissing(string)(value)
end