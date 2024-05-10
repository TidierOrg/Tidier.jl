import{_ as e,c as a,o as t,a6 as i}from"./chunks/framework.CC8w3C6l.js";const m=JSON.parse('{"title":"","description":"","frontmatter":{},"headers":[],"relativePath":"faq.md","filePath":"faq.md","lastUpdated":null}'),s={name:"faq.md"},o=i('<h2 id="Frequently-asked-questions" tabindex="-1">Frequently asked questions <a class="header-anchor" href="#Frequently-asked-questions" aria-label="Permalink to &quot;Frequently asked questions {#Frequently-asked-questions}&quot;">​</a></h2><h3 id="I&#39;m-a-Julia-user.-Why-should-I-use-Tidier.jl-rather-than-other-data-analysis-packages?" tabindex="-1">I&#39;m a Julia user. Why should I use Tidier.jl rather than other data analysis packages? <a class="header-anchor" href="#I&#39;m-a-Julia-user.-Why-should-I-use-Tidier.jl-rather-than-other-data-analysis-packages?" aria-label="Permalink to &quot;I&amp;#39;m a Julia user. Why should I use Tidier.jl rather than other data analysis packages? {#I&#39;m-a-Julia-user.-Why-should-I-use-Tidier.jl-rather-than-other-data-analysis-packages?}&quot;">​</a></h3><p>While Julia has a number of great data analysis packages, the most mature and idiomatic Julia package for data analysis is DataFrames.jl. Most other data analysis packages in Julia build on top of DataFrames.jl, and Tidier.jl is no exception.</p><p>DataFrames.jl emphasizes idiomatic Julia code without macros. While it is elegant, it can be verbose because of the need to write out anonymous functions. DataFrames.jl also emphasizes correctness, which means that errors are favored over warnings. For example, grouping by one variable and then subsequently grouping the already-grouped data frame by another variable results in an error in DataFrames.jl. These restrictions, while justified in some instances, can make interactive data analysis feel clunky and slow.</p><p>A number of macro-based data analysis packages have emerged as extensions of DataFrames.jl to make data analysis syntax less verbose, including DataFramesMeta.jl, Query.jl, and DataFrameMacros.jl. All of these packages have their strengths, and each of these served as an inspiration towards the creation of Tidier.jl.</p><p>What sets Tidier.jl apart is that it borrows the design of the tried-and-widely-adopted tidyverse and brings it to Julia. Our goal is to make data analysis code as easy and readable as possible. In our view, the reason you should use Tidier.jl is because of the richness, consistency, and thoroughness of the design made possible by bringing together two powerful tools: DataFrames.jl and the tidyverse. In Tidier.jl, nearly every possible transformation on data frames (e.g., aggregating, pivoting, nesting, and joining) can be accomplished using a consistent syntax. While you always have the option to intermix Tidier.jl code with DataFrames.jl code, Tidier.jl strives for completeness – there should never be a requirement to fall back to DataFrames.jl for any kind of data analysis task.</p><p>Tidier.jl also focuses on conciseness. This shows up most readily in two ways: the use of bare column names, and an approach to auto-vectorizing code.</p><ol><li><p><strong>Bare column names:</strong> If you are referring to a column named <code>a</code>, you can simply refer to it as <code>a</code> in Tidier.jl. You are essentially referring to <code>a</code> as if it was within an anonymous function, where the variable <code>a</code> was mapped to the column <code>a</code> in the data frame. If you want to refer to an object <code>a</code> that is defined outside of the data frame, then you can write <code>!!a</code>, which we refer to as &quot;bang-bang interpolation.&quot; This syntax is motivated by the tidyverse, where <a href="https://adv-r.hadley.nz/quasiquotation.html#the-polite-fiction-of" target="_blank" rel="noreferrer">the <code>!!</code> operator was selected because it is the least-bad &quot;polite fiction&quot; way of representing lazy interpolation</a>.</p></li><li><p><strong>Auto-vectorized code:</strong> Most data transformation functions and operators are intended to be used on scalars. However, transformations are usually performed on columns of data (represented as 1-dimensional arrays, or vectors), which means that most functions need to be vectorized, which can get unwieldy and verbose. However, there are functions which operate directly on vectors and thus should not be vectorized when applied to columns (e.g., <code>mean()</code> and <code>median()</code>). Tidier.jl uses a customizable look-up table to know which functions to vectorize and which ones not to vectorize. This means that you can largely leave code as un-vectorized (i.e., <code>mean(a + 1)</code> rather than <code>mean(a .+ 1)</code>), and Tidier.jl will correctly infer convert the first code into the second before running it. There are several ways to manually override the defaults.</p></li></ol><p>Lastly, the reason you should consider using Tidier.jl is that it brings a consistent syntax not only to data manipulation but also to plotting (by wrapping Makie.jl and AlgebraOfGraphics.jl) and to the handling of categorical variables, strings, and dates. Wherever possible, Tidier.jl uses existing classes rather than defining new ones. As a result, using Tidier.jl should never preclude you from using other Base Julia functions with which you may already be familiar.</p><h3 id="I&#39;m-an-R-user-and-I&#39;m-perfectly-happy-with-the-tidyverse.-Why-should-I-consider-using-Tidier.jl?" tabindex="-1">I&#39;m an R user and I&#39;m perfectly happy with the tidyverse. Why should I consider using Tidier.jl? <a class="header-anchor" href="#I&#39;m-an-R-user-and-I&#39;m-perfectly-happy-with-the-tidyverse.-Why-should-I-consider-using-Tidier.jl?" aria-label="Permalink to &quot;I&amp;#39;m an R user and I&amp;#39;m perfectly happy with the tidyverse. Why should I consider using Tidier.jl? {#I&#39;m-an-R-user-and-I&#39;m-perfectly-happy-with-the-tidyverse.-Why-should-I-consider-using-Tidier.jl?}&quot;">​</a></h3><p>If you&#39;re happy with the R tidyverse, then there&#39;s no imminent reason to switch to using Tidier.jl. While DataFrames.jl (the package on which TidierData.jl depends) <a href="https://duckdblabs.github.io/db-benchmark/" target="_blank" rel="noreferrer">is faster than R&#39;s dplyr and tidyr on benchmarks</a>, there are other faster backends in R that allow for the use of tidyverse syntax with better speed (e.g., dtplyr, tidytable, tidypolars).</p><p>The primary reason to consider using Tidier.jl is the value proposition of using Julia itself. Julia has many similarities to R (e.g., interactive coding in a console, functional style, multiple dispatch, dynamic data types), but unlike R, Julia is automatically compiled (to LLVM) before it runs. This means that certain compiler optimations, which are normally only possible in more verbose languages like C/C++ become available to Julia. There are a number of situations in R where the end-user is able to write fast R code as a direct result of C++ being used on the backend (e.g., through the use of the Rcpp package). This is why R is sometimes referred to as a glue language – because it provides a very nice way of glueing together faster C++ code.</p><p>The main value proposition of Julia is that you can use it as <em>both</em> a glue language <em>and</em> as a backend language. Tidier.jl embraces the glue language aspect of Julia while relying on packages like DataFrames.jl and Makie.jl on the backend.</p><p>While Julia has very mature backends, we hope that Tidier.jl demonstrates the value of, and need for, more glue-oriented data analysis packages in Julia.</p><h3 id="Why-does-Tidier.jl-re-export-so-many-packages?" tabindex="-1">Why does Tidier.jl re-export so many packages? <a class="header-anchor" href="#Why-does-Tidier.jl-re-export-so-many-packages?" aria-label="Permalink to &quot;Why does Tidier.jl re-export so many packages? {#Why-does-Tidier.jl-re-export-so-many-packages?}&quot;">​</a></h3><p>Tidier comes with batteries included. If you are using Tidier, you generally won&#39;t have to load in other packages for basic data analysis. Tidier is meant for interactive use. You can start your code with <code>using Tidier</code> and expect to have what you need at your fingertips.</p><p>If you are a package developer, then you definitely should consider depending on one of the smaller packages that make up Tidier.jl rather than Tidier itself. For example, if you want to use the categorical variable functions from Tidier, then you should use rely on only TidierCats.jl as a dependency.</p><h3 id="Should-I-update-Tidier.jl-or-the-underlying-packages-(e.g.,-TidierPlots.jl)-individually?" tabindex="-1">Should I update Tidier.jl or the underlying packages (e.g., TidierPlots.jl) individually? <a class="header-anchor" href="#Should-I-update-Tidier.jl-or-the-underlying-packages-(e.g.,-TidierPlots.jl)-individually?" aria-label="Permalink to &quot;Should I update Tidier.jl or the underlying packages (e.g., TidierPlots.jl) individually? {#Should-I-update-Tidier.jl-or-the-underlying-packages-(e.g.,-TidierPlots.jl)-individually?}&quot;">​</a></h3><p>Either approach is okay. For most users, we recommend updating Tidier.jl directly, as this will update the underlying packages up to their latest minor versions (but not necessarily up to their latest patch release). However, if you need access to the latest functionality in the underlying packages, you should feel free to update them directly. We will keep Tidier.jl future-proof to underlying package updates, so this shouldn&#39;t cause any problems with Tidier.jl.</p>',19),r=[o];function n(l,d,h,u,c,p){return t(),a("div",null,r)}const g=e(s,[["render",n]]);export{m as __pageData,g as default};
