# httr2 options

    Code
      send_sparql(.query = spq_init() %>% spq_assemble(), timeout = "ahahah")
    Error <rlang_error>
      timeout must be a integer

---

    Code
      send_sparql(.query = spq_init() %>% spq_assemble(), max_tries = "ahahah")
    Error <rlang_error>
      max_tries must be a integer

---

    Code
      send_sparql(.query = spq_init() %>% spq_assemble(), max_seconds = "ahahah")
    Error <rlang_error>
      max_seconds must be a integer

---

    Code
      send_sparql(.query = spq_init() %>% spq_assemble(), request_type = "ahahah")
    Error <rlang_error>
      `request_type` must be one of "url" or "body-form", not "ahahah".

---

    Code
      send_sparql(.query = spq_init() %>% spq_assemble(), user_agent = 42)
    Error <rlang_error>
      user_agent must be a string.

