test_that("spq() works", {
  spq_example = spq("DESC(?length) ?item_label")
  expect_type(spq_example, "character")
  expect_true(is.spq(spq_example))
  expect_false(is.spq("blop"))

  expect_snapshot(spq("DESC(?length) ?item_label"))

  expect_snapshot(error = TRUE, {
    spq(1)
  })

  expect_true(is.spq(spq_example))
  expect_true(is.spq(as.spq("DESC(?length) ?item_label")))
})
