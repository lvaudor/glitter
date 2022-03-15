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
    spq_arrange(query, desc(as.integer(mort)))
  )
})


test_that("spq_arrange works with SPARQL syntax", {
  query <- spq_init()
  expect_snapshot(
    spq_arrange(query, spq("DESC(xsd:integer(?mort))"))
  )
})


test_that("spq_arrange works with a mix", {
  query <- spq_init()
  expect_snapshot(
    spq_arrange(query, spq("DESC(xsd:integer(?mort))"), vie)
  )
})

test_that("spq_arrange works when using objects for spq()", {
  query <- spq_init()
  expect_snapshot({
    var <- "length"
    arranging_stuff <- sprintf("DESC(?%s) ?itemLabel", var)
    spq_arrange(query, spq(arranging_stuff))
  })
})


test_that("spq_arrange works if passing a string directly", {
  query <- spq_init()
  expect_snapshot({
    spq_arrange(query, "desc(length)")

  })
})

test_that("spq_arrange does not error if passing sthg that could be evaluated", {
  query <- spq_init()
  expect_snapshot({
    var <- c(1, 1)
    spq_arrange(query, str_to_lower(var))
  })
})
