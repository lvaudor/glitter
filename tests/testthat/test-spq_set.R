test_that("spq_set() works", {
  expect_snapshot(
    spq_init() %>%
      # dog, cat or chicken
      spq_set(species = c('wd:Q144','wd:Q146', 'wd:Q780'), mayorcode = "wd:Q30185")
  )
})

test_that("spq_set() in query", {
  httptest2::with_mock_dir(file.path("fixtures", "auteurset"), {
    tibble = spq_init(request_control = spq_control_request(endpoint = "dataBNF")) %>%
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
