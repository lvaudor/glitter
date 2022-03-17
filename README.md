
# glitter <img src="man/figures/logo_small.png" align="right"/>

> DSL for SPARQL in R. :sparkles: `glitter` produces ~~sparkle~~ SPARQL!
> :sparkles:

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![R-CMD-check](https://github.com/lvaudor/glitter/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lvaudor/glitter/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Codecov test
coverage](https://codecov.io/gh/lvaudor/glitter/branch/master/graph/badge.svg)](https://app.codecov.io/gh/lvaudor/glitter?branch=master)
<!-- badges: end -->

This package aims at writing and sending SPARQL queries without any
knowledge of the SPARQL language syntax. It makes the exploration and
use of Linked Open Data (Wikidata in particular) easier for those who do
not know SPARQL.

For instance, to find a corpus of 5 articles with a title in English and
“wikidata” in that title, instead of writing SPARQL by hand you can run:

``` r
library("glitter")
query <- spq_init() %>%
  spq_add("?item wdt:P31 wd:Q13442814") %>%
  spq_add("?item rdfs:label ?itemTitle") %>%
  spq_filter(str_detect(str_to_lower(itemTitle), 'wikidata')) %>%
  spq_filter(lang(itemTitle) == "en") %>%
  spq_head(n = 5)

query
#> PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
#> SELECT ?item ?itemTitle
#> WHERE{
#> 
#> ?item wdt:P31 wd:Q13442814.
#> ?item rdfs:label ?itemTitle.
#> FILTER(REGEX(LCASE(?itemTitle),"wikidata"))
#> FILTER(lang(?itemTitle)="en")
#> SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
#> }
#> 
#> LIMIT 5
```

To perform the query,

``` r
spq_perform(query)
#> # A tibble: 5 × 2
#>   item                                     itemTitle                            
#>   <chr>                                    <chr>                                
#> 1 http://www.wikidata.org/entity/Q18507561 Wikidata: A Free Collaborative Knowl…
#> 2 http://www.wikidata.org/entity/Q21503276 Utilizing the Wikidata system to imp…
#> 3 http://www.wikidata.org/entity/Q21503284 Wikidata: A platform for data integr…
#> 4 http://www.wikidata.org/entity/Q23712646 Wikidata as a semantic framework for…
#> 5 http://www.wikidata.org/entity/Q24074986 From Freebase to Wikidata: The Great…
```

## Installation

Install this packages through R-universe:

``` r
install.packages("glitter", repos = "https://lvaudor.r-universe.dev")
```

Or through GitHub:

``` r
install.packages("remotes") #if remotes is not already installed
remotes::install_github("lvaudor/glitter")
```

## Documentation

You can access the documentation regarding package `glitter` [on its
pkgdown
website](http://perso.ens-lyon.fr/lise.vaudor/Rpackages/glitter/).
