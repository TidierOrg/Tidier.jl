<a href="https://tidierorg.github.io/Tidier.jl/dev/"><img src="https://raw.githubusercontent.com/TidierOrg/Tidier.jl/main/docs/src/assets/Tidier\_jl\_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://tidierorg.github.io/Tidier.jl/dev/">Tidier.jl</a>

Tidier.jl is a 100% Julia implementation of the R tidyverse meta-package. Similar to the R tidyverse, Tidier.jl re-exports several other packages, each focusing on a specific set of functionalities.

<br><br>

<a href="https://tidierorg.github.io/TidierData.jl/latest/"><img src="https://raw.githubusercontent.com/TidierOrg/TidierData.jl/main/docs/src/assets/Tidier\_jl\_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://tidierorg.github.io/TidierData.jl/latest/">TidierData.jl</a>

TidierData.jl is a package dedicated to data transformation and reshaping, powered by DataFrames.jl, ShiftedArrays.jl, and Cleaner.jl. It focuses on functionality within the dplyr, tidyr, and janitor R packages.

<br><br>

<a href="https://github.com/TidierOrg/TidierPlots.jl"><img src="https://raw.githubusercontent.com/TidierOrg/TidierPlots.jl/main/assets/logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://github.com/TidierOrg/TidierPlots.jl">TidierPlots.jl</a>

TidierPlots.jl is a package dedicated to plotting, powered by AlgebraOfGraphics.jl. It focuses on functionality within the ggplot2 R package.

<br><br>

<a href="https://tidierorg.github.io/TidierCats.jl/dev/"><img src="https://raw.githubusercontent.com/TidierOrg/TidierCats.jl/main/docs/src/assets/TidierCats\_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://tidierorg.github.io/TidierCats.jl/dev/">TidierCats.jl</a>

TidierCats.jl is a package dedicated to handling categorical variables, powered by CategoricalArrays.jl. It focuses on functionality within the forcats R package.

<br><br>

<a href="https://github.com/TidierOrg/TidierDates.jl"><img src="https://raw.githubusercontent.com/TidierOrg/TidierDates.jl/main/docs/src/assets/TidierDates\_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://github.com/TidierOrg/TidierDates.jl">TidierDates.jl</a>

TidierDates.jl is a package dedicated to handling dates and times. It focuses on functionality within the lubridate R package.

<br><br>

<a href="https://tidierorg.github.io/TidierStrings.jl/dev/"><img src="https://raw.githubusercontent.com/TidierOrg/TidierStrings.jl/main/docs/src/assets/TidierStrings\_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://tidierorg.github.io/TidierStrings.jl/dev/">TidierStrings.jl</a>

TidierStrings.jl is a package dedicated to handling strings. It focuses on functionality within the stringr R package.

<br><br>

## Installation

For the stable version:

```
] add Tidier
```

The `]` character starts the Julia [package manager](https://docs.julialang.org/en/v1/stdlib/Pkg/). Press the backspace key to return to the Julia prompt.

or


```julia
using Pkg
Pkg.add("Tidier")
```

For the newest version:

```
] add Tidier#main
```

or

```julia
using Pkg
Pkg.add(url="https://github.com/TidierOrg/Tidier.jl")
```

## What’s new

See [NEWS.md](https://github.com/TidierOrg/Tidier.jl/blob/main/NEWS.md) for the latest updates.

## What's missing

Is there a tidyverse feature missing that you would like to see in Tidier.jl? Please file a GitHub issue.