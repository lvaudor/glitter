test_that("send_sparql() returns tibble", {
  expect_false(is_svo_correct("item"))
  expect_true(is_svo_correct("wd:Q33"))
  expect_true(is_svo_correct("?item"))
})
