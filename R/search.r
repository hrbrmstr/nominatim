search_base <- "http://nominatim.openstreetmap.org/search"

#' Search for places
#'
#' Vectorized over \code{query}
#'
#' Nominatim indexes named (or numbered) features with the OSM data set and a subset of
#' other unnamed features (pubs, hotels, churches, etc).
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
#'        Either uses standard rfc2616 accept-language string or a simple comma separated l
#'        ist of language codes. The \code{LANG} option will be used, if set.
#' @export
#' @examples
#' osm_search("[bakery]+berlin+wedding", limit=5)
osm_search <- function(query,
                       country_codes=NULL,
                       viewbox=NULL,
                       bounded=FALSE,
                       address_details=TRUE,
                       exclude_place_ids=NULL,
                       limit=1,
                       email=getOption("OSM_API_EMAIL", "nominatimrpackage@example.com"),
                       accept_language=getOption("LANG", "en-US,en;q=0.8")) {


  bind_rows(pblapply(1:length(query), function(i) {

    param_base <- "format=json&dedupe=0&debug=0&polygon=0"
    if (!is.null(country_codes)) param_base <- sprintf("%s&country_codes=%s", param_base, country_codes)
    if (!is.null(viewbox)) param_base <- sprintf("%s&viewbox=%s", param_base, viewbox)
    if (!is.null(bounded)) param_base <- sprintf("%s&bounded=%d", param_base, as.numeric(bounded))
    if (!is.null(exclude_place_ids)) param_base <- sprintf("%s&exclude_place_ids=%s", param_base, exclude_place_ids)
    if (!is.null(email)) param_base <- sprintf("%s&email=%s", param_base, curl::curl_escape(email))
    if (!is.null(accept_language)) param_base <- sprintf("%s&accept-language=%s", param_base, curl::curl_escape(accept_language))
    param_base <- sprintf("%s&address_details=%d", param_base, as.numeric(address_details))
    param_base <- sprintf("%s&limit=%d", param_base, as.numeric(limit))
    param_base <- sprintf("%s&q=%s", param_base, gsub(" ", "+", query))

    .search(param_base)

  }))

}


.search <- function(params) {

  tryCatch({

    res <- GET(search_base, query=params)
    stop_for_status(res)

    ret <- content(res)

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

      tmp_df

    })))

  }, error=function(e) { message("Error connecting to geocode service", e)})

  return(NULL)

}
