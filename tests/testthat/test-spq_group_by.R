test_that("spq_group_by works with R syntax", {
  withr::local_envvar("GLITTER.TESTING.SELECT" = "yep")

  expect_snapshot(
    spq_init() %>%
      spq_select(population, countryLabel) %>%
      spq_group_by(population, countryLabel)
  )
})

test_that("spq_group_by works with R syntax - string", {
  withr::local_envvar("GLITTER.TESTING.SELECT" = "yep")

  expect_snapshot(
    spq_init() %>%
      spq_select(population, countryLabel) %>%
      spq_group_by("population", "countryLabel")
  )
})
