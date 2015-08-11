#' Bounding box (and other metadata) lookup
#'
#' Perform a general \href{https://nominatim.openstreetmap.org/}{Nominatim} query
#' and retrieve \code{place} metadata, including bounding box information
#'
#' @param query search terms to pass to OSM Nominatim
#' @param viewbox (optional) one of:
#'   \itemize{
#'     \item{an atomic character vector with comma-separated values (e.g. \code{"-4.37,54.88,2.04,52.96"})}
#'     \item{a 4-element vector specifying the viewbox (e.g. \code{c(-4.37,54.88,2.04,52.96)})}
#'     \item{a named 4-element vector with \code{top}, \code{left}, \code{bottom}, \code{right} identified
#'           (e.g. \code{c(top=-4.37, left=54.88, bottom=2.04, right=52.96)}) in any order}
#'     \item{a 2x2 matrix as returned by \code{\link[sp]{bbox}}; i.e. with rownames of \code{x} and \code{y} and
#'           column names of \code{min} and \code{max}}
#'   }
#'
#' @return \code{data.frame} of places with metatata, including bounding box information
#' @export
#' @examples
#' bb_lookup("West Yorkshire", c(-4.37, 54.88, 2.04, 52.96))
#' bb_lookup("West Yorkshire", "-4.37,54.88,2.04,52.96")
#' bb_lookup("West Yorkshire", c(top=-4.37, left=54.88, bottom=2.04, right=52.96))
#' bb_lookup("United States")
bb_lookup <- function(query, viewbox=NULL) {

  if (!is.null(viewbox)) {
    if (inherits(viewbox, "matrix")) {
      if (all(rownames(viewbox) %in% c("x", "y")    ) &
          all(colnames(viewbox) %in% c("min", "max"))) {
        viewbox <- c(viewbox["y", "max"], viewbox["x", "min"], viewbox["y", "min"], viewbox["x", "max"])
        viewbox <- paste0(viewbox, collapse=",")
      } else {
        stop("When 'viewbox' is specified as a matrix, it must be in sp::bbox format", call.=FALSE)
      }
    } else {
      if (length(viewbox) > 1 & length(viewbox) == 4) {
        if (all(names(viewbox) %in% c("top", "left", "bottom", "right"))) {
          viewbox <- paste0(viewbox[c("top", "left", "bottom", "right")], collapse=",")
        } else {
          viewbox <- paste0(viewbox, collapse=",")
        }
      } else {
        stop(paste0("'viewbox' must either be 'NULL', a single-length, comma-separated vector ",
                    "or a numeric or character vector of length 4"), call.=FALSE)
      }
    }
  }

  res <- GET("https://nominatim.openstreetmap.org",
             query=list(q=query,
                        viewbox=viewbox,
                        format='json'))

  dat <- jsonlite::fromJSON(content(res, as='text'))

  if ("boundingbox" %in% colnames(dat)) {
    good_cols <- setdiff(colnames(dat), "boundingbox")
    bbox <- setNames(do.call(rbind.data.frame, dat$boundingbox), c("bottom", "top", "left", "right"))
    cbind.data.frame(dat[,good_cols], bbox, stringsAsFactors=FALSE)
  } else {
    dat
  }

}
