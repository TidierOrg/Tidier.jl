# This file is intended for any catch-all helper functions that don't deserve
# their own documentation page and don't have any outside licenses.

# Need to expand with docs
# These are just aliases
starts_with(args...) = startswith(args...)
ends_with(args...) = endswith(args...)
matches(pattern, flags...) = Regex(pattern, flags...)