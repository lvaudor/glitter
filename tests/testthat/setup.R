library(httptest2)
expect_snapshot <- function(...) {
  withr::local_envvar("GLITTER.NOCLI" = "blop")
  testthat::expect_snapshot(...)
}

