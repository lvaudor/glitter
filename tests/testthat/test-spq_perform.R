test_that("spq_perform() works, replace_prefixes", {
  httptest2::with_mock_dir(file.path("fixtures", "symogih"), {
    tib = spq_init(endpoint = "http://bhp-publi.ish-lyon.cnrs.fr:8888/sparql"
    ) %>%
      spq_prefix(prefixes=c(sym="http://symogih.org/ontology/",
        syr="http://symogih.org/resource/")) %>%
      spq_add("?r sym:associatesObject syr:AbOb213") %>%
      spq_add("?r sym:isComponentOf ?i") %>%
      spq_add("?i sym:knowledgeUnitStandardLabel ?stLabel") %>%
      spq_add(". sym:knowledgeUnitStandardDate ?stDate") %>%
      spq_add(". sym:hasKnowledgeUnitType ?KUTy") %>%
      spq_add("?KUTy rdfs:label ?KUTyLabel") %>%
      spq_head(n=10) %>%
      spq_perform(replace_prefixes = TRUE)
  })
  expect_true(all(grepl("syr\\:", tib[["KUTy"]])))

  httptest2::with_mock_dir(file.path("fixtures", "wikidata_prefixes"), {
    tib=spq_init() %>%
      spq_set(river="wd:Q602") %>%
      spq_add("?river ?p ?o") %>%
      spq_label(p,o) %>%
      spq_head(n=10) %>%
      spq_perform(replace_prefixes=TRUE)
  })
  expect_true(all(grepl("wd\\:", tib[["o"]])))
  expect_true(all(grepl("wdt\\:", tib[["p"]])))
})

