test_that("build_part_body() return strings", {

  x = build_part_body(query=NULL,subject="?city",verb="wdt:P625",object="?coords")
  expect_type(x, "character")

})

test_that("within_distance is not broken", {
  expect_snapshot(
    spq_init() %>%
      spq_add("?city wdt:P31/wdt:P279* wd:Q486972", .label="?city") %>%
      spq_mutate(coords = wdt::P625(city),
        .within_distance=list(center=c(long=4.84,lat=45.76),
          radius=5))
  )
})
