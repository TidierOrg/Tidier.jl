```@raw html
---
# https://vitepress.dev/reference/default-theme-home-page
layout: home
hero:
  name: "Tidier.jl"
  tagline: Tidier.jl is a data analysis package inspired by R's tidyverse and crafted specifically for Julia.
  image:
    src: /Tidier_jl_logo.png
  actions:
    - theme: brand
      text: Get Started
      link: installation.md
    - theme: alt
      text: View on GitHub
      link: https://github.com/TidierOrg/Tidier.jl
features:

  - icon: <img width="200" height="200" src="https://github.com/TidierOrg/TidierData.jl/raw/main/docs/src/assets/Tidier_jl_logo.png" alt="tidierdata"/>
    title: TidierData.jl
    details: "TidierData.jl is a 100% Julia implementation of the dplyr and tidyr R packages. Powered by the DataFrames.jl package and Julia’s extensive meta-programming capabilities, TidierData.jl is an R user’s love letter to data analysis in Julia." 
    link: https://tidierorg.github.io/TidierData.jl/latest/

  - icon: <img width="200" height="200" src="https://github.com/TidierOrg/TidierPlots.jl/raw/main/assets/logo.png" alt="tidierplots"/>
    title: TidierPlots.jl
    details: "TidierPlots.jl is a 100% Julia implementation of the R package ggplot in Julia. Powered by Makie.jl, and Julia’s extensive meta-programming capabilities, TidierPlots.jl is an R user’s love letter to data visualization in Julia."
    link: https://tidierorg.github.io/TidierPlots.jl/latest/

  - icon: <img width="200" height="200" src="https://github.com/TidierOrg/TidierDB.jl/raw/main/docs/src/assets/logo.png" alt="tidierdb"/>
    title: TidierDB.jl
    details: "TidierDB.jl is a 100% Julia implementation of the R package dbplyr in Julia and similar to Python's ibis package. Its main goal is to bring the syntax of Tidier.jl to multiple SQL backends, making it possible to analyze data directly on databases without needing to copy the entire database into memory."
    link: https://tidierorg.github.io/TidierDB.jl/latest/

  - icon: <img width="200" height="200" src="https://github.com/TidierOrg/TidierFiles.jl/raw/main/docs/src/assets/logo.png" alt="tidierfiles"/>
    title: TidierFiles.jl
    details: "TidierFiles.jl leverages the CSV.jl, XLSX.jl, and ReadStatTables.jl packages to reimplement the R haven and readr packages."
    link: https://tidierorg.github.io/TidierFiles.jl/latest/

  - icon: <img width="200" height="200" src="https://github.com/TidierOrg/TidierCats.jl/raw/main/docs/src/assets/TidierCats_logo.png" alt="tidiercats"/>
    title: TidierCats.jl
    details: "TidierCats.jl is a 100% Julia implementation of the R package forcats in Julia. It has one main goal: to implement forcats's straightforward syntax and of ease of use while working with categorical variables for Julia users."
    link: https://tidierorg.github.io/TidierCats.jl/dev/

  - icon: <img width="200" height="200" src="https://github.com/TidierOrg/TidierDates.jl/raw/main/docs/src/assets/TidierDates_logo.png" alt="tidierdates"/>
    title: TidierDates.jl
    details: "TidierDates.jl is a 100% Julia implementation of the R package lubridate in Julia. It has one main goal: to implement lubridate's straightforward syntax and of ease of use while working with dates for Julia users."
    link: https://tidierorg.github.io/TidierDates.jl/dev/

  - icon: <img width="200" height="200" src="https://github.com/TidierOrg/TidierStrings.jl/raw/main/docs/src/assets/TidierStrings_logo.png" alt="tidierstrings"/>
    title: TidierStrings.jl
    details: "TidierStrings.jl is a 100% Julia implementation of the R package stringr in Julia. It has one main goal: to implement stringr's straightforward syntax and of ease of use while working with strings for Julia users."
    link: https://tidierorg.github.io/TidierStrings.jl/dev/

  - icon: <img width="200" height="200" src="https://raw.githubusercontent.com/TidierOrg/TidierText.jl/main/docs/src/assets/TidierText_logo.png" alt="tidiertext"/>
    title: TidierText.jl
    details: "TidierText.jl is a 100% Julia implementation of the R tidytext package. The purpose of the package is to make it easy analyze text data using DataFrames."
    link: https://github.com/TidierOrg/TidierText.jl

  - icon: <img width="200" height="200" src="https://github.com/TidierOrg/TidierVest.jl/raw/main/docs/src/assets/TidierVest_logo.png" alt="tidiervest"/>
    title: TidierVest.jl
    details: "TidierVest.jl is a package dedicated to scraping and tidying website data. It focuses on functionality within the rvest R package."
    link: https://github.com/TidierOrg/TidierVest.jl


  - icon: <img width="200" height="200" src="https://raw.githubusercontent.com/TidierOrg/TidierIteration.jl/main/docs/assets/logo.png" alt="tidieriteration"/>
    title: TidierIteration.jl
    details: "TidierIteration.jl is a package focused on iterating over Julia collections. It focuses on functionality within the purrr R package."
    link: https://github.com/TidierOrg/TidierIteration.jl
---
```