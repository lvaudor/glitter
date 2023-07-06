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
