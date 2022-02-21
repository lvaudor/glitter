test_that("send_sparql() returns tibble", {
  skip_if_offline()
  metro_query='SELECT ?item ?itemLabel ?coords
  {
   ?item wdt:P361 wd:Q1552;
   wdt:P625 ?coords.
   OPTIONAL{?item wdt:P1619 ?date.}
   SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
  } ORDER BY ?itemLabel
  LIMIT 3
  '
  x=send_sparql(query=metro_query)
  expect_s3_class(x,"tbl")
})

test_that("send_sparql() works with dataBNF", {
  httptest2::with_mock_dir(file.path("fixtures", "auteurs"), {
    tib = spq_init() %>%
      spq_add("?auteur foaf:birthday ?jour") %>%
      spq_add("?auteur bio:birth ?date1") %>%
      spq_add("?auteur bio:death ?date2") %>%
      spq_add("?auteur foaf:name ?nom", required=FALSE) %>%
      spq_arrange("?jour") %>%
      spq_prefix() %>%
      spq_head(n = 10) %>%
      spq_perform(endpoint = "dataBNF")
  })
  expect_s3_class(tib, "tbl")
  expect_gt(nrow(tib), 2)
})

test_that("send_sparql() works with dbpedia", {
  httptest2::with_mock_dir(file.path("fixtures", "bowie"), {
    tib = spq_init() %>%
      spq_prefix(prefixes=c(dbo="http://dbpedia.org/ontology")) %>%
      spq_add("?person rdfs:label 'David Bowie'@en") %>%
      spq_add("?person ?p ?o") %>%
      spq_head(300) %>%
      spq_perform("dbpedia.org/sparql")
  })
  expect_s3_class(tib, "tbl")
  expect_gt(nrow(tib), 100)
})


test_that("send_sparql() works with SyMoGIH", {
  httptest2::with_mock_dir(file.path("fixtures", "symogih"), {
tib=spq_init() %>%
  spq_prefix(prefixes=c(sym="http://symogih.org/ontology/",
                        syr="http://symogih.org/resource/")) %>%
  spq_add("?r sym:associatesObject syr:AbOb213") %>%
  spq_add("?r sym:isComponentOf ?i") %>%
  spq_add("?i sym:knowledgeUnitStandardLabel ?stLabel") %>%
  spq_add(". sym:knowledgeUnitStandardDate ?stDate") %>%
  spq_add(". sym:hasKnowledgeUnitType ?KUTy") %>%
  spq_add("?KUTy rdfs:label ?KUTyLabel") %>%
  spq_head(n=10) %>%
  spq_perform(endpoint="http://bhp-publi.ish-lyon.cnrs.fr:8888/sparql")
  })
  expect_s3_class(tib, "tbl")
  expect_equal(nrow(tib), 10)
})
