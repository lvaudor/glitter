# deprecation

    Code
      req <- spq_init(endpoint = "hal") %>% spq_add(
        "haldoc:inria-00362381 dcterms:hasVersion ?version") %>% spq_add(
        "?version ?p ?object") %>% spq_head(5) %>% spq_perform(dry_run = TRUE,
        endpoint = "http://sparql.archives-ouvertes.fr/sparql", user_agent = "bla",
        max_tries = 4, max_seconds = 10, timeout = 20, request_type = "url")
    Condition
      Warning:
      The `endpoint` argument of `spq_perform()` is deprecated as of glitter 0.3.0.
      i Please use the `endpoint` argument of `spq_init()` instead.
      Warning:
      The `user_agent` argument of `spq_perform()` is deprecated as of glitter 0.3.0.
      i Please use the `user_agent` argument of `spq_request_control()` instead.
      i Parameters controlling how the request is made have to be passed to `spq_init()`'s `request_control` argument.
      Warning:
      The `max_tries` argument of `spq_perform()` is deprecated as of glitter 0.3.0.
      i Please use the `max_tries` argument of `spq_request_control()` instead.
      i Parameters controlling how the request is made have to be passed to `spq_init()`'s `request_control` argument.
      Warning:
      The `max_seconds` argument of `spq_perform()` is deprecated as of glitter 0.3.0.
      i Please use the `max_seconds` argument of `spq_request_control()` instead.
      i Parameters controlling how the request is made have to be passed to `spq_init()`'s `request_control` argument.
      Warning:
      The `timeout` argument of `spq_perform()` is deprecated as of glitter 0.3.0.
      i Please use the `timeout` argument of `spq_request_control()` instead.
      i Parameters controlling how the request is made have to be passed to `spq_init()`'s `request_control` argument.
      Warning:
      The `request_type` argument of `spq_perform()` is deprecated as of glitter 0.3.0.
      i Please use the `request_type` argument of `spq_request_control()` instead.
      i Parameters controlling how the request is made have to be passed to `spq_init()`'s `request_control` argument.
    Code
      req$method
    Output
      [1] "POST"

