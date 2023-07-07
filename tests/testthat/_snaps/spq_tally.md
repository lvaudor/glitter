# spq_tally() works

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_mutate(
        narrative_location = wdt::P840(film), .label = "?narrative_location") %>%
        spq_tally()
    Output
      
      SELECT (COUNT(*) AS ?n)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?narrative_location.
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424", .label = "?film") %>%
        spq_mutate(narrative_location = wdt::P840(film), .label = "?narrative_location") %>%
        spq_group_by(narrative_locationLabel) %>% spq_tally(sort = TRUE, name = "n_films")
    Output
      
      SELECT ?narrative_locationLabel (COUNT(*) AS ?n_films)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?narrative_location.
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      GROUP BY ?narrative_locationLabel
      ORDER BY DESC(?n_films)

# spq_count() works

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_mutate(
        narrative_location = wdt::P840(film), .label = "?narrative_location") %>%
        spq_count()
    Output
      
      SELECT (COUNT(*) AS ?n)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?narrative_location.
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424", .label = "?film") %>%
        spq_mutate(narrative_location = wdt::P840(film), .label = "?narrative_location") %>%
        spq_count(narrative_locationLabel, sort = TRUE, name = "n_films")
    Output
      
      SELECT ?narrative_locationLabel (COUNT(*) AS ?n_films)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?narrative_location.
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      GROUP BY ?narrative_locationLabel
      ORDER BY DESC(?n_films)

