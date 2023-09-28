test_that("transform_wikidata_coords() works", {
  httptest2::with_mock_dir(file.path("fixtures", "coords"), {
  tibble = spq_init() %>%
    spq_add("?city wdt:P31/wdt:P279* wd:Q486972") %>%
    spq_label(city) %>%
    spq_mutate(coords = wdt::P625(city),
      .within_distance=list(center=c(long=4.84,lat=45.76),
        radius=5)) %>%
      spq_head(2) %>%
    spq_perform() %>%
    transform_wikidata_coords("coords")
  })
  expect_true("lat" %in% names(tibble))
  expect_true("lng" %in% names(tibble))
})
