# formatting works

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424", .label = "?film") %>%
        spq_mutate(narrative_location = wdt::P840(film), .label = "?narrative_location") %>%
        spq_count(narrative_locationLabel, sort = TRUE, name = "n_films")
    Warning <lifecycle_warning_deprecated>
      The `.label` argument of `spq_add()` is deprecated as of glitter 0.2.0.
      i Ability to use `.label` will be dropped in next release, use `spq_label()` instead.
      The `.label` argument of `spq_add()` is deprecated as of glitter 0.2.0.
      i Ability to use `.label` will be dropped in next release, use `spq_label()` instead.
    Output
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT (COUNT(*) AS ?n_films)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      OPTIONAL {
      ?film rdfs:label ?film_labell.
      FILTER(lang(?film_labell) IN ('en'))
      }
      
      ?film wdt:P840 ?narrative_location.
      OPTIONAL {
      ?narrative_location rdfs:label ?narrative_location_labell.
      FILTER(lang(?narrative_location_labell) IN ('en'))
      }
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      GROUP BY ?narrative_locationLabel
      ORDER BY DESC(?n_films)

