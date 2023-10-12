test_that("spq_head() works", {
  query = spq_init() %>% spq_head(5)
  expect_equal(query[["limit"]], 5)

  query = spq_init() %>% spq_head(NULL)
  expect_equal(query[["limit"]], NULL)
})
