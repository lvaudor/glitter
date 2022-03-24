test_that("spq_arrange works with R syntax", {
  expect_snapshot(
    spq_arrange(spq_init(), desc(length), itemLabel)
  )
})

test_that("spq_arrange works with SPARQL syntax", {
  expect_snapshot(
    spq_arrange(spq_init(), spq("DESC(?length) ?itemLabel"))
  )
})

test_that("spq_arrange works with R syntax", {
  expect_snapshot(
    spq_arrange(spq_init(), desc(as.integer(mort)))
  )
})


test_that("spq_arrange works with SPARQL syntax", {
  expect_snapshot(
    spq_arrange(spq_init(), spq("DESC(xsd:integer(?mort))"))
  )
})


test_that("spq_arrange works with a mix", {
  expect_snapshot(
    spq_arrange(spq_init(), spq("DESC(xsd:integer(?mort))"), vie)
  )
})

test_that("spq_arrange works when using objects for spq()", {
  expect_snapshot({
    var <- "length"
    arranging_stuff <- sprintf("DESC(?%s) ?itemLabel", var)
    spq_arrange(spq_init(), spq(arranging_stuff))
  })
})


test_that("spq_arrange works if passing a string directly", {
  expect_snapshot({
    spq_arrange(spq_init(), "desc(length)")

  })
})

test_that("spq_arrange does not error if passing sthg that could be evaluated", {
  expect_snapshot({
    var <- c(1, 1)
    spq_arrange(spq_init(), str_to_lower(var))
  })
})
