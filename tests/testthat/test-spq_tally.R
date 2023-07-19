test_that("spq_tally() works", {
  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424") %>%
      spq_mutate(narrative_location = wdt::P840(film)) %>%
      spq_label(narrative_location) %>%
      spq_tally()
  )

  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424",.label="?film") %>%
      spq_mutate(narrative_location = wdt::P840(film)) %>%
      spq_label(narrative_location) %>%
      spq_group_by(narrative_location_label) %>%
      spq_tally(sort = TRUE, name = "n_films")
  )
})

test_that("spq_count() works", {
  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424") %>%
      spq_mutate(narrative_location = wdt::P840(film)) %>%
      spq_label(narrative_location) %>%
      spq_count()
  )

  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424",.label="?film") %>%
      spq_mutate(narrative_location = wdt::P840(film)) %>%
      spq_label(narrative_location) %>%
      spq_count(narrative_location_label, sort = TRUE, name = "n_films")
  )
})
