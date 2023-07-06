test_that("spq_mutate works", {
  expect_snapshot(
    spq_init() %>%
      spq_mutate(statement = wdt::P1843(wd::Q331676)) %>%
      spq_mutate(lang = lang(statement))
  )
})
