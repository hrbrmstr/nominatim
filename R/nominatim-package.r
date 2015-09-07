#' An interface between R and the OpenStreeMap Nominatim API
#'
#' Most queries are run against the MapQuest Nominatim API as per the OpenStreetMap
#' recommendation.
#'
#' Data (c) OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright\cr
#' Nominatim Usage Policy: http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy\cr
#' MapQuest Nominatim Terms of Use: http://info.mapquest.com/terms-of-use/\cr
#'
#' \url{http://wiki.openstreetmap.org/wiki/Nominatim}
#' @name nominatim
#' @note A slight delay is introduced between calls as both OpenStreetMap Nominatim &
#'       MapQuest Nominatim API calls to reduce load on their servers.
#' @docType package
#' @author Bob Rudis (@@hrbrmstr)
#' @import httr dplyr pbapply utils sp
#' @importFrom jsonlite fromJSON
#' @importFrom curl curl_escape
#' @importFrom stats setNames
NULL
