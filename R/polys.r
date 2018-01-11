#' Search for places, returning a list of \code{SpatialPointsDataFrame},
#' \code{SpatialLinesDataFrame} or a \code{SpatialPolygonsDataFrame}
#'
#' Vectorized over \code{query}. If the return types are mixed (i.e. not all of the
#' same spatial type) the function will stop with an error.
#'
#' Nominatim indexes named (or numbered) features with the OSM data set and a subset of
#' other unnamed features (pubs, hotels, churches, etc).
#'
#' @note A slight delay is introduced between calls to both OpenStreetMap Nominatim &
#'       MapQuest Nominatim API to reduce load on their servers.
#'
#' Data (c) OpenStreetMap contributors, ODbL 1.0. \url{http://www.openstreetmap.org/copyright}\cr
#' Nominatim Usage Policy: \url{http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy}\cr
#' MapQuest Nominatim Terms of Use: \url{http://info.mapquest.com/terms-of-use/}\cr
#'
#' Search terms are processed first left to right and then right to left if that fails.
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
#'        Either uses standard rfc2616 accept-language string or a simple comma separated list
#'        of language codes. The \code{LANG} option will be used, if set.
#' @param key To access the openstreetmap API you need a valid API key. You can get it for free
#'        at \url{https://developer.mapquest.com}
#' @export
#' @examples \dontrun{
#' # returns SpatialPointsDataFrame
#' osm_search_spatial("[bakery]+berlin+wedding", limit=5)
#'
#' # returns SpatialLinesDataFrame
#' osm_search_spatial("135-7 pilkington avenue, birmingham", limit=10)
#'
#' # returns SpatialPolygonsDataFrame
#' osm_search_spatial("135 pilkington avenue, birmingham", limit=10)
#' }
osm_search_spatial <- function(query,
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

  pblapply(1:length(query), function(i) {

    param_base <- "format=json&dedupe=0&debug=0&polygon=0"
    if (!is.null(country_codes)) param_base <- sprintf("%s&country_codes=%s", param_base, country_codes)
    if (!is.null(viewbox)) param_base <- sprintf("%s&viewbox=%s", param_base, viewbox)
    if (!is.null(bounded)) param_base <- sprintf("%s&bounded=%d", param_base, as.numeric(bounded))
    if (!is.null(exclude_place_ids)) param_base <- sprintf("%s&exclude_place_ids=%s", param_base, exclude_place_ids)
    if (!is.null(email)) param_base <- sprintf("%s&email=%s", param_base, curl::curl_escape(email))
    if (!is.null(accept_language)) param_base <- sprintf("%s&accept-language=%s", param_base, curl::curl_escape(accept_language))
    param_base <- sprintf("%s&key=%s", param_base, key)
    param_base <- sprintf("%s&address_details=%d", param_base, as.numeric(address_details))
    param_base <- sprintf("%s&limit=%d", param_base, as.numeric(limit))
    param_base <- sprintf("%s&polygon_geojson=1", param_base)
    param_base <- sprintf("%s&q=%s", param_base, gsub(" ", "+", query))

    if (length(query) > 1 & length(query) != i) Sys.sleep(getOption("NOMINATIM.DELAY"))

    .search_poly(param_base)

  })

}


.search_poly <- function(params) {

  tryCatch({

    res <- GET(getOption("NOMINATIM.search_base"), query=params, timeout(getOption("NOMINATIM.TIMEOUT")))
    stop_for_status(res)

    ret <- jsonlite::fromJSON(content(res, as="text"))

    ret_cols <- intersect(colnames(ret),
                          c("place_id", "licence", "osm_type", "osm_id", "icon",
                            "lat", "lon", "display_name", "class", "type", "importance"))
    dat <- ret[, ret_cols]

    if ("boundingbox" %in% colnames(ret)) {
      bndbox <- do.call(rbind.data.frame, ret$boundingbox)
      colnames(bndbox) <- c("bbox_left", "bbox_top", "bbox_right", "bbox_bottom")
      dat <- cbind.data.frame(dat, bndbox)
    }

    if ("address" %in% colnames(ret)) {
      dat <- cbind.data.frame(dat, ret$address)
    }

    dat$lat <- as.numeric(dat$lat)
    dat$lon <- as.numeric(dat$lon)
    dat$importance <- as.numeric(dat$importance)

    if ("geojson" %in% colnames(ret)) {

      typ <- unique(ret$geojson$type)

      if (length(typ) == 1) {
        if (typ == "Point") {
          mat <- matrix(unlist(ret$geojson$coordinates), ncol=2, byrow=TRUE)
          return(SpatialPointsDataFrame(mat, dat))
        } else if (typ == "LineString") {
          mat <- lapply(lapply(ret$geojson$coordinates, matrix, ncol=2, byrow=TRUE), Line)
          mat_l <- lapply(1:length(mat), function(i) {
            Lines(mat[[i]], dat[i, "place_id"])
          })
          rownames(dat) <- dat[, "place_id"]
          return(SpatialLinesDataFrame(SpatialLines(mat_l), dat))
        } else if (typ == "Polygon") {
          mat <- lapply(lapply(ret$geojson$coordinates, matrix, ncol=2, byrow=TRUE), Polygon)
          mat_l <- lapply(1:length(mat), function(i) {
            Polygons(list(mat[[i]]), dat[i, "place_id"])
          })
          rownames(dat) <- dat[, "place_id"]
          return(SpatialPolygonsDataFrame(SpatialPolygons(mat_l), dat))
        }
      } else {
        stop("Returned shapes from Nominatim API are incomptible", call.=FALSE)
      }

    }

  }, error=function(e) { message("Error connecting to geocode service", e)})

  return(NULL)

}
#
# geojson_to_spatial <- function(geojson_string) {
#
#   tmp_file <- tempfile()
#   writeLines(geojson_string, tmp_file)
#   spat <- readOGR(tmp_file, "OGRGeoJSON", stringsAsFactors=FALSE, verbose=FALSE)
#   unlink(tmp_file)
#   return(sp)
#
# }
#
