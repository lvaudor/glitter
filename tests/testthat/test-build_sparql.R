test_that("build_sparql() works - bindings", {
  expect_snapshot(
    spq_init() %>%
      spq_add("?film wdt:P31 wd:Q11424") %>%
      spq_add("?film wdt:P921 ?subject") %>%
      spq_label(subject) %>%
      spq_group_by(film) %>%
      spq_summarise(subject_label_concat=str_c(subject_label,sep="; ")) %>%
      spq_head(10)
  )
})
