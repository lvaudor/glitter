# spq_summarise() works

    Code
      spq_init() %>% spq_add("?item wdt:P361 wd:Q297853") %>% spq_add(
        "?item wdt:P1082 ?folkm_ngd") %>% spq_add("?area wdt:P31 wd:Q1907114",
        .label = "?area") %>% spq_add("?area wdt:P527 ?item") %>% spq_group_by(area,
        areaLabel) %>% spq_summarise(total_folkm = sum(folkm_ngd))
    Output
      
      SELECT ?area ?areaLabel (SUM(?folkm_ngd) AS ?total_folkm)
      WHERE {
      
      ?item wdt:P361 wd:Q297853.
      ?item wdt:P1082 ?folkm_ngd.
      ?area wdt:P31 wd:Q1907114.
      ?area wdt:P527 ?item.
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      GROUP BY ?area ?areaLabel
      

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424", .label = "?film") %>% spq_add(
        "?film wdt:P840 ?loc", .label = "?loc") %>% spq_summarise(n_films = n())
    Output
      
      SELECT (COUNT(*) AS ?n_films)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?loc.
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424", .label = "?film") %>% spq_add(
        "?film wdt:P840 ?loc", .label = "?loc") %>% spq_group_by(loc) %>%
        spq_summarise(n_films = n())
    Output
      
      SELECT ?loc (COUNT(*) AS ?n_films)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?loc.
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      GROUP BY ?loc
      

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_add(
        "?film wdt:P577 ?date") %>% spq_mutate(year = year(date)) %>% spq_group_by(
        year) %>% spq_summarise(n_films = n(), one_film = sample(film)) %>% spq_head(
        10)
    Output
      
      SELECT ?year (COUNT(*) AS ?n_films) (SAMPLE(?film) AS ?one_film)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P577 ?date.
      BIND(YEAR(?date) AS ?year)
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      GROUP BY ?year
      
      LIMIT 10

---

    Code
      spq_init() %>% spq_add("?film wdt:P31 wd:Q11424") %>% spq_add(
        "?film wdt:P840 ?loc") %>% spq_summarise(n_films = n())
    Output
      
      SELECT (COUNT(*) AS ?n_films)
      WHERE {
      
      ?film wdt:P31 wd:Q11424.
      ?film wdt:P840 ?loc.
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

