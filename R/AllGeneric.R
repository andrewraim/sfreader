#' read_geo
#'
#' @description
#' Read a geo file into a \code{tibble}.
#'
#' @param sf a summary file object.
#' @param path path to a geo file corresponding to \code{sf}.
#'
#' @return A \code{tibble} with the contents of the geo file.
#'
#' @export
setGeneric("read_geo", function(sf, path) standardGeneric("read_geo"))

#' interpret_data_filenames
#'
#' @description
#' Parse encoded filenames into a \code{tibble} which can be more easily
#' viewed and processed.
#'
#' @param sf a summary file object.
#' @param paths a vector of paths to data files corresponding to \code{sf}.
#'
#' @return A \code{tibble}.
#'
#' @export
setGeneric("interpret_data_filenames", function(sf, paths) standardGeneric("interpret_data_filenames"))

#' get_data_urls
#'
#' @description
#' Get URLs of data for the given summary file.
#'
#' @param sf a summary file object.
#' @param base_url the base URL for the data files. Default value is last known
#' location at the time this version of the package was prepared.
#'
#' @return A \code{tibble}.
#'
#' @export
setGeneric("get_data_urls", function(sf, base_url = "ANY") standardGeneric("get_data_urls"))

#' get_filename_patterns
#'
#' @description
#' Get patterns which can be used to identify geo files and data files relevant
#' to the given summary file.
#'
#' @param sf a summary file object.
#'
#' @return A \code{tibble}.
#'
#' @export
setGeneric("get_filename_patterns", function(sf) standardGeneric("get_filename_patterns"))
