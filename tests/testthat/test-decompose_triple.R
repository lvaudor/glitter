test_that("decompose_triple works", {
  expect_snapshot(decompose_triple('?athlete rdfs:label "Cristiano Ronaldo"@en'))
})
