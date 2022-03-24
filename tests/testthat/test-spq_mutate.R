test_that("spq_mutate works", {
  query <- spq_init()
  expect_snapshot(
    query %>%
      spq_add(.triple_pattern = "wd:Q331676 wdt:P1843 ?statement") %>%
      spq_mutate(lang = lang(statement))
  )
})
