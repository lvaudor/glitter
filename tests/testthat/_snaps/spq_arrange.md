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

# spq_arrange_ works with SPARQL syntax

    Code
      spq_arrange_(query, spq("DESC(?length) ?itemLabel"))
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(?length) ?itemLabel

---

    Code
      spq_arrange_(query, spq("DESC(xsd:integer(?mort))"))
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(xsd:integer(?mort))

# spq_arrange_ works when using objects for spq()

    Code
      var <- "length"
      arranging_stuff <- sprintf("DESC(?%s) ?itemLabel", var)
      spq_arrange_(query, spq(arranging_stuff))
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(?length) ?itemLabel

# spq_arrange errors if passing a string directly

    For use with characters use spq_arrange_()

# spq_arrange_ errors if passing a string directly

    Did you mean to pass a string? Use spq() to wrap it.

# spq_arrange does not error if passing sthg that could be evaluated

    Code
      var <- c(1, 1)
      spq_arrange(query, length(var))
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY length(?var)

