![](nominatim.png)

<!-- README.md is generated from README.Rmd. Please edit that file -->
nominatim is an R package to interface to the [OpenStreeMap Nominatim API](http://wiki.openstreetmap.org/wiki/Nominatim).

From the wiki:

> Nominatim (from the Latin, 'by name') is a tool to search OSM data by name and address and to generate synthetic addresses of OSM points (reverse geocoding). It can be found at nominatim.openstreetmap.org.
>
> Nominatim is also used as one of the sources for the search box on the OpenStreetMap home page. Several companies provide hosted instances of Nominatim that you can query via an API, for example see MapQuest Open Initiative, PickPoint or the OpenCage Geocoder.

Most functions hit the [MapQuest Nominatim API](http://open.mapquestapi.com/nominatim/) as recommended by OpenStreetMap.

The following functions are implemented:

-   `address_lookup`: Lookup the address of one or multiple OSM objects like node, way or relation.
-   `osm_geocode`: Search for places by address
-   `osm_search`: Search for places
-   `osm_search_spatial`: Search for places, returning a list of 'SpatialPointsDataFrame', 'SpatialLinesDataFrame' or a 'SpatialPolygonsDataFrame'
-   `reverse_geocode_coords`: Reverse geocode based on lat/lon
-   `reverse_geocode_osm`: Reverse geocode based on OSM Type & Id
-   `bb_lookup`: Bounding box (and other metadata) lookup

### News

-   Version 0.2.1.9000 released : bb\_lookup can also take an `sp::bbox`-like matrix as value to `viewbox`
-   Version 0.2.0.9000 released : bb\_lookup
-   Version 0.1.1.9000 released : address lookup, switch API server, API timeout watch
-   Version 0.1.0.9000 released : "spatial" stuff
-   Version 0.0.0.9000 released

### NOTE

-   Data © OpenStreetMap contributors, ODbL 1.0. <http://www.openstreetmap.org/copyright>
-   Nominatim Usage Policy: <http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy>
-   MapQuest Nominatim Terms of Use: <http://info.mapquest.com/terms-of-use/>

### TODO

-   Enable configuration of timeout
-   Enable switching Nominatim API server providers
-   Better spatial support

### Installation

``` r
devtools::install_github("hrbrmstr/nominatim")
```

### Usage

``` r
library(nominatim)
#> Data (c) OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright
#> Nominatim Usage Policy: http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy
#> MapQuest Nominatim Terms of Use: http://info.mapquest.com/terms-of-use/

# current verison
packageVersion("nominatim")
#> [1] '0.2.1.9000'

# Reverse geocode Canadian embassies
# complete list of Canadian embassies here:
# http://open.canada.ca/data/en/dataset/6661f0f8-2fb2-46fa-9394-c033d581d531

embassies <- data.frame(
  lat=c("34.53311", "41.327546", "41.91534", "36.76148", "-13.83282",
        "40.479094", "-17.820705", "13.09511", "13.09511"),
  lon=c("69.1835", "19.818698", "12.50891", "3.0166", "-171.76462",
        "-3.686115", "31.043559", "-59.59998", "-59.59998"),
  osm_type=c("R", "W", "R", "N", "N", "W", "R", "N", "N"),
  osm_id=c("3836233", "267586999", "3718093", "501522082", "305640297",
           "309487691", "2793217", "501458399", "501458399"),
  stringsAsFactors=FALSE)

emb_coded_coords <- reverse_geocode_coords(embassies$lat, embassies$lon)
head(emb_coded_coords)
#> Source: local data frame [6 x 24]
#> 
#>     place_id                                                                             licence osm_type     osm_id
#> 1  141554854 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way  251884280
#> 2  140380416 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way  248349387
#> 3   17419117 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 1690405094
#> 4   23022786 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 2261850466
#> 5    6676195 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node  687791952
#> 6 2657152894 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way   98280735
#> Variables not shown: lat (dbl), lon (dbl), display_name (chr), address29 (chr), road (chr), city (chr), state (chr),
#>   country (chr), country_code (chr), monument (chr), village_green (chr), county (chr), postcode (chr), bus_stop (chr),
#>   neighbourhood (chr), suburb (chr), city_district (chr), house_number (chr), pub (chr), house (chr)

emb_coded_osm <- reverse_geocode_osm(embassies$osm_type, embassies$osm_id)
head(emb_coded_osm)
#> Source: local data frame [6 x 16]
#> 
#>     place_id                                                                             licence osm_type    osm_id
#> 1  194135434 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright relation   3836233
#> 2  146632013 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way 267586999
#> 3  151591965 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright relation   3718093
#> 4 2636487072 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 501522082
#> 5    1372733 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 305640297
#> 6 2612043014 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way 309487691
#> Variables not shown: lat (dbl), lon (dbl), display_name (chr), city (chr), county (chr), state (chr), country (chr),
#>   country_code (chr), road (chr), village (chr), town (chr), locality (chr)

# lookup some places from the wiki example

places <- c("R146656", "W104393803", "N240109189")
places_found <- address_lookup(places)
head(places_found)
#> Source: local data frame [3 x 22]
#> 
#>     place_id                                                                             licence osm_type    osm_id
#> 1  127761056 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright relation    146656
#> 2   77769706 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way 104393803
#> 3 2570600569 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 240109189
#> Variables not shown: lat (chr), lon (chr), display_name (chr), class (chr), type (chr), importance (chr), city (chr),
#>   county (chr), state_district (chr), state (chr), country (chr), country_code (chr), address29 (chr), house_number
#>   (chr), pedestrian (chr), suburb (chr), city_district (chr), postcode (chr)

# more general search

osm_search("[bakery]+berlin+wedding", limit=5)
#> Source: local data frame [5 x 15]
#> 
#>     place_id                                                                             licence osm_type     osm_id
#> 1    2520528 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node  346137917
#> 2    6887729 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node  707409445
#> 3   29179742 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 2661679367
#> 4    7161987 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node  762607353
#> 5 2659941153 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 3655549445
#> Variables not shown: lat (dbl), lon (dbl), display_name (chr), class (chr), type (chr), importance (dbl), icon (chr),
#>   bbox_left (dbl), bbox_top (dbl), bbox_right (dbl), bbox_bottom (dbl)

# address search

osm_geocode(c("1600 Pennsylvania Ave, Washington, DC.",
              "1600 Amphitheatre Parkway, Mountain View, CA",
              "Seattle, Washington"))
#> Source: local data frame [3 x 15]
#> 
#>     place_id                                                                             licence osm_type   osm_id
#> 1 2661769953 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright relation  5396194
#> 2   47189532 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way 13367984
#> 3  151183715 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright relation   237385
#> Variables not shown: lat (dbl), lon (dbl), display_name (chr), class (chr), type (chr), importance (dbl), icon (chr),
#>   bbox_left (dbl), bbox_top (dbl), bbox_right (dbl), bbox_bottom (dbl)

# spatial
library(sp)
plot(osm_search_spatial("[bakery]+berlin+wedding", limit=5)[[1]])
```

![](README-usage-1.png)

``` r

# bounding box (et. al.)
bb_lookup("West Yorkshire", c(-4.37, 54.88, 2.04, 52.96))
#>    place_id                                                                             licence osm_type   osm_id
#> 1 127642488 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright relation    88079
#> 2  53947051 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way 15199284
#>           lat               lon
#> 1 53.74152525 -1.72024765303197
#> 2    33.24139       -96.7825009
#>                                                                                            display_name    class
#> 1                                                                        West Yorkshire, United Kingdom boundary
#> 2 West Yorkshire, Crestview at Prosper, Rockhill, Collin County, Texas, 75078, United States of America  highway
#>          type importance        top       left      bottom       right
#> 1  ceremonial  0.5199873 53.5197297 53.9632249  -2.1739695  -1.1988144
#> 2 residential  0.2562500  33.239815  33.242393 -96.7825009 -96.7824669

bb_lookup("United States")
#>     place_id                                                                             licence osm_type     osm_id
#> 1  127658196 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright relation     148838
#> 2   60476969 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way   27423181
#> 3  114115020 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way  250575475
#> 4  125647735 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way  315105902
#> 5  126468268 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright      way  315105903
#> 6 2574545131 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 3381768346
#> 7   18767684 Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright     node 1865902396
#>           lat               lon
#> 1  39.7837304      -100.4458825
#> 2  14.4858002       121.0218547
#> 3  40.7372329 -73.8624768947891
#> 4 38.96692885 -77.1376750544799
#> 5  38.9408694 -77.1185943162839
#> 6  39.2242033       -94.5858773
#> 7  36.2983916       -84.2179138
#>                                                                                                             display_name
#> 1                                                                                               United States of America
#> 2 United States, Better Living Subdivision, Don Bosco, Parañaque, Manila Fővárosi Régió, Metro Manila, 1006, Philippines
#> 3               United States, 97-30, 57th Avenue, Corona, Queens County, NYC, New York, 11368, United States of America
#> 4                                                                                United States, United States of America
#> 5                                                                                United States, United States of America
#> 6  Gladstone Post Office, 7170, North Broadway Avenue, Gladstone, Clay County, Missouri, 64118, United States of America
#> 7             Caryville Post Office, Hill Street, Caryville, Campbell County, Tennessee, 37714, United States of America
#>      class           type importance
#> 1 boundary administrative   1.144692
#> 2  highway    residential   0.300000
#> 3 building            yes   0.201000
#> 4 boundary  national_park   0.201000
#> 5 boundary protected_area   0.201000
#> 6  amenity    post_office   0.201000
#> 7  amenity    post_office   0.201000
#>                                                                                       icon         top       left
#> 1 https://nominatim.openstreetmap.org/images/mapicons/poi_boundary_administrative.p.20.png -14.7608357 71.6048217
#> 2                                                                                     <NA>  14.4830636 14.4882325
#> 3                                                                                     <NA>  40.7369018  40.737504
#> 4                                                                                     <NA>  38.9661524 38.9679981
#> 5                                                                                     <NA>  38.9404777 38.9412879
#> 6         https://nominatim.openstreetmap.org/images/mapicons/amenity_post_office.p.20.png  39.2241533 39.2242533
#> 7         https://nominatim.openstreetmap.org/images/mapicons/amenity_post_office.p.20.png  36.2983416 36.2984416
#>         bottom       right
#> 1 -179.9999999         180
#> 2  121.0206884 121.0222591
#> 3  -73.8627531 -73.8622348
#> 4  -77.1380857 -77.1373315
#> 5  -77.1188673 -77.1183216
#> 6  -94.5859273 -94.5858273
#> 7  -84.2179638 -84.2178638
```

### Test Results

``` r
library(nominatim)
library(testthat)

date()
#> [1] "Tue Aug 11 13:27:22 2015"

test_dir("tests/")
#> testthat results ========================================================================================================
#> OK: 0 SKIPPED: 0 FAILED: 0
#> 
#> DONE
```

### Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
