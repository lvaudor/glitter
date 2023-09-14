# httr2 options error

    Code
      spq_control_request(timeout = "ahahah")
    Error <rlang_error>
      Must provide an integer as `timeout`.
      i You provided a "character".

---

    Code
      spq_control_request(max_tries = "ahahah")
    Error <rlang_error>
      Must provide an integer as `max_tries`.
      i You provided a "character".

---

    Code
      spq_control_request(max_seconds = "ahahah")
    Error <rlang_error>
      Must provide an integer as `max_seconds`.
      i You provided a "character".

---

    Code
      spq_control_request(request_type = "ahahah")
    Error <rlang_error>
      `request_type` must be one of "url" or "body-form", not "ahahah".

---

    Code
      spq_control_request(user_agent = 42)
    Error <rlang_error>
      Must provide a character as `user_agent`.

