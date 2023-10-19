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

test_that("spq_label() .languages = NULL", {
  expect_snapshot(
    spq_init(endpoint = "hal") %>%
      spq_add("?labo dcterms:identifier ?labo_id", .required = FALSE) %>%
      spq_label(labo, .languages = NULL, .required = TRUE) %>%
      spq_filter(str_detect(labo_label,"EVS|(UMR 5600)|(Environnement Ville Soc)"))
  )
})


test_that("spq_label() for optional thing", {
  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424") %>%
      spq_add("?film wdt:P840 ?loc") %>%
      spq_add("?loc wdt:P625 ?coords") %>%
      spq_add("?film wdt:P3383 ?image") %>%
      spq_add("?film wdt:P921 ?subject", .required=FALSE) %>%
      spq_add("?film wdt:P577 ?date") %>%
      spq_label(film,loc,subject) %>%
      spq_head(10)
  )

    expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424") %>%
      spq_add("?film wdt:P840 ?loc") %>%
      spq_add("?loc wdt:P625 ?coords") %>%
      spq_add("?film wdt:P3383 ?image") %>%
      spq_add("?film wdt:P921 ?subject", .required=FALSE) %>%
      spq_add("?film wdt:P577 ?date") %>%
      spq_label(film,loc,subject, .required = TRUE) %>%
      spq_head(10)
  )
})
