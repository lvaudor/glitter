test_that("spq_arrange works with R syntax", {
  query <- spq_init()
  expect_snapshot(
    spq_arrange(query, desc(length), itemLabel)
  )
})

test_that("spq_arrange works with SPARQL syntax", {
  query <- spq_init()
  expect_snapshot(
    spq_arrange(query, "DESC(?length) ?itemLabel")
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
    spq_arrange(query, "DESC(xsd:integer(?mort))")
  )
})

