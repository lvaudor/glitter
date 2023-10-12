# spq_select works with R syntax

    Code
      spq_select(query, count = n(human), eyecolorLabel, haircolorLabel)
    Output
      
      SELECT (COUNT(?human) AS ?count) ?eyecolorLabel ?haircolorLabel
      WHERE {
      
      
      }
      

---

    Code
      spq_select(query, count = n(human), eyecolorLabel, haircolorLabel) %>%
        spq_select(-haircolorLabel)
    Output
      
      SELECT (COUNT(?human) AS ?count) ?eyecolorLabel
      WHERE {
      
      
      }
      

---

    Code
      spq_select(query, birthyear = year(birthdate))
    Output
      
      SELECT (YEAR(?birthdate) AS ?birthyear)
      WHERE {
      
      
      }
      

---

    Code
      spq_select(query, lang, count = n(unique(article)))
    Output
      
      SELECT ?lang (COUNT(DISTINCT ?article) AS ?count)
      WHERE {
      
      
      }
      

---

    Code
      spq_select(query, lang, count = n_distinct(article))
    Output
      
      SELECT ?lang (COUNT(DISTINCT ?article) AS ?count)
      WHERE {
      
      
      }
      

---

    Code
      spq_select(query, lang, count = n_distinct(article)) %>% spq_select(lang)
    Output
      
      SELECT ?lang
      WHERE {
      
      
      }
      

# spq_select works with SPARQL

    Code
      spq_select(query, spq("?lang"), spq("(COUNT(DISTINCT ?article) AS ?count"))
    Output
      
      SELECT ?lang (COUNT(DISTINCT ?article) AS ?count
      WHERE {
      
      
      }
      

# spq_select works with both

    Code
      spq_select(query, lang, spq("(COUNT(DISTINCT ?article) AS ?count"))
    Output
      
      SELECT ?lang (COUNT(DISTINCT ?article) AS ?count
      WHERE {
      
      
      }
      

# spq_select errors well

    i In index: 1.
    i With name: birthyear.
    Caused by error in `map()`:
    i In index: 1.
    Caused by error in `.f()`:
    ! x Can't find equivalent for argument(s) abbreviate, translate for call to year().
    i If you think there should be one, open an issue in https://github.com/lvaudor/glitter.

---

    i In index: 1.
    i With name: birthyear.
    Caused by error in `spq_translate_dsl()`:
    ! x Can't find SPARQL equivalent for collapse().
    i If you think there should be one, open an issue in https://github.com/lvaudor/glitter.

# spq_select can use DISTINCT and REDUCED

    Code
      spq_select(query, year, month, day, .spq_duplicate = "distinct")
    Output
      
      SELECT DISTINCT ?year ?month ?day
      WHERE {
      
      
      }
      

---

    Code
      spq_select(query, year, month, day, .spq_duplicate = "reduced")
    Output
      
      SELECT REDUCED ?year ?month ?day
      WHERE {
      
      
      }
      

---

    x Wrong value for `.spq_duplicate` argument (reduce).
    i Use either `NULL`, "distinct" or "reduced".

# spq_select tells a variable isn't there

    Code
      spq_init() %>% spq_add("?station wdt:P16 wd:Q1552") %>% spq_add(
        "?station wdt:P31 wd:Q928830") %>% spq_add("?station wdt:P625 ?coords") %>%
        spq_label(station) %>% spq_select(station_label, blop)
    Condition
      Error in `check_variables_present()`:
      ! Can't use `spq_select()` on absent variables: ?station_label.
      i Did you forget a call to `spq_add()`, `spq_mutate()` or `spq_label()`?

