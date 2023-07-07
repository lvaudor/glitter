test_that("formatting works", {
  testthat::expect_snapshot({
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424",.label="?film") %>%
      spq_mutate(narrative_location = wdt::P840(film), .label = "?narrative_location") %>%
      spq_count(narrative_locationLabel, sort = TRUE, name = "n_films")
  })
})
