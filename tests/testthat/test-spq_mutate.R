test_that("spq_mutate works", {
  expect_snapshot(
    spq_init() %>%
      spq_mutate(statement = wdt::P1843(wd::Q331676)) %>%
      spq_mutate(lang = lang(statement))
  )
})

test_that("spq_mutate with renaming", {
  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424",.label="film") %>%
      spq_add("?film wdt:P577 ?date") %>%
      spq_mutate(date=year(date)) %>%
      spq_head(10)
  )
})

