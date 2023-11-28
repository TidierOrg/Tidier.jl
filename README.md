# Tidier.jl

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/TidierOrg/Tidier.jl/blob/main/LICENSE)
[![Docs: Latest](https://img.shields.io/badge/Docs-Latest-blue.svg)](https://tidierorg.github.io/Tidier.jl/dev)
[![Build Status](https://github.com/TidierOrg/Tidier.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/TidierOrg/Tidier.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/Tidier&label=Downloads)](https://pkgs.genieframework.com?packages=Tidier)

<a href="https://github.com/TidierOrg/Tidier.jl"><img src="https://raw.githubusercontent.com/TidierOrg/Tidier.jl/main/docs/src/assets/Tidier_jl_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://github.com/TidierOrg/Tidier.jl">Tidier.jl</a>

Tidier.jl is a 100% Julia implementation of the R tidyverse meta-package. Similar to the R tidyverse, Tidier.jl re-exports several other packages, each focusing on a specific set of functionalities.

[[GitHub]](https://github.com/TidierOrg/Tidier.jl) | [[Documentation]](https://tidierorg.github.io/Tidier.jl/dev/)

<br><br>

<a href="https://github.com/TidierOrg/TidierData.jl"><img src="https://raw.githubusercontent.com/TidierOrg/TidierData.jl/main/docs/src/assets/Tidier_jl_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://github.com/TidierOrg/TidierData.jl">TidierData.jl</a>

TidierData.jl is a package dedicated to data transformation and reshaping, powered by DataFrames.jl, ShiftedArrays.jl, and Cleaner.jl. It focuses on functionality within the dplyr, tidyr, and janitor R packages.

[[GitHub]](https://github.com/TidierOrg/TidierData.jl) | [[Documentation]](https://tidierorg.github.io/TidierData.jl/latest/)

<br><br>

<a href="https://github.com/TidierOrg/TidierPlots.jl"><img src="https://raw.githubusercontent.com/TidierOrg/TidierPlots.jl/main/assets/logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://github.com/TidierOrg/TidierPlots.jl">TidierPlots.jl</a>

TidierPlots.jl is a package dedicated to plotting, powered by AlgebraOfGraphics.jl. It focuses on functionality within the ggplot2 R package.

[[GitHub]](https://github.com/TidierOrg/TidierPlots.jl) | [[Documentation]](https://tidierorg.github.io/TidierPlots.jl/latest/)

<br><br>

<a href="https://github.com/TidierOrg/TidierCats.jl"><img src="https://raw.githubusercontent.com/TidierOrg/TidierCats.jl/main/docs/src/assets/TidierCats_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://github.com/TidierOrg/TidierCats.jl">TidierCats.jl</a>

TidierCats.jl is a package dedicated to handling categorical variables, powered by CategoricalArrays.jl. It focuses on functionality within the forcats R package.

[[GitHub]](https://github.com/TidierOrg/TidierCats.jl) | [[Documentation]](https://tidierorg.github.io/TidierCats.jl/dev/)

<br><br>

<a href="https://github.com/TidierOrg/TidierDates.jl"><img src="https://raw.githubusercontent.com/TidierOrg/TidierDates.jl/main/docs/src/assets/TidierDates_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://github.com/TidierOrg/TidierDates.jl">TidierDates.jl</a>

TidierDates.jl is a package dedicated to handling dates and times. It focuses on functionality within the lubridate R package.

[[GitHub]](https://github.com/TidierOrg/TidierCats.jl)

<br><br>

<a href="https://github.com/TidierOrg/TidierStrings.jl"><img src="https://raw.githubusercontent.com/TidierOrg/TidierStrings.jl/main/docs/src/assets/TidierStrings_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://github.com/TidierOrg/TidierStrings.jl">TidierStrings.jl</a>

TidierStrings.jl is a package dedicated to handling strings. It focuses on functionality within the stringr R package.

[[GitHub]](https://github.com/TidierOrg/TidierStrings.jl) | [[Documentation]](https://tidierorg.github.io/TidierStrings.jl/dev/)

<br><br>

<a href="https://github.com/TidierOrg/TidierText.jl"><img src="https://raw.githubusercontent.com/TidierOrg/TidierText.jl/main/docs/src/assets/TidierText_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://github.com/TidierOrg/TidierText.jl">TidierText.jl</a>

TidierText.jl is a package dedicated to handling and tidying text data. It focuses on functionality within the tidytext R package.

[[GitHub]](https://github.com/TidierOrg/TidierText.jl)

<br><br>

<a href="https://github.com/TidierOrg/TidierVest.jl"><img src="https://raw.githubusercontent.com/TidierOrg/TidierVest.jl/main/docs/src/assets/TidierVest_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://github.com/TidierOrg/TidierVest.jl">TidierVest.jl</a>

TidierVest.jl is a package dedicated to scraping and tidying website data. It focuses on functionality within the rvest R package.

[[GitHub]](https://github.com/TidierOrg/TidierVest.jl)

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