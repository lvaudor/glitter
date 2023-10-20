# spq_tally() works

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_mutate(
        narrative_location = wdt::P840(film)) %>% spq_label(narrative_location) %>%
        spq_tally()
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT (COUNT(*) AS ?n)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?narrative_location.
      OPTIONAL {
      	?narrative_location rdfs:label ?narrative_location_labell.
      	FILTER(lang(?narrative_location_labell) IN ('en'))
      }
      
      
      }
      

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_mutate(
        narrative_location = wdt::P840(film)) %>% spq_label(narrative_location) %>%
        spq_group_by(narrative_location_label) %>% spq_tally(sort = TRUE, name = "n_films")
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?narrative_location_label (COUNT(*) AS ?n_films)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?narrative_location.
      OPTIONAL {
      	?narrative_location rdfs:label ?narrative_location_labell.
      	FILTER(lang(?narrative_location_labell) IN ('en'))
      }
      
      BIND(COALESCE(?narrative_location_labell,'') AS ?narrative_location_label)
      
      }
      GROUP BY ?narrative_location_label
      ORDER BY DESC(?n_films)

# spq_count() works

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_mutate(
        narrative_location = wdt::P840(film)) %>% spq_label(narrative_location) %>%
        spq_count()
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT (COUNT(*) AS ?n)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?narrative_location.
      OPTIONAL {
      	?narrative_location rdfs:label ?narrative_location_labell.
      	FILTER(lang(?narrative_location_labell) IN ('en'))
      }
      
      
      }
      

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_mutate(
        narrative_location = wdt::P840(film)) %>% spq_label(narrative_location) %>%
        spq_count(narrative_location_label, sort = TRUE, name = "n_films")
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?narrative_location_label (COUNT(*) AS ?n_films)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?narrative_location.
      OPTIONAL {
      	?narrative_location rdfs:label ?narrative_location_labell.
      	FILTER(lang(?narrative_location_labell) IN ('en'))
      }
      
      BIND(COALESCE(?narrative_location_labell,'') AS ?narrative_location_label)
      
      }
      GROUP BY ?narrative_location_label
      ORDER BY DESC(?n_films)

