# spq_arrange works with R syntax

    Code
      spq_arrange(spq_init(), desc(length), itemLabel)
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(?length) ?itemLabel

---

    Code
      spq_arrange(spq_init(), desc(as.integer(mort)))
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(xsd:integer(?mort))

# spq_arrange works with SPARQL syntax

    Code
      spq_arrange(spq_init(), spq("DESC(?length) ?itemLabel"))
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(?length) ?itemLabel

---

    Code
      spq_arrange(spq_init(), spq("DESC(xsd:integer(?mort))"))
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(xsd:integer(?mort))

# spq_arrange works with a mix

    Code
      spq_arrange(spq_init(), spq("DESC(xsd:integer(?mort))"), vie)
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(xsd:integer(?mort)) ?vie

# spq_arrange works when using objects for spq()

    Code
      var <- "length"
      arranging_stuff <- sprintf("DESC(?%s) ?itemLabel", var)
      spq_arrange(spq_init(), spq(arranging_stuff))
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(?length) ?itemLabel

# spq_arrange works if passing a string directly

    Code
      spq_arrange(spq_init(), "desc(length)")
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(?length)

# spq_arrange does not error if passing sthg that could be evaluated

    Code
      var <- c(1, 1)
      spq_arrange(spq_init(), str_to_lower(var))
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY LCASE(?var)

