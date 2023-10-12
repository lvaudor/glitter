# spq_treat_argument() errors for no equivalent

    Code
      spq_treat_argument("something(bla)")
    Condition
      Error in `spq_translate_dsl()`:
      ! x Can't find SPARQL equivalent for something().
      i If you think there should be one, open an issue in https://github.com/lvaudor/glitter.

# COUNT()

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_mutate(
        narrative_location = wdt::P840(film)) %>% spq_mutate(count = n()) %>%
        spq_select(-film, -narrative_location)
    Output
      
      SELECT (COUNT(*) AS ?count)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?narrative_location.
      
      }
      

