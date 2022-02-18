test_that("decompose_triplet works", {
  expect_snapshot(decompose_triplet('?athlete rdfs:label "Cristiano Ronaldo"@en'))
})
