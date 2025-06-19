# place to put commands

Look at the R packages book to find these [https://r-pkgs.org/](https://r-pkgs.org/) h
# documentation

In R: `devtools::document()` to generate / update the .Rd files for function documentation

# Steps in R

1. use `library(devtools)` to get package functions going
2. Use `load_all()` to get the package functions to load
3. Use `document()` to update roxygen documentation
4. Use `install()` to get the package packaged up


# Steps in Git

1. In the Git terminal, do `cd /c/Projects/ekonomR` (or `cd /path/to/package`)
2. `git add .` to add everything
3. `git commit -m "commit message here"` to specify the commit message
4. `git push -u origin main` to push



# to knit the README file so it can be viewed on Github
# do this in R Console
library(knitr)
knitr::knit(input = "README.Rmd", output = "README.md")

knitr::knit(input = file.path("documentation","documentation.Rmd"), output = file.path("documentation","documentation.md"))


knitr::knit(input = here::here("vignettes","basic-cleaning_wpp.Rmd"), output = here::here("vignettes","basic-cleaning_wpp.md"))

