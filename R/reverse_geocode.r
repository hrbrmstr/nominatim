#' Reverse geocode based on lat/lon
#'
#' Vectorized over \code{lat} and \code{lon}
#'
#' @note A slight delay is introduced between calls to both OpenStreetMap Nominatim &
#'       MapQuest Nominatim API to reduce load on their servers.
#'
#' Data (c) OpenStreetMap contributors, ODbL 1.0. \url{http://www.openstreetmap.org/copyright}\cr
#' Nominatim Usage Policy: \url{http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy}\cr
#' MapQuest Nominatim Terms of Use: \url{http://info.mapquest.com/terms-of-use/}\cr
#'
#' @param lat Latitude to generate an address for
#' @param lon Longitude to generate an address for
#' @param zoom Level of detail required where 0 is country and 18 is house/building
#' @param address_details Include a breakdown of the address into elements (TRUE == include)
#' @param email If you are making large numbers of request please include a valid email address
#'        or alternatively include your email address as part of the User-Agent string.
#'        This information will be kept confidential and only used to contact you in the
#'        event of a problem, see Usage Policy for more details. You can pass the value
#'        in directly or set the \code{OSM_API_EMAIL} option and the function will
#'        it for all requests.
#' @param accept_language Preferred language order for showing search results
#'        Either uses standard rfc2616 accept-language string or a simple comma separated
#'        list of language codes. The \code{LANG} option will be used, if set.
#' @param key To access the openstreetmap API you need a valid API key. You can get it for
#'        free at \url{https://developer.mapquest.com}
#' @return data.frame of reverse geocode results
#' @export
#' @examples \dontrun{
#' # Reverse geocode Canadian embassies
#' # complete list of Canadian embassies here:
#' # http://open.canada.ca/data/en/dataset/6661f0f8-2fb2-46fa-9394-c033d581d531
#' embassies <- data.frame(lat=c("34.53311", "41.327546", "41.91534", "36.76148", "-13.83282",
#'                               "40.479094", "-17.820705", "13.09511", "13.09511"),
#'                         lon=c("69.1835", "19.818698", "12.50891", "3.0166", "-171.76462",
#'                               "-3.686115", "31.043559", "-59.59998", "-59.59998"),
#'                         osm_type=c("R", "W", "R", "N", "N", "W", "R", "N", "N"),
#'                         osm_id=c("3836233", "267586999", "3718093", "501522082", "305640297",
#'                                  "309487691", "2793217", "501458399", "501458399"),
#'                                  stringsAsFactors=FALSE)
#' emb_coded_coords <- reverse_geocode_coords(embassies$lat, embassies$lon)
#' }
reverse_geocode_coords <- function(lat, lon,
                                   zoom=18, address_details=TRUE,
                                   email=getOption("OSM_API_EMAIL", "nominatimrpackage@example.com"),
                                   accept_language=getOption("LANG", "en-US,en;q=0.8"),
                                   key = getOption("OSM_API_KEY", "")) {

  if (length(lat) != length(lon)) {
    stop("lat & lon vectors must be the same size", call.=FALSE)
  }

  if (nchar(key) == 0) {
    stop('Please provide a openstreet API key')
  }

  bind_rows(pblapply(1:length(lat), function(i) {

    params <- list(lat=lat[i], lon=lon[i],
                   format="json", zoom=zoom, email=email,
                   `accept-language`=accept_language,
                   addressdetails=as.numeric(address_details), key = key)

    if (length(lat) > 1 & length(lat) != i) Sys.sleep(getOption("NOMINATIM.DELAY"))

    reverse_geocode(params)

  }))


}

#' Reverse geocode based on OSM Type & Id
#'
#' Vectorized over \code{osm_type} and \code{osm_id}
#'
#' @note A slight delay is introduced between calls as both OpenStreetMap Nominatim &
#'       MapQuest Nominatim API calls to reduce load on their servers.
#'
#' Data (c) OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright
#' Nominatim Usage Policy: http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy
#' MapQuest Nominatim Terms of Use: http://info.mapquest.com/terms-of-use/
#'
#' @param osm_type A specific osm node / way / relation to return an address for (\code{N, W or R})
#' @param osm_id A specific osm node / way / relation to return an address for
#' @param zoom Level of detail required where 0 is country and 18 is house/building
#' @param address_details Include a breakdown of the address into elements (TRUE == include)
#' @param email If you are making large numbers of request please include a valid email address
#'        or alternatively include your email address as part of the User-Agent string.
#'        This information will be kept confidential and only used to contact you in the
#'        event of a problem, see Usage Policy for more details. You can pass the value
#'        in directly or set the \code{OSM_API_EMAIL} option and the function will
#'        it for all requests.
#' @param accept_language Preferred language order for showing search results
#'        Either uses standard rfc2616 accept-language string or a simple comma separated l
#'        ist of language codes. The \code{LANG} option will be used, if set.
#' @param key To access the openstreetmap API you need a valid API key. You can get it for free at https://developer.mapquest.com
#' @return data.frame of reverse geocoded results
#' @export
#' @examples \dontrun{
#' # Reverse geocode Canadian embassies
#' # complete list of Canadian embassies here:
#' # http://open.canada.ca/data/en/dataset/6661f0f8-2fb2-46fa-9394-c033d581d531
#' embassies <- data.frame(lat=c("34.53311", "41.327546", "41.91534", "36.76148", "-13.83282",
#'                               "40.479094", "-17.820705", "13.09511", "13.09511"),
#'                         lon=c("69.1835", "19.818698", "12.50891", "3.0166", "-171.76462",
#'                               "-3.686115", "31.043559", "-59.59998", "-59.59998"),
#'                         osm_type=c("R", "W", "R", "N", "N", "W", "R", "N", "N"),
#'                         osm_id=c("3836233", "267586999", "3718093", "501522082", "305640297",
#'                                  "309487691", "2793217", "501458399", "501458399"),
#'                                  stringsAsFactors=FALSE)
#' emb_coded_osm <- reverse_geocode_osm(embassies$osm_type, embassies$osm_id)
#' }
reverse_geocode_osm <- function(osm_type, osm_id,
                                zoom=18, address_details=TRUE,
                                email=getOption("OSM_API_EMAIL", "nominatimrpackage@example.com"),
                                accept_language=getOption("LANG", "en-US,en;q=0.8"),
                                key = getOption("OSM_API_KEY", "")) {

  if (length(osm_type) != length(osm_id)) {
    stop("osm_type & osm_id vectors must be the same size", call.=FALSE)
  }

  if (nchar(key) == 0) {
    stop('Please provide a openstreet API key')
  }

  bind_rows(pblapply(1:length(osm_type), function(i) {

    params <- list(osm_type=osm_type[i], osm_id=osm_id[i],
                   format="json", zoom=zoom, email=email,
                   `accept-language`=accept_language,
                   addressdetails=as.numeric(address_details), key = key)

    if (length(osm_type) > 1 & length(osm_type) != i) Sys.sleep(getOption("NOMINATIM.DELAY"))

    reverse_geocode(params)

  }))

}


reverse_geocode <- function(params) {

  tryCatch({

    res <- GET(reverse_base, query=params, timeout(getOption("NOMINATIM.TIMEOUT")))
    stop_for_status(res)

    ret <- content(res)

    if (length(ret) == 0) return(NULL)

    ret_names <- intersect(names(ret),
                           c("place_id", "licence", "osm_type", "osm_id",
                             "lat", "lon", "display_name", "class", "type", "importance"))
    tmp_df <- data.frame(t(sapply(ret_names, function(x) { ret[[x]] })), stringsAsFactors=FALSE)

    if ("address" %in% names(ret)) {
      tmp_df <- cbind.data.frame(tmp_df,
                                 data.frame(t(sapply(names(ret[["address"]]),
                                                     function(x) { ret[["address"]][[x]]} )),
                                            stringsAsFactors=FALSE),
                                 stringsAsFactors=FALSE)
    }

    tmp_df$lat <- as.numeric(tmp_df$lat)
    tmp_df$lon <- as.numeric(tmp_df$lon)

    return(tmp_df)

  }, error=function(e) { message("Error connecting to geocode service", e)})

  return(NULL)

}
