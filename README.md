# Tidier.jl

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/TidierOrg/Tidier.jl/blob/main/LICENSE)
[![Docs: Latest](https://img.shields.io/badge/Docs-Latest-blue.svg)](https://tidierorg.github.io/Tidier.jl/dev)
[![Build Status](https://github.com/TidierOrg/Tidier.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/TidierOrg/Tidier.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/Tidier&label=Downloads)](https://pkgs.genieframework.com?packages=Tidier)

<a href="https://tidierorg.github.io/Tidier.jl/dev/"><img src="docs/assets/Tidier_jl_logo.png" align="left" style="padding-right:10px"; width="150"></img></a>

## <a href="https://tidierorg.github.io/Tidier.jl/dev/">Tidier.jl</a>

Tidier.jl is a 100% Julia implementation of the R tidyverse meta-package. Similar to the R tidyverse, Tidier.jl re-exports several other packages, each focusing on a specific set of functionalities.

<a href="https://tidierorg.github.io/TidierData.jl/latest/"><img src="https://raw.githubusercontent.com/TidierOrg/TidierData.jl/b3b8886eac075264fe1a6c44894fd8af123ce933/docs/src/assets/Tidier_jl_logo.png" align="left" style="padding-right:10px"; width="150"></img></a>

## <a href="https://tidierorg.github.io/TidierData.jl/latest/">TidierData.jl</a>

TidierData.jl is package dedicated to data transformation and reshaping, powered by DataFrames.jl, ShiftedArrays.jl, and Cleaner.jl. It focuses on functionality within the dplyr, tidyr, and janitor R packages.

<a href="https://github.com/TidierOrg/TidierPlots.jl"><img src="https://raw.githubusercontent.com/TidierOrg/TidierPlots.jl/main/assets/logo.png" align="left" style="padding-right:10px"; width="150"></img></a>

## <a href="https://github.com/TidierOrg/TidierPlots.jl">TidierPlots.jl</a>

TidierPlots.jl is a package dedicated to plotting, powered by AlgebraOfGraphics.jl. It focuses on functionality within the ggplot2 R package.

<a href="https://tidierorg.github.io/TidierCats.jl/dev/"><img src="https://raw.githubusercontent.com/TidierOrg/TidierCats.jl/main/docs/src/assets/TidierCats_logo.png" align="left" style="padding-right:10px"; width="150"></img></a>

## <a href="https://tidierorg.github.io/TidierCats.jl/dev/">TidierCats.jl</a>

TidierCats.jl is a package dedicated to handling categorical variables, powered by CategoricalArrays.jl. It focuses on functionality within the forcats R package.

<a href="https://github.com/TidierOrg/TidierDates.jl"><img src="https://raw.githubusercontent.com/TidierOrg/TidierDates.jl/main/docs/src/assets/TidierDates_logo.png" align="left" style="padding-right:10px"; width="150"></img></a>

## <a href="https://github.com/TidierOrg/TidierDates.jl">TidierDates.jl</a>

TidierDates.jl is a package dedicated to handling dates and times. It focuses on functionality within the lubridate R package.

<a href="https://tidierorg.github.io/TidierStrings.jl/dev/"><img src="https://raw.githubusercontent.com/TidierOrg/TidierStrings.jl/main/docs/src/assets/TidierStrings_logo.png" align="left" style="padding-right:10px"; width="150"></img></a>

## <a href="https://tidierorg.github.io/TidierStrings.jl/dev/">TidierStrings.jl</a>

TidierStrings.jl is a package dedicated to handling strings. It focuses on functionality within the stringr R package.

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