![](nominatim.png)

<!-- README.md is generated from README.Rmd. Please edit that file -->
nominatim is an R package to interface to the [OpenStreeMap Nominatim API](http://wiki.openstreetmap.org/wiki/Nominatim).

From the wiki: \>Nominatim (from the Latin, 'by name') is a tool to search OSM data by name and address and to generate synthetic addresses of OSM points (reverse geocoding). It can be found at nominatim.openstreetmap.org. \> \>Nominatim is also used as one of the sources for the search box on the OpenStreetMap home page. Several companies provide hosted instances of Nominatim that you can query via an API, for example see MapQuest Open Initiative, PickPoint or the OpenCage Geocoder.

The following functions are implemented:

-   `address_lookup`: Lookup the address of one or multiple OSM objects like node, way or relation.
-   `osm_search`: Search for places
-   `reverse_geocode_coords`: Reverse geocode based on lat/lon
-   `reverse_geocode_osm`: Reverse geocode based on OSM Type & Id

### News

-   Version 0.0.0.9000 released

### Installation

``` r
devtools::install_github("hrbrmstr/nominatim")
```

### Usage

``` r
library(nominatim)

# current verison
packageVersion("nominatim")
#> [1] '0.0.0.9000'

# Reverse geocode Canadian embassies
# complete list of Canadian embassies here:
# http://open.canada.ca/data/en/dataset/6661f0f8-2fb2-46fa-9394-c033d581d531

embassies <- data.frame(lat=c("34.53311", "41.327546", "41.91534", "36.76148", "-13.83282",
                              "40.479094", "-17.820705", "13.09511", "13.09511"),
                        lon=c("69.1835", "19.818698", "12.50891", "3.0166", "-171.76462",
                              "-3.686115", "31.043559", "-59.59998", "-59.59998"),
                        osm_type=c("R", "W", "R", "N", "N", "W", "R", "N", "N"),
                        osm_id=c("3836233", "267586999", "3718093", "501522082", "305640297",
                                 "309487691", "2793217", "501458399", "501458399"),
                        stringsAsFactors=FALSE)

emb_coded_coords <- reverse_geocode_coords(embassies$lat, embassies$lon)
head(emb_coded_coords)
#> Source: local data frame [6 x 23]
#> 
#>    place_id                                                                             licence osm_type     osm_id
#> 1 114261310 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way  251884280
#> 2 113405421 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way  248349387
#> 3  17130351 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 1690405094
#> 4  21875530 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 2261850466
#> 5   6574328 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node  687791952
#> 6  76162705 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way   98280735
#> Variables not shown: lat (chr), lon (chr), display_name (chr), address29 (chr), road (chr), city (chr), state (chr),
#>   country (chr), country_code (chr), attraction (chr), county (chr), postcode (chr), bus_stop (chr), neighbourhood
#>   (chr), suburb (chr), city_district (chr), house_number (chr), pub (chr), building (chr)

emb_coded_osm <- reverse_geocode_osm(embassies$osm_type, embassies$osm_id)
head(emb_coded_osm)
#> Source: local data frame [6 x 16]
#> 
#>     place_id                                                                             licence osm_type    osm_id
#> 1  128140499 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright relation   3836233
#> 2  117737072 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way 267586999
#> 3  128127817 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright relation   3718093
#> 4 2575507032 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 501522082
#> 5    1287405 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 305640297
#> 6  124936050 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way 309487691
#> Variables not shown: lat (chr), lon (chr), display_name (chr), city (chr), county (chr), state (chr), country (chr),
#>   country_code (chr), road (chr), village (chr), town (chr), locality (chr)

# lookup some places from the wiki example

places <- c("R146656", "W104393803", "N240109189")
places_found <- address_lookup(places)
head(places_found)
#> Source: local data frame [3 x 22]
#> 
#>     place_id                                                                             licence osm_type    osm_id
#> 1  127761056 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright relation    146656
#> 2   77769745 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way 104393803
#> 3 2570600569 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 240109189
#> Variables not shown: lat (chr), lon (chr), display_name (chr), class (chr), type (chr), importance (chr), city (chr),
#>   county (chr), state_district (chr), state (chr), country (chr), country_code (chr), attraction (chr), house_number
#>   (chr), pedestrian (chr), suburb (chr), city_district (chr), postcode (chr)

# more general search

osm_search("[bakery]+berlin+wedding", limit=5)
#> Source: local data frame [5 x 15]
#> 
#>   place_id                                                                             licence osm_type    osm_id
#> 1  4762713 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 530568693
#> 2  7566845 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 832835245
#> 3  1394510 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 317179427
#> 4  6749898 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 707409445
#> 5  7002350 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 762607353
#> Variables not shown: lat (chr), lon (chr), display_name (chr), class (chr), type (chr), importance (chr), icon (chr),
#>   bbox_left (dbl), bbox_top (dbl), bbox_right (dbl), bbox_bottom (dbl)
```

### Test Results

``` r
library(nominatim)
library(testthat)

date()
#> [1] "Tue Jul 28 16:50:39 2015"

test_dir("tests/")
#> testthat results ========================================================================================================
#> OK: 0 SKIPPED: 0 FAILED: 0
#> 
#> DONE
```

### Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
