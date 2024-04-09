# Installation

## Installing Tidier.jl

There are 2 ways to install Tidier.jl: using the package console, or using Julia code when you're using the Julia console. You might also see the console referred to as the "REPL," which stands for Read-Evaluate-Print Loop. The REPL is where you can interactively run code and view the output.

Julia's REPL is particularly cool because it provides a built-in package REPL and shell REPL, which allow you to take actions on managing packages (in the case of the package REPL) or run shell commands (in the shell REPL) without ever leaving the Julia REPL.

To install the stable version of Tidier.jl, you can type the following into the Julia REPL:

```julia
]add Tidier
```

The `]` character starts the Julia [package manager](https://docs.julialang.org/en/v1/stdlib/Pkg/). The `add Tidier` command tells the package manager to install the Tidier package from the Julia registry. You can exit the package REPL by pressing the backspace key to return to the Julia prompt.

If you already have the Tidier package installed, the `add Tidier` command *will not* update the package. Instead, you can update the package using the the `update Tidier` (or `up Tidier` for short) commnds. As with the `add Tidier` command, make sure you are in the package REPL before you run these package manager commands.

If you need to (or prefer to) install packages using Julia code, you can achieve the same outcome using the following code to install Tidier:

```julia
import Pkg
Pkg.add("Tidier")
```

You can update Tidier.jl using the `Pkg.update()` function, as follows:

```julia
import Pkg; Pkg.update("Tidier")
```

Note that while Julia allows you to separate statements by using multiple lines of code, you can also use a semi-colon (`;`) to separate multiple statements. This is convenient for short snippets of code. There's another practical reason to use semi-colons in coding, which is to silence the output of a function call. We will come back to this in the "Getting Started" section below.

In general, installing the latest version of the package from the Julia registry should be sufficient because we follow a continuous-release cycle. After every update to the code, we update the version based on the magnitude of the change and then release the latest version to the registry. That's why it's so important to know how to update the package!

However, if for some reason you do want to install the package directly from GitHub, you can get the newest version using either the package REPL...

```julia
]add Tidier#main
```

...or using Julia code.

```julia
import Pkg; Pkg.add(url="https://github.com/TidierOrg/Tidier.jl")

```
