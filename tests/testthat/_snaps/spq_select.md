# spq_select works with R syntax

    Code
      spq_select(query, count = n(human), eyecolorLabel, haircolorLabel)
    Output
      
      SELECT (COUNT(?human) AS ?count) ?eyecolorLabel ?haircolorLabel
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

---

    Code
      spq_select(query, count = n(human), eyecolorLabel, haircolorLabel) %>%
        spq_select(-haircolorLabel)
    Output
      
      SELECT (COUNT(?human) AS ?count) ?eyecolorLabel
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

---

    Code
      spq_select(query, birthyear = year(birthdate))
    Output
      
      SELECT (YEAR(?birthdate) AS ?birthyear)
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

---

    Code
      spq_select(query, lang, count = n(unique(article)))
    Output
      
      SELECT ?lang (COUNT(DISTINCT ?article) AS ?count)
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

# spq_select works with SPARQL

    Code
      spq_select(query, spq("?lang"), spq("(COUNT(DISTINCT ?article) AS ?count"))
    Output
      
      SELECT ?lang (COUNT(DISTINCT ?article) AS ?count
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

# spq_select works with both

    Code
      spq_select(query, lang, spq("(COUNT(DISTINCT ?article) AS ?count"))
    Output
      
      SELECT ?lang (COUNT(DISTINCT ?article) AS ?count
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

# spq_select errors well

    x Can't find equivalent for argument(s) abbreviate, translate for call to year().
    i If you think there should be one, open an issue in https://github.com/lvaudor/glitter.

---

    x Can't find SPARQL equivalent for collapse().
    i If you think there should be one, open an issue in https://github.com/lvaudor/glitter.

# spq_select can use DISTINCT and REDUCED

    Code
      spq_select(query, year, month, day, spq_duplicate = "distinct")
    Output
      
      SELECT DISTINCT ?year ?month ?day
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

---

    Code
      spq_select(query, year, month, day, spq_duplicate = "reduced")
    Output
      
      SELECT REDUCED ?year ?month ?day
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

---

    x Wrong value for `spq_duplicate` argument (reduce).
    i Use either `NULL`, "distinct" or "reduced".

