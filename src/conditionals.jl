"""
$docstring_if_else
"""
function if_else(condition::Union{Bool,Missing}, yes, no, miss)
    if ismissing(condition)
        return miss
    elseif condition == true
        return yes
    elseif condition == false
        return no
    else
        throw("condition must be a Boolean (true/false/missing).")
    end
end

function if_else(condition::Union{Bool,Missing}, yes, no)
    if ismissing(condition)
        return missing
    elseif condition == true
        return yes
    elseif condition == false
        return no
    else
        throw("condition must be a Boolean (true/false/missing).")
    end
end

"""
$docstring_case_when
"""
function case_when(conditions...)
    for condition in conditions
        if ismissing(condition[1])
            continue
        elseif condition[1]
            return condition[2]
        end
    end
    return missing
end
