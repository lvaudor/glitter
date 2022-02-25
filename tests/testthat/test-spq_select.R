test_that("spq_select works with R syntax", {
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
})

test_that("spq_select works with SPARQL", {
  query <- spq_init()
  expect_snapshot(
    spq_select(query, spq("?lang"), spq("(COUNT(DISTINCT ?article) AS ?count"))
  )
})

test_that("spq_select works with both", {
  query <- spq_init()
  expect_snapshot(
    spq_select(query, lang, spq("(COUNT(DISTINCT ?article) AS ?count"))
  )
})

test_that("spq_select errors well", {
  query <- spq_init()
  expect_snapshot_error(
    spq_select(query, birthyear = year(birthdate, abbreviate = TRUE, translate = FALSE))
  )
  expect_snapshot_error(
    spq_select(query, birthyear = collapse(birthdate))
  )

})
