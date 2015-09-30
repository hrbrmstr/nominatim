#' Lookup the address of one or multiple OSM objects like node, way or relation.
#'
#' Vectorized over \code{osm_ids}
#'
#' @note A slight delay is introduced between calls as both OpenStreetMap Nominatim &
#'       MapQuest Nominatim API calls to reduce load on their servers.
#'
#' Data (c) OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright\cr
#' Nominatim Usage Policy: http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy\cr
#' MapQuest Nominatim Terms of Use: http://info.mapquest.com/terms-of-use/\cr
#'
#' @param osm_ids A vector of up to 50 specific osm node, way or relations ids to
#'        return the addresses for. Format for each entry is \code{[N|W|R]<value>}.
#' @param address_details Include a breakdown of the address into elements (TRUE == include)
#' @param email If you are making large numbers of request please include a valid email address
#'        or alternatively include your email address as part of the User-Agent string.
#'        This information will be kept confidential and only used to contact you in the
#'        event of a problem, see Usage Policy for more details. You can pass the value
#'        in directly or set the \code{OSM_API_EMAIL} option and the function will
#'        it for all requests.
#' @param accept_language Preferred language order for showing search results
#'        Either uses standard rfc2616 accept-language string or a simple comma separated l
#'        ist of language codes. The \code{LANG} option will be used, if set.#' @export
#' @examples \dontrun{
#' places <- c("R146656", "W104393803", "N240109189")
#' places_found <- address_lookup(places)
#' }
address_lookup <- function(osm_ids,
                           address_details=TRUE,
                           email=getOption("OSM_API_EMAIL", "nominatimrpackage@example.com"),
                           accept_language=getOption("LANG", "en-US,en;q=0.8")) {

  places <- paste(trimws(osm_ids), collapse=",")

  params <- list(osm_ids=places,
                 format="json", email=email,
                 `accept-language`=accept_language,
                 addressdetails=as.numeric(address_details))

  .address_lookup(params)

}

.address_lookup <- function(params) {

  tryCatch({

    res <- GET(lookup_base, query=params, timeout(getOption("NOMINATIM.TIMEOUT")))
    stop_for_status(res)

    ret <- content(res)

    if (length(ret) == 0) return(NULL)

    return(bind_rows(lapply(1:length(ret), function(i) {

      ret_names <- intersect(names(ret[[i]]),
                             c("place_id", "licence", "osm_type", "osm_id",
                               "lat", "lon", "display_name", "class", "type", "importance"))
      tmp_df <- data.frame(t(sapply(ret_names, function(x) { ret[[i]][[x]] })), stringsAsFactors=FALSE)

      if ("address" %in% names(ret[[i]])) {
        tmp_df <- cbind.data.frame(tmp_df,
                                   data.frame(t(sapply(names(ret[[i]][["address"]]),
                                                       function(x) { ret[[i]][["address"]][[x]]} )),
                                              stringsAsFactors=FALSE),
                                   stringsAsFactors=FALSE)
      }

      tmp_df

    })))

  }, error=function(e) { message("Error connecting to geocode service", e)})

  return(NULL)

}
