test_that("spq_arrange works with R syntax", {
  query <- spq_init()
  expect_snapshot(
    spq_arrange(query, desc(length), itemLabel)
  )
})

test_that("spq_arrange works with SPARQL syntax", {
  query <- spq_init()
  expect_snapshot(
    spq_arrange(query, spq("DESC(?length) ?itemLabel"))
  )
})

test_that("spq_arrange works with R syntax", {
  query <- spq_init()
  expect_snapshot(
    spq_arrange(query, desc(xsd:integer(mort)))
  )
})


test_that("spq_arrange works with SPARQL syntax", {
  query <- spq_init()
  expect_snapshot(
    spq_arrange(query, spq("DESC(xsd:integer(?mort))"))
  )
})


test_that("spq_arrange errors if passing a string directly", {
  query <- spq_init()
  expect_snapshot_error(
    spq_arrange(query, "DESC(xsd:integer(?mort))")
  )
})
