test_that("within_distance is not broken", {
  expect_snapshot(
    spq_init() %>%
      spq_add("?city wdt:P31/wdt:P279* wd:Q486972") %>%
      spq_label(city) %>%
      spq_mutate(coords = wdt::P625(city),
        .within_distance=list(center=c(long=4.84,lat=45.76),
          radius=5))
  )
})
