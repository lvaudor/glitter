test_that("send_sparql() returns tibble", {
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
