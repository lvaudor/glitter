test_that("build_part_xxx() return strings", {

  x= glitter:::build_part_select(query=NULL,subject="?city",verb="wdt:P625",object="?coords", label="?city")
  expect_true(is.character(x))

  x= glitter:::build_part_body(query=NULL,subject="?city",verb="wdt:P625",object="?coords")
  expect_true(is.character(x))

  x= build_part_service(query=NULL)
  expect_true(is.character(x))

})
