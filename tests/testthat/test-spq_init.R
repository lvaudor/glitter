test_that("formatting works", {
  testthat::expect_snapshot({
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424") %>%
      spq_mutate(narrative_location = wdt::P840(film)) %>%
      spq_label(film, narrative_location) %>%
      spq_count(narrative_location_label, sort = TRUE, name = "n_films")
  })
})

test_that("spq_init() errors for DIY request control", {
  testthat::expect_snapshot({
    spq_init(request_control = list(max_tries = 1L))
  }, error = TRUE)
})

