test_that("spq_offset() works", {
  expect_snapshot(
    spq_init() %>%
      spq_add("?item wdt:P31 wd:Q5") %>%
      spq_label(item) %>%
      spq_add("?item wdt:P19/wdt:P131* wd:Q60") %>%
      spq_add("?item wikibase:sitelinks ?linkcount") %>%
      spq_arrange(desc(linkcount)) %>%
      spq_head(42) %>%
      spq_offset(11)
  )
})
