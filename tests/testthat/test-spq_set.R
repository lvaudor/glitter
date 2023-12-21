test_that("spq_set() works", {
  expect_snapshot(
    spq_init() %>%
      # dog, cat or chicken
      spq_set(species = c('wd:Q144','wd:Q146', 'wd:Q780'), mayorcode = "wd:Q30185")
  )
})

test_that("spq_set() works with URLs", {
  expect_snapshot(
    spq_init() %>%
      # dog, cat or chicken
      spq_set(species = c(
    'https://www.wikidata.org/entity/Q144',
    'https://www.wikidata.org/entity/Q146',
    'https://www.wikidata.org/entity/Q780'
  ), mayorcode = "wd:Q30185")
  )
})


test_that("spq_set() in two examples", {
  expect_snapshot(
    spq_init() %>%
      spq_prefix(prefixes = c(schema = "http://schema.org/")) %>%
      spq_set(lemma = c(
        "'Wikipedia'@de",
        "'Wikidata'@de",
        "'Berlin'@de",
        "'Technische Universität Berlin'@de"
      )
      ) %>%
      spq_add("?sitelink schema:about ?item") %>%
      spq_add("?sitelink schema:isPartOf <https://de.wikipedia.org/>") %>%
      spq_add("?sitelink schema:name ?lemma") %>%
      spq_select(lemma, item)
  )

  expect_snapshot(
    spq_init() %>%
      spq_prefix(prefixes = c(schema = "http://schema.org/")) %>%
      spq_set(lemma = c(
        "'Wikipedia'@de",
        "'Wikidata'@de",
        "'Berlin'@de",
        "'Technische Universität Berlin'@de"
      )
      ) %>%
      spq_mutate(item = schema::about(sitelink)) %>%
      spq_add("?sitelink schema:isPartOf <https://de.wikipedia.org/>") %>%
      spq_mutate(lemma = schema::name(sitelink)) %>%
      spq_select(lemma, item)
  )
})

test_that("spq_set() in query", {
  httptest2::with_mock_dir(file.path("fixtures", "auteurset"), {
    tibble = spq_init(endpoint = "dataBNF") %>%
      spq_set(anniv = "foaf:birthday") %>%
      spq_add("?auteur ?anniv ?jour") %>%
      spq_add("?auteur bio:birth ?date1") %>%
      spq_add("?auteur bio:death ?date2") %>%
      spq_add("?auteur foaf:name ?nom", .required=FALSE) %>%
      spq_arrange(jour) %>%
      spq_prefix() %>%
      spq_head(n = 10) %>%
      spq_perform()
  })
  expect_s3_class(tibble, "tbl_df")
  expect_setequal(
    names(tibble),
    c("anniv", "auteur", "date1", "date2", "jour", "nom")
  )
})
