test_that("build_part_xxx() return strings", {

  x = glitter:::build_part_select(query=NULL,subject="?city",verb="wdt:P625",object="?coords", label="?city")
  expect_type(x, "character")

  x = glitter:::build_part_body(query=NULL,subject="?city",verb="wdt:P625",object="?coords")
  expect_type(x, "character")

})
