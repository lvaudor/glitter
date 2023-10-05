# httr2 options error

    Code
      spq_control_request(timeout = "ahahah")
    Condition
      Error in `spq_control_request()`:
      ! Must provide an integer as `timeout`.
      i You provided a "character".

---

    Code
      spq_control_request(max_tries = "ahahah")
    Condition
      Error in `spq_control_request()`:
      ! Must provide an integer as `max_tries`.
      i You provided a "character".

---

    Code
      spq_control_request(max_seconds = "ahahah")
    Condition
      Error in `spq_control_request()`:
      ! Must provide an integer as `max_seconds`.
      i You provided a "character".

---

    Code
      spq_control_request(request_type = "ahahah")
    Condition
      Error in `spq_control_request()`:
      ! `request_type` must be one of "url" or "body-form", not "ahahah".

---

    Code
      spq_control_request(user_agent = 42)
    Condition
      Error in `spq_control_request()`:
      ! Must provide a character as `user_agent`.

