
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

The glitter package aims at writing and sending SPARQL queries without
advanced knowledge of the SPARQL language syntax. It makes the
exploration and use of Linked Open Data (Wikidata in particular) easier
for those who do not know SPARQL well.

With glitter, compared to writing SPARQL queries by hand, your code
should be easier to write, and easier to read by your peers who do not
know SPARQL. The glitter package supports a “domain-specific language”
(DSL) with function names (and syntax) closer to the tidyverse and base
R than to SPARQL.

For instance, to find a corpus of 5 articles with a title in English and
“wikidata” in that title, instead of writing SPARQL by hand you can run:

``` r
library("glitter")
query <- spq_init() %>%
  spq_add("?item wdt:P31 wd:Q13442814") %>%
  spq_label(item) %>%
  spq_filter(str_detect(str_to_lower(item_label), 'wikidata')) %>%
  spq_head(n = 5)

query
#> PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
#> SELECT ?item (COALESCE(?item_labell,'') AS ?item_label)
#> WHERE {
#> 
#> ?item wdt:P31 wd:Q13442814.
#> OPTIONAL {
#> ?item rdfs:label ?item_labell.
#> FILTER(lang(?item_labell) IN ('en'))
#> }
#> 
#> BIND(COALESCE(?item_labell,'') AS ?item_label)
#> FILTER(REGEX(LCASE(?item_label),"wikidata"))
#> }
#> 
#> LIMIT 5
```

Note how we were able to use `str_detect()` and `str_to_lower()` (as in
the stringr package) instead of SPARQL’s functions `REGEX` and `LCASE`.

To perform the query,

``` r
spq_perform(query)
#> # A tibble: 5 × 2
#>   item                                     item_label                           
#>   <chr>                                    <chr>                                
#> 1 http://www.wikidata.org/entity/Q18507561 Wikidata: A Free Collaborative Knowl…
#> 2 http://www.wikidata.org/entity/Q21503276 Utilizing the Wikidata system to imp…
#> 3 http://www.wikidata.org/entity/Q21503284 Wikidata: A platform for data integr…
#> 4 http://www.wikidata.org/entity/Q23712646 Wikidata as a semantic framework for…
#> 5 http://www.wikidata.org/entity/Q24074986 From Freebase to Wikidata: The Great…
```

To get a random subset of movies with the date they were released, you
could use

``` r
spq_init() %>%
  spq_add("?film wdt:P31 wd:Q11424") %>%
  spq_label(film) %>%
  spq_add("?film wdt:P577 ?date") %>%
  spq_mutate(date = year(date)) %>%
  spq_head(10) %>%
  spq_perform()
#> # A tibble: 10 × 3
#>    film                                  film_label       date
#>    <chr>                                 <chr>           <dbl>
#>  1 http://www.wikidata.org/entity/Q24585 July 14          1932
#>  2 http://www.wikidata.org/entity/Q24585 July 14          1933
#>  3 http://www.wikidata.org/entity/Q24618 Jaded            1998
#>  4 http://www.wikidata.org/entity/Q24732 The Broken Coin  1915
#>  5 http://www.wikidata.org/entity/Q24815 Citizen Kane     1941
#>  6 http://www.wikidata.org/entity/Q24815 Citizen Kane     1941
#>  7 http://www.wikidata.org/entity/Q24815 Citizen Kane     1946
#>  8 http://www.wikidata.org/entity/Q24871 Avatar           2009
#>  9 http://www.wikidata.org/entity/Q24871 Avatar           2009
#> 10 http://www.wikidata.org/entity/Q24871 Avatar           2009
```

Note that we were able to “overwrite” the date variable, which is
straightforward in dplyr, but not so much in SPARQL.

## Installation

Install this packages through R-universe:

``` r
install.packages("glitter", repos = "https://lvaudor.r-universe.dev")
```

Or through GitHub:

``` r
install.packages("pak") #if pak is not already installed
pak::pak("lvaudor/glitter")
```

## Documentation

You can access the documentation regarding package `glitter` [on its
pkgdown
website](http://perso.ens-lyon.fr/lise.vaudor/Rpackages/glitter/).
