withr::with_dir("vignettes/articles", {
  knitr::knit("glitter_bibliometry.Rmd.orig", output = "glitter_bibliometry.Rmd")
})
