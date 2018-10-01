.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Data (c) OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright")
  packageStartupMessage("Nominatim Usage Policy: http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy")
  packageStartupMessage("MapQuest Nominatim Terms of Use: http://info.mapquest.com/terms-of-use/")
  options(NOMINATIM.TIMEOUT=5)
  options(NOMINATIM.DELAY=0.5)
  options(NOMINATIM.search_base="http://open.mapquestapi.com/nominatim/v1/search.php")
}
