#' An S4 class to represent the 2010 SF2 summary file
#'
#' @slot type Type of summary file ("SF2_2010")
#' @export
setClass("SF2_2010",
	slots = c(type = "character"),
	prototype = list(type = "SF2_2010")
)
