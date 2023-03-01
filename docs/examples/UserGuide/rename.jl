# Renaming colummns follows the same syntax as in R's `tidyverse`, where the "tidy expression" is `new_name = old_name`. While the main function to rename columns is `@rename()`, you can also use `@select()` if you additionally plan to select only the renamed columns.

using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");

# ## Rename using `@rename()`

# If you only want to rename the columns without selecting them, then this is where `@rename()` comes in handy. For the sake of brevity, we are selecting the first 5 columns and rows after performing the `@rename()`.

@chain movies begin
    @rename(title = Title, Minutes = Length)
    @select(1:5)
    @slice(1:5)
end

# ## Rename using `@select()`

# If you plan to only select those columns that you would like to rename, then you can use `@select()` to *both* rename and select the columns of interest.

@chain movies begin
  @select(title = Title, Minutes = Length)
  @slice(1:5)
end