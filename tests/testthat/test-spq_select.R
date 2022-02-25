test_that("spq_select works with R syntax", {
  query <- spq_init()
  expect_snapshot(
    spq_select(query, count = n (human), eyecolorLabel, haircolorLabel)
  )
  expect_snapshot(
    spq_select(query, count = n (human), eyecolorLabel, haircolorLabel) %>%
    spq_select(- haircolorLabel)
  )
  expect_snapshot(
    spq_select(query, birthyear = year(birthdate))
  )
})

test_that("spq_select errors well", {
  query <- spq_init()
  expect_snapshot_error(
    spq_select(query, birthyear = year(birthdate, abbreviate = TRUE, translate = FALSE))
  )
  expect_snapshot_error(
    spq_select(query, birthyear = collapse(birthdate))
  )

})
