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
