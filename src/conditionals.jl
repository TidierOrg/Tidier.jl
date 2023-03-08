function if_else(condition::Union{Bool, Missing}, yes, no, miss)
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

function if_else(condition::Union{Bool, Missing}, yes, no)
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

# a = 1:10
# case_when and => get auto-vectorized
# case_when.(true .=> "hello", true .=> "false")
# Examples:
# case_when.(a .>= 3 .=> "yes") # remainder are missing
# case_when.(a .>= 3 .=> "yes", true .=> "no")
function case_when(conditions...)
  for condition in conditions
    if condition[1]
      return condition[2]
    end
  end
  return missing
end

