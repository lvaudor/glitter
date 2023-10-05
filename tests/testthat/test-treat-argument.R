test_that("spq_treat_argument() errors for no equivalent", {
  expect_snapshot(error = TRUE, {
    spq_treat_argument("something(bla)")
  })
})

test_that("COUNT()", {
  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424") %>%
      spq_mutate(narrative_location = wdt::P840(film)) %>%
      spq_mutate(count = n()) %>%
      spq_select(- film, - narrative_location)
  )
})
