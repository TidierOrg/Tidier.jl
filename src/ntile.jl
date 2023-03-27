# The `ntile()` function is a line-by-line R-to-Julia translation of the
# `dplyr::ntile()` function. We have reproduced the `dplyr` MIT License below.

# MIT License
# Copyright (c) 2023 dplyr authors
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

"""
$docstring_ntile
"""
function ntile(x, n::Integer)
  
  x = if_else.(ismissing.(x), missing, invperm(sortperm(x)))
  x_length = length(x) - sum(ismissing.(x))
  if n <= 0
    throw("`n` must be a positive number.")
  end

  if x_length == 0
    return repeat(missing, length(x)) # need to fix
  else
    n_larger = x_length % n
    n_smaller = n - n_larger
    size = x_length / n
    larger_size = ceil(size)
    smaller_size = floor(size)
    larger_threshold = larger_size * n_larger
    bins = if_else.(x .<= larger_threshold,
                    (x .+ (larger_size - 1)) / larger_size,
                    (x .+ (-larger_threshold + smaller_size - 1)) / smaller_size .+ n_larger)
    return passmissing(convert).(Int, floor.(bins))
  end
end