# spq_arrange works with R syntax

    Code
      spq_arrange(query, desc(length), itemLabel)
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(?length) ?itemLabel

---

    Code
      spq_arrange(query, desc(xsd:integer(mort)))
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(xsd:integer(?mort))

# spq_arrange works with SPARQL syntax

    Code
      spq_arrange(query, spq("DESC(?length) ?itemLabel"))
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(?length) ?itemLabel

---

    Code
      spq_arrange(query, spq("DESC(xsd:integer(?mort))"))
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(xsd:integer(?mort))

