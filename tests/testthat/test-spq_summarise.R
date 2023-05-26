test_that("spq_summarise() works", {
  expect_snapshot(
    spq_init() %>%
      spq_add("?item wdt:P361 wd:Q297853") %>%
      spq_add("?item wdt:P1082 ?folkm_ngd") %>%
      spq_add("?area wdt:P31 wd:Q1907114", .label = "?area") %>%
      spq_add("?area wdt:P527 ?item") %>%
      spq_group_by(area, areaLabel)  %>%
      spq_summarise(total_folkm = sum(folkm_ngd))
  )

  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424",.label="?film") %>%
      spq_add("?film wdt:P840 ?loc",.label="?loc") %>%
      spq_summarise(n_films=n())
  )

  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424",.label="?film") %>%
      spq_add("?film wdt:P840 ?loc",.label="?loc") %>%
      spq_group_by(loc) %>%
      spq_summarise(n_films=n())
  )
})
