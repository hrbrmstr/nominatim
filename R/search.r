#' Search for places by address
#'
#' Geocode place addresses
#'
#' Vectorized over \code{query}
#'
#' Nominatim indexes named (or numbered) features with the OSM data set and a subset of
#' other unnamed features (pubs, hotels, churches, etc).
#'
#' Search terms are processed first left to right and then right to left if that fails.
#'
#' @note A slight delay is introduced between calls as both OpenStreetMap Nominatim &
#'       MapQuest Nominatim API calls to reduce load on their servers.
#'
#' Data (c) OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright\cr
#' Nominatim Usage Policy: http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy\cr
#' MapQuest Nominatim Terms of Use: http://info.mapquest.com/terms-of-use/\cr
#'
#' @param query Query string to search for. Should be in standard address format.
#' @param country_codes Limit search results to a specific country (or a list of countries).
#'        Should be the ISO 3166-1alpha2 code,e.g. gb for the United Kingdom, de for Germany, etc.
#'        Format: \code{<countrycode>[,<countrycode>][,<countrycode>]...}
#' @param viewbox The preferred area to find search results. Format:
#'        \code{<left>,<top>,<right>,<bottom>}
#' @param bounded Restrict the results to only items contained with the bounding box.
#'        Restricting the results to the bounding box also enables searching by amenity only.
#'        For example a search query of just "[pub]" would normally be rejected
#'        but with \code{bounded=TRUE} will result in a list of items matching within the bounding box.
#' @param address_details Include a breakdown of the address into elements (TRUE == include)
#' @param exclude_place_ids If you do not want certain openstreetmap objects to appear in the search result,
#'        give a comma separated list of the place_id's you want to skip. This can be used
#'        to broaden search results. For example, if a previous query only returned a few
#'        results, then including those here would cause the search to return other, less
#'        accurate, matches (if possible). Format \code{<place_id,[place_id],[place_id]>}
#' @param limit Limit the number of returned results (numeric)
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
#' @export
#' @examples \dontrun{
#' osm_search("[bakery]+berlin+wedding", limit=5)
#' }
osm_geocode <- function(query,
                        country_codes=NULL,
                        viewbox=NULL,
                        bounded=FALSE,
                        address_details=TRUE,
                        exclude_place_ids=NULL,
                        limit=1,
                        email=getOption("OSM_API_EMAIL", "nominatimrpackage@example.com"),
                        accept_language=getOption("LANG", "en-US,en;q=0.8"),
                        key = getOption("OSM_API_KEY", "")) {

  if (nchar(key) == 0) {
    stop('Please provide a openstreet API key')
  }

  bind_rows(pblapply(1:length(query), function(i) {

    param_base <- sprintf("%s/%s", getOption("NOMINATIM.search_base"), gsub(" ", "+", query[i]))

    params <- "format=json&dedupe=0&debug=0&polygon=0"
    if (!is.null(country_codes)) params <- sprintf("%s&countrycodes=%s", params, country_codes)
    if (!is.null(viewbox)) params <- sprintf("%s&viewbox=%s", params, viewbox)
    if (!is.null(bounded)) params <- sprintf("%s&bounded=%d", params, as.numeric(bounded))
    if (!is.null(exclude_place_ids)) params <- sprintf("%s&exclude_place_ids=%s", params, exclude_place_ids)
    if (!is.null(email)) params <- sprintf("%s&email=%s", params, curl::curl_escape(email))
    if (!is.null(accept_language)) params <- sprintf("%s&accept-language=%s", params, curl::curl_escape(accept_language))
    params <- sprintf("%s&addressdetails=%d", params, as.numeric(address_details))
    params <- sprintf("%s&limit=%d", params, as.numeric(limit))
    params <- sprintf("%s&key=%s", params, key)

    if (length(query) > 1 & length(query) != i) Sys.sleep(getOption("NOMINATIM.DELAY"))

    .search(param_base, params)

  }))

}

#' Search for places
#'
#' Vectorized over \code{query}
#'
#' @note A slight delay is introduced between calls as both OpenStreetMap Nominatim &
#'       MapQuest Nominatim API calls to reduce load on their servers.
#'
#' Data (c) OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright
#' Nominatim Usage Policy: http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy
#' MapQuest Nominatim Terms of Use: http://info.mapquest.com/terms-of-use/
#'
#' @param query Query string to search for
#' @param country_codes Limit search results to a specific country (or a list of countries).
#'        Should be the ISO 3166-1alpha2 code,e.g. gb for the United Kingdom, de for Germany, etc.
#'        Format: \code{<countrycode>[,<countrycode>][,<countrycode>]...}
#' @param viewbox The preferred area to find search results. Format:
#'        \code{<left>,<top>,<right>,<bottom>}
#' @param bounded Restrict the results to only items contained with the bounding box.
#'        Restricting the results to the bounding box also enables searching by amenity only.
#'        For example a search query of just "[pub]" would normally be rejected
#'        but with \code{bounded=TRUE} will result in a list of items matching within the bounding box.
#' @param address_details Include a breakdown of the address into elements (TRUE == include)
#' @param exclude_place_ids If you do not want certain openstreetmap objects to appear in the search result,
#'        give a comma separated list of the place_id's you want to skip. This can be used
#'        to broaden search results. For example, if a previous query only returned a few
#'        results, then including those here would cause the search to return other, less
#'        accurate, matches (if possible). Format \code{<place_id,[place_id],[place_id]>}
#' @param limit Limit the number of returned results (numeric)
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
#' @export
#' @examples \dontrun{
#' osm_search("[bakery]+berlin+wedding", limit=5)
#' osm_search("Halifax", limit=3, country_codes="gb,ca")
#' }
osm_search <- function(query,
                       country_codes=NULL,
                       viewbox=NULL,
                       bounded=FALSE,
                       address_details=TRUE,
                       exclude_place_ids=NULL,
                       limit=1,
                       email=getOption("OSM_API_EMAIL", "nominatimrpackage@example.com"),
                       accept_language=getOption("LANG", "en-US,en;q=0.8"),
                       key = getOption("OSM_API_KEY", "")) {

  if (nchar(key) == 0) {
    stop('Please provide a openstreet API key')
  }

  bind_rows(pblapply(1:length(query), function(i) {

    param_base <- "format=json&dedupe=0&debug=0&polygon=0"
    if (!is.null(country_codes)) param_base <- sprintf("%s&countrycodes=%s", param_base, country_codes)
    if (!is.null(viewbox)) param_base <- sprintf("%s&viewbox=%s", param_base, viewbox)
    if (!is.null(bounded)) param_base <- sprintf("%s&bounded=%d", param_base, as.numeric(bounded))
    if (!is.null(exclude_place_ids)) param_base <- sprintf("%s&exclude_place_ids=%s", param_base, exclude_place_ids)
    if (!is.null(email)) param_base <- sprintf("%s&email=%s", param_base, curl::curl_escape(email))
    if (!is.null(accept_language)) param_base <- sprintf("%s&accept-language=%s", param_base, curl::curl_escape(accept_language))
    param_base <- sprintf("%s&key=%s", param_base, key)
    param_base <- sprintf("%s&addressdetails=%d", param_base, as.numeric(address_details))
    param_base <- sprintf("%s&limit=%d", param_base, as.numeric(limit))
    param_base <- sprintf("%s&q=%s", param_base, gsub(" ", "+", query[i]))

    if (length(query) > 1 & length(query) != i) Sys.sleep(getOption("NOMINATIM.DELAY"))

    .search(getOption("NOMINATIM.search_base"), param_base)

  }))

}

.search <- function(search_base, params) {

  tryCatch({

    res <- GET(search_base, query=params, timeout(getOption("NOMINATIM.TIMEOUT")))
    stop_for_status(res)

    ret <- content(res)

    if (length(ret) == 0) return(NULL)

    return(bind_rows(lapply(1:length(ret), function(i) {

      ret_names <- intersect(names(ret[[i]]),
                             c("place_id", "licence", "osm_type", "osm_id", "icon",
                               "lat", "lon", "display_name", "class", "type", "importance"))
      tmp_df <- data.frame(t(sapply(ret_names, function(x) { ret[[i]][[x]] })), stringsAsFactors=FALSE)

      if ("address" %in% names(ret[[i]])) {
        tmp_df <- cbind.data.frame(tmp_df,
                                   data.frame(t(sapply(names(ret[[i]][["address"]]),
                                                       function(x) { ret[[i]][["address"]][[x]]} )),
                                              stringsAsFactors=FALSE),
                                   stringsAsFactors=FALSE)
      }

      if ("boundingbox" %in% names(ret[[i]])) {
        tmp_df <- cbind.data.frame(tmp_df,
                                   bbox_left=as.numeric(ret[[i]]$boundingbox[[1]]),
                                   bbox_top=as.numeric(ret[[i]]$boundingbox[[2]]),
                                   bbox_right=as.numeric(ret[[i]]$boundingbox[[3]]),
                                   bbox_bottom=as.numeric(ret[[i]]$boundingbox[[4]]),
                                   stringsAsFactors=FALSE)
      }

      tmp_df$lat <- as.numeric(tmp_df$lat)
      tmp_df$lon <- as.numeric(tmp_df$lon)
      tmp_df$importance <- as.numeric(tmp_df$importance)

      tmp_df

    })))

  }, error=function(e) { message("Error connecting to geocode service", e)})

  return(NULL)

}
