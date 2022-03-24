test_that("decompose_triple_pattern works", {
  expect_snapshot(decompose_triple_pattern('?athlete rdfs:label "Cristiano Ronaldo"@en'))
})
