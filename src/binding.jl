"""
$docstring_bind_rows
"""
macro bind_rows(df, exprs...)
  tidy_exprs = parse_bind_args.(exprs)
  locate_id = findfirst(i -> i[2], tidy_exprs)
  if locate_id isa Nothing
    df_vec = [i[1] for i in tidy_exprs]
    id_expr = nothing
  else
    df_vec = deleteat!([tidy_exprs...], locate_id)
    df_vec = [i[1] for i in df_vec]
    id_expr = tidy_exprs[locate_id][1]
  end

  df_expr = quote
    vcat(DataFrame($(esc(df))), $(df_vec...); cols=:union, source=$id_expr)
  end
  return df_expr
end

"""
$docstring_bind_cols
"""
macro bind_cols(df, exprs...)
  tidy_exprs = parse_bind_args.(exprs)
  df_vec = [i[1] for i in tidy_exprs]

  df_expr = quote
    hcat(DataFrame($(esc(df))), $(df_vec...); makeunique=true)
  end
  return df_expr
end
