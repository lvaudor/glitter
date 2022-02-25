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

# spq_arrange works with a mix

    Code
      spq_arrange(query, spq("DESC(xsd:integer(?mort))"), vie)
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
      spq_arrange(query, spq(arranging_stuff))
    Output
      
      SELECT *
      WHERE{
      
      
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      ORDER BY DESC(?length) ?itemLabel

# spq_arrange errors if passing a string directly

    x Cannot use "DESC(xsd:integer(?mort))"
    i Did you mean to pass a string? Use spq() to wrap it.

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

