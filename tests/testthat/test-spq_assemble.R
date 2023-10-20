test_that("spq_assemble() works - bindings", {
  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424") %>%
      spq_add("?film wdt:P921 ?subject") %>%
      spq_label(subject) %>%
      spq_group_by(film) %>%
      spq_summarise(subject_label_concat=str_c(subject_label,sep="; ")) %>%
      spq_head(10)
  )

  expect_snapshot(
    spq_init() %>%
      spq_add("?item wdt:P31 wd:Q13442814") %>%
      spq_label(item) %>%
      spq_filter(str_detect(str_to_lower(item_label), 'wikidata')) %>%
      spq_head(n = 5)
  )
})


test_that("spq_assemble() detects undefined variables in filter", {
  expect_snapshot({
    spq_init() %>%
      spq_filter(lang(itemTitleLOOKTYPO)=="en") %>%
      spq_assemble()
  }, error = TRUE)
})

test_that("spq_assemble() called from printing isn't strict", {
  expect_snapshot({
    spq_init() %>%
      spq_filter(lang(itemTitleLOOKTYPO)=="en")
  })
})

