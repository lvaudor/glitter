test_that("httr2 options error", {
  expect_snapshot(
    spq_control_request(timeout = "ahahah"),
    error = TRUE
  )
  expect_snapshot(
    spq_control_request(max_tries = "ahahah"),
    error = TRUE
  )
  expect_snapshot(
    spq_control_request(max_seconds = "ahahah"),
    error = TRUE
  )
  expect_snapshot(
    spq_control_request(request_type = "ahahah"),
    error = TRUE
  )
  expect_snapshot(
    spq_control_request(user_agent = 42),
    error = TRUE
  )
})
