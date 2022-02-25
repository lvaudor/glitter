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
      

# spq_select errors well

    Can't find equivalent for argument(s) abbreviate, translate for call to year().

---

    Can't find SPARQL equivalent for collapse().

