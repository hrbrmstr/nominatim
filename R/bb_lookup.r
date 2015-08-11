#' Bounding box (and other metadata) lookup
#'
#' Perform a general \href{https://nominatim.openstreetmap.org/}{Nominatim} query
#' and retrieve \code{place} metadata, including bounding box information
#'
#' @param query search terms to pass to OSM Nominatim
#' @param viewbox (optional) atomic character vector with comma-separated values
#'               (e.g. \code{"-4.37,54.88,2.04,52.96"}) or a 4-element vector
#'               specifying the viewbox (e.g. \code{c(-4.37,54.88,2.04,52.96)}).
#'
#' @return \code{data.frame} of places with metatata, including bounding box information
#' @export
#' @examples
#' bb_lookup("West Yorkshire", c(-4.37, 54.88, 2.04, 52.96))
#' bb_lookup("United States")
bb_lookup <- function(query, viewbox=NULL) {

  if (!is.null(viewbox)) {
    if (length(viewbox) > 1 & length(viewbox) == 4) {
      viewbox <- paste0(viewbox)
    } else {
      stop(paste0("'viewbox' must either be 'NULL', a single-length, comma-separated vector ",
                  "or a numeric or character vector of length 4"), call.=FALSE)
    }
  }

  res <- GET("https://nominatim.openstreetmap.org",
             query=list(q=query,
                        viewbox=viewbox,
                        format='json'))

  dat <- jsonlite::fromJSON(content(res, as='text'))

  if ("boundingbox" %in% colnames(dat)) {
    good_cols <- setdiff(colnames(dat), "boundingbox")
    bbox <- setNames(do.call(rbind.data.frame, dat$boundingbox), c("top", "left", "bottom", "right"))
    cbind.data.frame(dat[,good_cols], bbox, stringsAsFactors=FALSE)
  } else {
    dat
  }

}
