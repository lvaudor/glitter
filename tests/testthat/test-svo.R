test_that("is_svo_correct() works", {
  expect_false(is_svo_correct("item"))
  expect_true(is_svo_correct("wd:Q33"))
  expect_true(is_svo_correct("?item"))
})
