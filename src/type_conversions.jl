
function as_float(value)::Union{AbstractFloat, Missing}
    try
        convert(AbstractFloat, value)
    catch
        missing
    end
end

function as_float(value::String)::Union{Float64, Missing}
    try
        parse(Float64, value)
    catch
        missing
    end
end

function as_integer(value)::Union{Integer, Missing}
    try
        convert(Integer, value)
    catch
        missing
    end
end

function as_integer(value::String)::Union{Int64, Missing}
    try
        parse(Int64, value)
    catch
        missing
    end
end

function as_string(value)::String
    string(value)
end