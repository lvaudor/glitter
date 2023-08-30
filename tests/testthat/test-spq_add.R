test_that("spq_add() works, double variable", {
  expect_snapshot(
    spq_init() %>%
      spq_add(spq("?software p:P348/pq:P577 ?date"))
  )
})

test_that("spq_add() works, trailing period", {
  expect_snapshot(
    spq_init() %>%
      spq_add(spq("?software pq:P577 ?date."))
  )
})
