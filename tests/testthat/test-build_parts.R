test_that("build_part_xxx() return strings", {

  x= build_part_select(NA,subject="?city",verb="wdt:P625",object="?coords", label="?city")
  expect_true(is.character(x))

  x= build_part_body(NA,subject="?city",verb="wdt:P625",object="?coords")
  expect_true(is.character(x))

  x= build_part_service(NA)
  expect_true(is.character(x))

  x=build_part_limit(NA,10)
  expect_true(is.character(x))
})
