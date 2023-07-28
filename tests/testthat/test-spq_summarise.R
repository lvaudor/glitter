test_that("spq_summarise() works", {
  expect_snapshot(
    spq_init() %>%
      spq_add("?item wdt:P361 wd:Q297853") %>%
      spq_add("?item wdt:P1082 ?folkm_ngd") %>%
      spq_add("?area wdt:P31 wd:Q1907114") %>%
      spq_label(area) %>%
      spq_add("?area wdt:P527 ?item") %>%
      spq_group_by(area, area_label)  %>%
      spq_summarise(total_folkm = sum(folkm_ngd))
  )

  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424") %>%
      spq_add("?film wdt:P840 ?loc") %>%
      spq_label(film, loc) %>%
      spq_summarise(n_films=n())
  )

  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424") %>%
      spq_add("?film wdt:P840 ?loc") %>%
      spq_label(film, loc) %>%
      spq_group_by(loc) %>%
      spq_summarise(n_films=n())
  )

  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424") %>%
      spq_add("?film wdt:P577 ?date") %>%
      spq_mutate(year = year(date)) %>%
      spq_group_by(year) %>%
      spq_summarise(n_films = n(), one_film = sample(film)) %>%
      spq_head(10)
  )

  expect_snapshot(

    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424") %>%
      spq_add("?film wdt:P840 ?loc") %>%
      spq_summarise(n_films = n())
  )
})

test_that("spq_summarize() works with renaming", {
  expect_snapshot(
    spq_init() %>%
      spq_add("?item wdt:P361 wd:Q297853") %>%
      spq_add("?item wdt:P1082 ?folkm_ngd") %>%
      spq_add("?area wdt:P31 wd:Q1907114") %>%
      spq_label(area) %>%
      spq_add("?area wdt:P527 ?item") %>%
      spq_group_by(area, area_label)  %>%
      spq_summarise(folkm_ngd = sum(folkm_ngd))
  )

  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424") %>%
      spq_add("?film wdt:P840 ?loc") %>%
      spq_add("?film wdt:P577 ?date") %>%
      spq_mutate(year=year(date)) %>%
      spq_mutate(year = min(year)) %>%
      spq_group_by(loc, year) %>%
      spq_summarize(n_films = n())
  )

  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424") %>%
      spq_head(10) %>%
      spq_add("?film wdt:P577 ?date") %>%
      spq_mutate(year = year(date)) %>%
      spq_group_by(filmLabel,loc) %>%
      spq_summarise(year = min(year))
  )
})
