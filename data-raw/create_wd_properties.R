query="SELECT ?property ?propertyType ?propertyLabel ?propertyDescription ?propertyAltLabel
WHERE {
  ?property wikibase:propertyType ?propertyType.
  SERVICE wikibase:label {bd:serviceParam wikibase:language '[AUTO_LANGUAGE],en'. }
}
ORDER BY ASC (xsd:integer(STRAFTER(STR(?property), 'P')))"
wd_properties=send_sparql(query)
wd_properties=wd_properties %>% setNames(c("id","type","label","description","altLabel"))
usethis::use_data(wd_properties, overwrite = TRUE)
