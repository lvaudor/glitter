test_that("spq_languages() deprecation", {
  expect_snapshot(
    spq_init() %>%
      spq_language("en")
  )
})
