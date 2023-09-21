test_that("spq_label() works", {
  expect_snapshot(
    spq_init() %>%
      spq_add("?mayor wdt:P31 ?species") %>%
      spq_set(species = c('wd:Q144','wd:Q146', 'wd:Q780')) %>%
      spq_add("?mayor p:P39 ?node") %>%
      spq_add("?node ps:P39 wd:Q30185") %>%
      spq_add("?node pq:P642 ?place") %>%
      spq_label(mayor, place, .languages = "en$")
  )
  expect_snapshot(
    spq_init() %>%
      spq_add("?mayor wdt:P31 ?species") %>%
      spq_set(species = c('wd:Q144','wd:Q146', 'wd:Q780')) %>%
      spq_add("?mayor p:P39 ?node") %>%
      spq_add("?node ps:P39 wd:Q30185") %>%
      spq_add("?node pq:P642 ?place") %>%
      spq_label(mayor, place, .languages = c("fr", "en"))
  )

  httptest2::with_mock_dir(file.path("fixtures", "labels"), {
    tib = spq_init() %>%
      spq_add("?mayor wdt:P31 ?species") %>%
      spq_set(species = c('wd:Q144','wd:Q146', 'wd:Q780')) %>%
      spq_add("?mayor p:P39 ?node") %>%
      spq_add("?node ps:P39 wd:Q30185") %>%
      spq_add("?node pq:P642 ?place") %>%
      spq_label(mayor, place, .languages = c("fr", "en")) %>%
      spq_perform()
  })
  expect_setequal(
    names(tib),
    c("mayor", "node", "place", "species", "mayor_label", "mayor_label_lang",
      "place_label", "place_label_lang")
  )
})

test_that("spq_label() for not rdfs:label", {
  expect_snapshot(
    spq_init(endpoint = "hal") %>%
      spq_add("haldoc:inria-00362381 dcterms:hasVersion ?version") %>%
      spq_add("?version dcterms:type ?type") %>%
      spq_label(type)
  )
})

test_that("spq_label() .overwrite", {

  expect_snapshot(
    spq_init() %>%
      spq_add("?mayor wdt:P31 ?species") %>%
      spq_set(species = c('wd:Q144','wd:Q146', 'wd:Q780')) %>%
      spq_add("?mayor p:P39 ?node") %>%
      spq_add("?node ps:P39 wd:Q30185") %>%
      spq_add("?node pq:P642 ?place") %>%
      spq_label(mayor, place, .languages = "en$", .overwrite = TRUE)
  )
})
