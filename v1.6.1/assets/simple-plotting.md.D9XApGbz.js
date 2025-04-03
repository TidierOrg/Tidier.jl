import{_ as i,c as a,o as e,ai as t}from"./chunks/framework.8WgRPCLY.js";const n="/Tidier.jl/v1.6.1/assets/scatter.k2Rr2d-U.png",l="/Tidier.jl/v1.6.1/assets/customized-scatter.DM_YBVUL.png",E=JSON.parse('{"title":"From data to plots","description":"","frontmatter":{},"headers":[],"relativePath":"simple-plotting.md","filePath":"simple-plotting.md","lastUpdated":null}'),p={name:"simple-plotting.md"};function h(o,s,k,d,r,c){return e(),a("div",null,s[0]||(s[0]=[t(`<h1 id="From-data-to-plots" tabindex="-1">From data to plots <a class="header-anchor" href="#From-data-to-plots" aria-label="Permalink to &quot;From data to plots {#From-data-to-plots}&quot;">​</a></h1><h2 id="Exploring-the-penguins-data" tabindex="-1">Exploring the penguins data <a class="header-anchor" href="#Exploring-the-penguins-data" aria-label="Permalink to &quot;Exploring the penguins data {#Exploring-the-penguins-data}&quot;">​</a></h2><p>A very well known dataset in the R community is the <code>palmerpenguins</code> dataset. It contains data about penguins, including their species and some ecological measurements. Let&#39;s load the data and take a look at it.</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Tidier </span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">#exports TidierPlots.jl and others</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> DataFrames</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> PalmerPenguins</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">penguins </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> dropmissing</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">DataFrame</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(PalmerPenguins</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">load</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">()));</span></span></code></pre></div><p>The <code>penguins</code> DataFrame contains the following columns (from <code>TiderData.jl</code> let us take a glimpse):</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">@glimpse</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> penguins</span></span></code></pre></div><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>Rows: 333</span></span>
<span class="line"><span>Columns: 7</span></span>
<span class="line"><span>.species        InlineStrings.String15Adelie, Adelie, Adelie, Adelie, Adelie, Ade</span></span>
<span class="line"><span>.island         InlineStrings.String15Torgersen, Torgersen, Torgersen, Torgersen,</span></span>
<span class="line"><span>.bill_length_mm Float64        39.1, 39.5, 40.3, 36.7, 39.3, 38.9, 39.2, 41.1, 38</span></span>
<span class="line"><span>.bill_depth_mm  Float64        18.7, 17.4, 18.0, 19.3, 20.6, 17.8, 19.6, 17.6, 21</span></span>
<span class="line"><span>.flipper_length _mmInt64          181, 186, 195, 193, 190, 181, 195, 182, 191, 19</span></span>
<span class="line"><span>.body_mass_g    Int64          3750, 3800, 3250, 3450, 3650, 3625, 4675, 3200, 38</span></span>
<span class="line"><span>.sex            InlineStrings.String7male, female, female, female, male, female,</span></span></code></pre></div><h2 id="A-simple-TiderPlots.jl-scatterplot" tabindex="-1">A simple <code>TiderPlots.jl</code> scatterplot <a class="header-anchor" href="#A-simple-TiderPlots.jl-scatterplot" aria-label="Permalink to &quot;A simple \`TiderPlots.jl\` scatterplot {#A-simple-TiderPlots.jl-scatterplot}&quot;">​</a></h2><p>Now the experience to plot using <code>TidierPlots.jl</code> will be as seamless as in R. Let&#39;s start by plotting the <code>bill_length_mm</code> and <code>bill_depth_mm</code> columns.</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">ggplot</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(penguins, </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">@aes</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(x</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">bill_length_mm, y</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">bill_depth_mm, color </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> species))</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">+</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">    geom_point</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">()</span></span></code></pre></div><p><img src="`+n+`" alt=""></p><p>This is <em>not</em> R code, its pure Julia. And if you are familiar with R, you will find it very similar. The <code>ggplot</code> function creates a plot object, and the <code>geom_point</code> function adds a scatter layer on top of it. The <code>@aes</code> macro is used to map the variables of the <code>penguins</code> DataFrame to the aesthetics of the plot. In this case, we are mapping the <code>bill_length_mm</code> column to the x-axis, the <code>bill_depth_mm</code> column to the y-axis, and the <code>species</code> column to the color of the points. The output is a scatter plot of the <code>bill_length_mm</code> and <code>bill_depth_mm</code> columns, colored by the <code>species</code> column.</p><p>Now, <code>@aes()</code> is used to map variables in your data to visual properties (aesthetics) of the plot. These aesthetics can include things like position (x and y coordinates), color, shape, size, etc. Each aesthetic is a way of visualizing a variable or a statistical transformation of a variable.</p><p>Aesthetics are specified in the form aes(aesthetic = variable), where aesthetic is the name of the aesthetic, and variable is the column name in your data that you want to map to the aesthetic. The variable names do not need to be preceded by a colon. This is the first difference you might encounter when using <code>TidierPlots.jl</code>, and the best part is that it also accepts multiple forms for <code>aes</code> specification, none of which is exactly the same as ggplot2.</p><p>Option 1: <code>@aes</code> macro, aes as in ggplot2:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">@aes</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(x </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> x, y </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> y)</span></span></code></pre></div><p>Option 2: <code>@es</code>:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">@es</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(x </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> x, y </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> y)</span></span></code></pre></div><p>Option 3: <code>aes</code> function, julia-style columns:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">aes</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(x </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> :x</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, y </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> :y</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Option 4: <code>aes</code> function, strings for columns:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">aes</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(x </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;x&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, y </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;y&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><h2 id="Customizing-the-plot" tabindex="-1">Customizing the plot <a class="header-anchor" href="#Customizing-the-plot" aria-label="Permalink to &quot;Customizing the plot {#Customizing-the-plot}&quot;">​</a></h2><p>Moving from general rules, to specific plots, let us first explore <code>geom_point()</code></p><p><code>geom_point()</code> is used to create a scatter plot. It is typically used with aesthetics mapping variables to x and y positions, and optionally to other aesthetics like color, shape, and size. <code>geom_point()</code> can be used to visualize the relationship between two continuous variables, or a continuous and a discrete variable. The following visuals features can be changed within geom_point(), shape, size, stroke, strokecolour, and alpha.</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">ggplot</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(penguins, </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">@aes</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(x </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> bill_length_mm, y </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> bill_depth_mm, color </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> species)) </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">+</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">    geom_point</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">( </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        size </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> 20</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        stroke </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> 1</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        strokecolor </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;black&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        alpha </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> 0.2</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">) </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">+</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">    labs</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(x </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;Bill Length (mm)&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, y </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;Bill Width (mm)&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">) </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">+</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">    lims</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(x </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> c</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">40</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">60</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">), y </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> c</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">15</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">20</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)) </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">+</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">    theme_minimal</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">()</span></span></code></pre></div><p><img src="`+l+'" alt=""></p><p>To see more about the <code>TidierPlots.jl</code> package, you can visit the <a href="https://tidierorg.github.io/TidierPlots.jl/latest/" target="_blank" rel="noreferrer">documentation</a>.</p>',28)]))}const y=i(p,[["render",h]]);export{E as __pageData,y as default};
