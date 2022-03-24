test_that("spq_filter works with SPARQL syntax", {
  expect_snapshot(
    spq_init() %>%
      spq_add(.triple_pattern = "?item wdt:P31 wd:Q13442814") %>%
      spq_add(.triple_pattern = "?item rdfs:label ?itemTitle") %>%
      spq_filter(spq("CONTAINS(LCASE(?itemTitle),'wikidata')")) %>%
      spq_filter(spq("LANG(?itemTitle)='en'"))
  )
})

test_that("spq_filter works with R DSL", {
  expect_snapshot(
    spq_init() %>%
      spq_add(.triple_pattern = "?item wdt:P31 wd:Q13442814") %>%
      spq_add(.triple_pattern = "?item rdfs:label ?itemTitle") %>%
      spq_filter(str_detect(str_to_lower(itemTitle), "wikidata")) %>%
      spq_filter(lang(itemTitle) == "en")
  )
})

test_that("R-DSL %in%", {
  expect_snapshot(
  spq_init() %>%
    spq_filter(str_to_lower(as.character(scientific_name)) %in% c("lala", "lili"))
  )
})

test_that("R-DSL & and :", {
  expect_snapshot(
  spq_init() %>%
    spq_filter(bound(date) & typeof(date) == xsd:dateTime)
  )
})
