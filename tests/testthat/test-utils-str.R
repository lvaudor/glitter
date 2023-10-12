test_that("is_svo_correct() works", {
  expect_false(is_svo_correct("item"))
  expect_true(is_svo_correct("wd:Q33"))
  expect_true(is_svo_correct("?item"))
})

test_that("check_prefix() errors well", {
  expect_snapshot(error = TRUE, {
    check_prefix("blop", usual_prefixes)
  })
})
