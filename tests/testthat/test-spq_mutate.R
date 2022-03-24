test_that("spq_mutate works", {
  query <- spq_init()
  expect_snapshot(
    query %>%
      spq_mutate(statement = wdt::P1843(wd::Q331676)) %>%
      spq_mutate(lang = lang(statement))
  )
})
