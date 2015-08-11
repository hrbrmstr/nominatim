# httr::GET timeout (seconds)
TIMEOUT <- 2

# time between requests (i.e. throttling)
DELAY <- 0.5

# URL base for various Nominatim operations
search_base <- "http://open.mapquestapi.com/nominatim/v1/search.php"
lookup_base <- "http://nominatim.openstreetmap.org/lookup"
reverse_base <- "http://open.mapquestapi.com/nominatim/v1/reverse.php"

# search_base <- "http://nominatim.openstreetmap.org/search"
# lookup_base <- "http://nominatim.openstreetmap.org/lookup"
# reverse_base <- "http://nominatim.openstreetmap.org/reverse"

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Data (c) OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright")
  packageStartupMessage("Nominatim Usage Policy: http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy")
  packageStartupMessage("MapQuest Nominatim Terms of Use: http://info.mapquest.com/terms-of-use/")
}
