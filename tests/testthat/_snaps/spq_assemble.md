# spq_assemble() detects undefined variables in filter

    Code
      spq_init() %>% spq_filter(lang(itemTitleLOOKTYPO) == "en") %>% spq_assemble()
    Error <rlang_error>
      Can't filter on undefined variables: ?itemTitleLOOKTYPO
      i You haven't mentioned them in any triple, VALUES, mutate.

# spq_assemble() called from printing isn't strict

    Code
      spq_init() %>% spq_filter(lang(itemTitleLOOKTYPO) == "en")
    Output
      
      SELECT *
      WHERE{
      
      FILTER(lang(?itemTitleLOOKTYPO)="en")
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
      }
      

