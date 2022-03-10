test_that("spq_group_by works with R syntax", {
  expect_snapshot(
    spq_init() %>%
      spq_select(population, countryLabel) %>%
      spq_group_by(population, countryLabel)
  )
})

test_that("spq_group_by works with R syntax - string", {
  expect_snapshot(
    spq_init() %>%
      spq_select(population, countryLabel) %>%
      spq_group_by("population", "countryLabel")
  )
})
