# notes to maintain documentation

- built with [Documenter](https://juliadocs.github.io/Documenter.jl)
  using Paul Bastide's [fork](https://github.com/pbastide/Documenter.jl)
  to have the flexibility to avoid committing new figures (see below)
- deployed [here](http://crsl4.github.io/PhyloNetworks.jl/)
  (go to `latest/` or `stable/`)
  using github and files committed to the `gh-pages` branch.

## how it works: overview

- `.travis.yml` asks to run `docs/make.jl` after a successful test & build.
- the julia script `docs/make.jl` has 3 steps:
  1. run `docs/src/man/src/make_weave.jl` to
     [Weave](http://weavejl.mpastell.com/stable/) the `.jmd` files
     in `docs/src/man/src/*.jmd`: turns them into markdown files placed in
     `docs/src/man/*.md`, that contain the input & output of julia code.
  2. run `makedocs()` from `Documenter`: make the documentation
  3. run `deploydocs(...)` also from Documenter. This step calls `mkdocs`,
     which turns the markdown files in `docs/.../*.md` into html files.

## about julia markdown

- The `.jmd` files that are weaved into `.md` files
  are listed in `docs/src/man/src/make_weave.jl`:
  **add** to this list any new `.jmd` file that needs to be added to the manual.
- `.jmd` is similar to `.Rmd`: we can choose which julia chunks to eval, echo,
  show as in the REPL (`term=true`) etc.
- the default chunk options are defined on line 3 of
  `docs/src/man/src/make_weave.jl`: unlike in Rstudio,
  the defaults here are `results="hidden"` and `eval=false`,
  so that a `{julia}` chunk won't be evaluated. Just the input code will be shown.
  To run the chunk and show both input and output, use:

  `{julia; eval=true; results="markup"; term=true}`

  for REPL display, or

  `{julia; eval=true; results="markup";}`

  to show output separately from input.

## figures

- all figures produced by the code are placed in `docs/assets/figures`.
  `mkdocs` exports all files in `docs/assets` during the publishing;
  they are tracked on the `gh-pages` branch (not on `master`).
- the chunk label determines the name of any files
  that the chunk will create if one or more figures are drawn.
  Figures are tracked by git,
  so it's best to control the name of the files being created. example:

  `{julia; eval=true; label="truenet_opt"; fig_width=4; fig_height=4}`

- `.travis.yml` defines an environment variable: `DRAW_FIG`.
  If `"false"`, any figure produced during weaving of the jmd files
  are suppressed from the commit (see Paul Bastide's `/src/Documenter.jl`
  [here](https://github.com/pbastide/Documenter.jl/blob/master/src/Documenter.jl#L356)
  for instance), to avoid tracking unimportant changes to `png` or `pdf` images.
