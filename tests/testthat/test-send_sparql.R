test_that("send_sparql() returns tibble", {
  httptest2::with_mock_dir(file.path("fixtures", "coords"), {
    x = spq_init() %>%
    spq_add("?city wdt:P31/wdt:P279* wd:Q486972") %>%
    spq_label(city) %>%
    spq_mutate(coords = wdt::P625(city),
      .within_distance=list(center=c(long=4.84,lat=45.76),
        radius=5)) %>%
      spq_head(2) %>%
    spq_perform()
  })
  expect_s3_class(x,"tbl")
})

test_that("send_sparql() works with dataBNF", {
  httptest2::with_mock_dir(file.path("fixtures", "auteurs"), {
    tib = spq_init(endpoint = "dataBNF") %>%
      spq_add("?auteur foaf:birthday ?jour") %>%
      spq_add("?auteur bio:birth ?date1") %>%
      spq_add("?auteur bio:death ?date2") %>%
      spq_add("?auteur foaf:name ?nom", .required=FALSE) %>%
      spq_arrange(jour) %>%
      spq_prefix() %>%
      spq_head(n = 10) %>%
      spq_perform()
  })
  expect_s3_class(tib, "tbl")
  expect_gt(nrow(tib), 2)
})

test_that("send_sparql() works with dbpedia", {
  httptest2::with_mock_dir(file.path("fixtures", "bowie"), {
    tib = spq_init(endpoint = "dbpedia") %>%
      spq_prefix(prefixes=c(dbo="http://dbpedia.org/ontology")) %>%
      spq_add("?person rdfs:label 'David Bowie'@en") %>%
      spq_add("?person ?p ?o") %>%
      spq_head(300) %>%
      spq_perform()
  })
  expect_s3_class(tib, "tbl")
  expect_gt(nrow(tib), 100)
})


test_that("send_sparql() works with SyMoGIH", {
  httptest2::with_mock_dir(file.path("fixtures", "symogih"), {
    tib=spq_init(endpoint = "http://bhp-publi.ish-lyon.cnrs.fr:8888/sparql") %>%
      spq_prefix(prefixes=c(sym="http://symogih.org/ontology/",
        syr="http://symogih.org/resource/")) %>%
      spq_add("?r sym:associatesObject syr:AbOb213") %>%
      spq_add("?r sym:isComponentOf ?i") %>%
      spq_add("?i sym:knowledgeUnitStandardLabel ?stLabel") %>%
      spq_add(". sym:knowledgeUnitStandardDate ?stDate") %>%
      spq_add(". sym:hasKnowledgeUnitType ?KUTy") %>%
      spq_add("?KUTy rdfs:label ?KUTyLabel") %>%
      spq_head(n=10) %>%
      spq_perform()
  })
  expect_s3_class(tib, "tbl")
  expect_equal(nrow(tib), 10)
})

test_that("send_sparql() works with HAL query that mixes things", {
  httptest2::with_mock_dir(file.path("fixtures", "versions"), {
    tib = spq_init(endpoint = "hal") %>%
      spq_add("haldoc:inria-00362381 dcterms:hasVersion ?version") %>%
      spq_add("?version ?p ?object") %>%
      spq_head(5) %>%
      spq_perform()
  })
  expect_s3_class(tib, "tbl")
  expect_equal(nrow(tib), 5)
})
test_that("httr2 options", {

  skip_if_not_installed("httpuv")

  custom_ua_query = spq_init(
    endpoint = "http://example.com",
    spq_control_request(user_agent = "lalala")
  ) %>%
    spq_perform(dry_run = TRUE)
  expect_equal(custom_ua_query[["headers"]][["user-agent"]], "lalala")

  expect_equal(
    custom_ua_query[["headers"]][["host"]],
    "example.com?query=%0ASELECT%20%2A%0AWHERE%20%7B%0A%0A%0A%7D%0A%0A"
  )

  body_form_query = spq_init(
    endpoint = "http://example.com",
    request_control = spq_control_request(request_type = "body-form")
  ) %>%
    spq_perform(dry_run = TRUE)
  expect_equal(body_form_query[["headers"]][["host"]], "example.com")
  expect_equal(body_form_query[["headers"]][["content-length"]], "53")
  expect_equal(body_form_query[["headers"]][["content-type"]], "application/x-www-form-urlencoded")
})
