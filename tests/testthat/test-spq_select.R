test_that("spq_select works with R syntax", {
  withr::local_envvar("GLITTER.TESTING.SELECT" = "yep")

  query <- spq_init()

  expect_snapshot(
    spq_select(query, count = n (human), eyecolorLabel, haircolorLabel)
  )

  expect_snapshot(
    spq_select(query, count = n (human), eyecolorLabel, haircolorLabel) %>%
      spq_select(- haircolorLabel)
  )

  expect_snapshot(
    spq_select(query, birthyear = year(birthdate))
  )

  expect_snapshot(
    spq_select(query, lang, count = n(unique(article)))
  )

  expect_snapshot(
    spq_select(query, lang, count = n_distinct(article))
  )

  expect_snapshot(
    spq_select(query, lang, count = n_distinct(article)) %>%
      spq_select(lang)
  )
})

test_that("spq_select works with SPARQL", {
  withr::local_envvar("GLITTER.TESTING.SELECT" = "yep")
  query <- spq_init()
  expect_snapshot(
    spq_select(query, spq("?lang"), spq("(COUNT(DISTINCT ?article) AS ?count"))
  )
})

test_that("spq_select works with both", {
  withr::local_envvar("GLITTER.TESTING.SELECT" = "yep")
  query <- spq_init()
  expect_snapshot(
    spq_select(query, lang, spq("(COUNT(DISTINCT ?article) AS ?count"))
  )
})

test_that("spq_select errors well", {
  withr::local_envvar("GLITTER.TESTING.SELECT" = "yep")

  query <- spq_init()
  expect_snapshot_error(
    spq_select(query, birthyear = year(birthdate, abbreviate = TRUE, translate = FALSE))
  )
  expect_snapshot_error(
    spq_select(query, birthyear = collapse(birthdate))
  )

})

test_that("spq_select can use DISTINCT and REDUCED", {
  withr::local_envvar("GLITTER.TESTING.SELECT" = "yep")

  query <- spq_init()
  expect_snapshot(
    spq_select(query, year, month, day, .spq_duplicate = "distinct")
  )
  expect_snapshot(
    spq_select(query, year, month, day, .spq_duplicate = "reduced")
  )
  expect_snapshot_error(
    spq_select(query, year, month, day, .spq_duplicate = "reduce")
  )

})

test_that("spq_select tells a variable isn't there", {
  expect_snapshot(error = TRUE, {
    spq_init() %>%
      spq_add("?station wdt:P16 wd:Q1552") %>%
      spq_add("?station wdt:P31 wd:Q928830") %>%
      spq_add("?station wdt:P625 ?coords") %>%
      spq_label(station) %>%
      spq_select(station_label, blop)
  })

})
