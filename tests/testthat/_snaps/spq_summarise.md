# spq_summarise() works

    Code
      spq_init() %>% spq_add("?item wdt:P361 wd:Q297853") %>% spq_add(
        "?item wdt:P1082 ?folkm_ngd") %>% spq_add("?area wdt:P31 wd:Q1907114") %>%
        spq_label(area) %>% spq_add("?area wdt:P527 ?item") %>% spq_group_by(area,
        area_label) %>% spq_summarise(total_folkm = sum(folkm_ngd))
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?area ?area_label (SUM(?folkm_ngd) AS ?total_folkm)
      WHERE {
      
      ?item wdt:P361 wd:Q297853.
      ?item wdt:P1082 ?folkm_ngd.
      ?area wdt:P31 wd:Q1907114.
      OPTIONAL {
      	?area rdfs:label ?area_labell.
      	FILTER(lang(?area_labell) IN ('en'))
      }
      
      ?area wdt:P527 ?item.
      BIND(COALESCE(?area_labell,'') AS ?area_label)
      
      }
      GROUP BY ?area ?area_label
      

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_add(
        "?film wdt:P840 ?loc") %>% spq_label(film, loc) %>% spq_summarise(n_films = n())
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT (COUNT(*) AS ?n_films)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?loc.
      OPTIONAL {
      	?film rdfs:label ?film_labell.
      	FILTER(lang(?film_labell) IN ('en'))
      }
      
      OPTIONAL {
      	?loc rdfs:label ?loc_labell.
      	FILTER(lang(?loc_labell) IN ('en'))
      }
      
      
      }
      

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_add(
        "?film wdt:P840 ?loc") %>% spq_label(film, loc) %>% spq_group_by(loc) %>%
        spq_summarise(n_films = n())
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?loc (COUNT(*) AS ?n_films)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?loc.
      OPTIONAL {
      	?film rdfs:label ?film_labell.
      	FILTER(lang(?film_labell) IN ('en'))
      }
      
      OPTIONAL {
      	?loc rdfs:label ?loc_labell.
      	FILTER(lang(?loc_labell) IN ('en'))
      }
      
      
      }
      GROUP BY ?loc
      

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_add(
        "?film wdt:P577 ?date") %>% spq_mutate(year = year(date)) %>% spq_group_by(
        year) %>% spq_summarise(n_films = n(), one_film = sample(film)) %>% spq_head(
        10)
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      SELECT ?year (COUNT(*) AS ?n_films) (SAMPLE(?film) AS ?one_film)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P577 ?date.
      BIND(YEAR(?date) AS ?year)
      
      }
      GROUP BY ?year
      
      LIMIT 10

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_add(
        "?film wdt:P840 ?loc") %>% spq_summarise(n_films = n())
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      SELECT (COUNT(*) AS ?n_films)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?loc.
      
      }
      

# spq_summarize() works with renaming

    Code
      spq_init() %>% spq_add("?item wdt:P361 wd:Q297853") %>% spq_add(
        "?item wdt:P1082 ?folkm_ngd") %>% spq_add("?area wdt:P31 wd:Q1907114") %>%
        spq_label(area) %>% spq_add("?area wdt:P527 ?item") %>% spq_group_by(area,
        area_label) %>% spq_summarise(folkm_ngd = sum(folkm_ngd))
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?area ?area_label (SUM(?folkm_ngd0) AS ?folkm_ngd)
      WHERE {
      
      ?item wdt:P361 wd:Q297853.
      ?item wdt:P1082 ?folkm_ngd0.
      ?area wdt:P31 wd:Q1907114.
      OPTIONAL {
      	?area rdfs:label ?area_labell.
      	FILTER(lang(?area_labell) IN ('en'))
      }
      
      ?area wdt:P527 ?item.
      BIND(COALESCE(?area_labell,'') AS ?area_label)
      
      }
      GROUP BY ?area ?area_label
      

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_add(
        "?film wdt:P840 ?loc") %>% spq_add("?film wdt:P577 ?date") %>% spq_mutate(
        year = year(date)) %>% spq_mutate(year = min(year)) %>% spq_group_by(loc,
        year) %>% spq_summarize(n_films = n())
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      SELECT ?loc ?year (COUNT(*) AS ?n_films)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?loc.
      ?film wdt:P577 ?date.
      BIND(YEAR(?date) AS ?year0)
      BIND(MIN(?year0) AS ?year)
      
      }
      GROUP BY ?loc ?year
      

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_head(10) %>% spq_add(
        "?film wdt:P577 ?date") %>% spq_mutate(year = year(date)) %>% spq_group_by(
        filmLabel, loc) %>% spq_summarise(year = min(year))
    Output
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      SELECT (MIN(?year0) AS ?year)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P577 ?date.
      BIND(YEAR(?date) AS ?year0)
      
      }
      GROUP BY ?filmLabel ?loc
      
      LIMIT 10

