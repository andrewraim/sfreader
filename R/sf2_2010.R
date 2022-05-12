# Declare global variables within package to pass CRAN check
globalVariables("sf2_2010_states")
globalVariables("sf2_2010_geo_format")
globalVariables(c("ABBREV", "NAME"))

#' @export
SF2_2010 = function()
{
	new("SF2_2010")
}

#' read_geo
#'
#' @param sf a summary file object.
#' @param path path to a geo file corresponding to \code{sf}.
#'
#' @description
#' Read a geo file from the 2010 SF2 summary file into a \code{tibble}. See
#' documentation for generic.
#'
#' @export
setMethod("read_geo", c(sf = "SF2_2010", path = "character"), function(sf, path)
{
	# Read in the geo file, which is in a fixed width format. Information about
	# widths and column types is stored in this package.
	geo_dat = read_fwf(file = path,
		col_positions = fwf_widths(sf2_2010_geo_format[['FIELD_SIZE']]),
		col_types = paste0(sf2_2010_geo_format[['DATA_TYPE']], collapse = ""))

	# Assign column headers based on access specifications
	colnames(geo_dat) = sf2_2010_geo_format[['FIELD']]
	return(geo_dat)
})

#' @export
setMethod("interpret_data_filenames", c(sf = "SF2_2010", path = "character"), function(sf, paths)
{
	filenames = basename(paths)
	match_out = str_match(filenames, '([\\w]{2})([\\d]{3})([\\d]{2})([\\d]{4})\\.(.*)')
	tibble(
		STATE = match_out[,2],
		ITERATION_CODE = match_out[,3],
		SEGMENT = match_out[,4],
		YEAR = match_out[,5],
		SF_TYPE = match_out[,6],
		PATH = paths
	)
})

#' @export
setMethod("get_data_urls", c(sf = "SF2_2010", base_url = "character"),
	function(sf, base_url)
{
	sf2_2010_states %>%
		mutate(URL = sprintf("%s/%s/%s2010.sf2.zip", base_url, NAME, tolower(ABBREV))) %>%
		select(-NAME, -ABBREV)
})

#' @export
setMethod("get_data_urls", c(sf = "SF2_2010", base_url = "missing"),
	function(sf)
{
	base_url = "https://www2.census.gov/census_2010/05-Summary_File_2"
	get_data_urls(sf, base_url)
})

#' @export
setMethod("get_filename_patterns", c(sf = "SF2_2010"), function(sf)
{
	tribble(~TYPE, ~PATTERN,
		"geo", '(\\w){2}geo(\\d){4}.sf2',
		"data", '(\\w){2}(\\d){3}(\\d){2}(\\d){4}.sf2'
	)
})

#' SF2 2010 Geo File Columns
#'
#' A dataset which describes the fixed width file format.
#'
#' @format A data frame with 101 rows and 6 columns:
#' \describe{
#'   \item{ID}{Unique ID for the field.}
#'   \item{FIELD}{Name of the field.}
#'   \item{START_POS}{Starting position of the field.}
#'   \item{FIELD_SIZE}{Size of the field.}
#'   \item{DATA_TYPE}{Type of the data contained in the field.}
#'   \item{DESCRIPTION}{Description of the geo field.}
#' }
#' @source \url{https://www.census.gov/data/datasets/2010/dec/summary-file-2.html}
"sf2_2010_geo_format"

#' SF2 2010 Geographic Component Definitions
#'
#' A dataset with definitions of geographic components (GEOCOMPs).
#'
#' @format A data frame with 114 rows and 2 columns:
#' \describe{
#'   \item{CODE}{Code used in the summary file data.}
#'   \item{DESCRIPTION}{Description of the geographic component.}
#' }
#' @source \url{https://www.census.gov/data/datasets/2010/dec/summary-file-2.html}
"sf2_2010_geocomp"

#' SF2 2010 Characteristic Iterations
#'
#' A dataset with definitions of characteristic iterations (CHARITERs).
#'
#' @format A data frame with 331 rows and 2 columns:
#' \describe{
#'   \item{CODE}{Code used in the summary file data.}
#'   \item{DESCRIPTION}{Description of the characteristic iteration.}
#' }
#' @source \url{https://www.census.gov/data/datasets/2010/dec/summary-file-2.html}
"sf2_2010_iterations"


#' SF2 2010 Fields
#'
#' @format A data frame with 1575 rows and 6 columns:
#' \describe{
#'   \item{SEGMENT}{Segment associated with the variable.}
#'   \item{POSITION}{Position of the variable in the file for the given segment.}
#'   \item{FIELD}{Name of the variable.}
#'   \item{PARENT_FIELD}{Name of this variable's parent variable.}
#'   \item{TABLE}{Name of the logical table associated with this variable.}
#'   \item{NAME}{Description of the variable.}
#'   \item{DESCRIPTION}{Fully qualified name of the variable based on table hierarchy.}
#' }
#'
#' @details
#' A summary file contains a number of "logical" tables which are partitioned
#' into 11 types of data files; each file type contains a segment of containing
#' the variables of one or more of the logical tables. Variables within a table
#' are defined as a hierarchical structure where each may be contain one or more
#' child variables.
#'
#' This dataset enumerates the variables contained within each segment, so that
#' the column names can be overlaid onto the data as headers.
#'
#' This dataset also provides a mapping from each variable to the logical table
#' to which it belongs. An value of \code{HEAD} indicates that the variable is
#' part of the header and does not belong to a logical table.
#'
#' The hierarchical structure of each table may be accessed via the
#' \code{PARENT_FIELD} variable. This variable specifies the parent in the
#' hierarchy, or is \code{NA} if it at the top level of the hierarchy.
#'
#' @source \url{https://www.census.gov/data/datasets/2010/dec/summary-file-2.html}
"sf2_2010_fields"

#' SF2 2010 States
#'
#' A dataset containing state (and US) information for which summary files are
#' defined. Names and abbreviations correspond to those in the files.
#'
#' @format A data frame with 53 rows and 3 columns:
#' \describe{
#'   \item{NAME}{Name of the state.}
#'   \item{FIPS}{FIPS code associated with the state (or \code{NA} for the
#'   national level).}
#'   \item{ABBREV}{Name of the variable (or \code{US} for the national level).}
#' }
#' @source \url{https://www.census.gov/data/datasets/2010/dec/summary-file-2.html}
"sf2_2010_states"

#' SF2 2010 Tables
#'
#' A dataset containing logical tables defined in the summary files.
#'
#' @format A data frame with 71 rows and 3 columns:
#' \describe{
#'   \item{TABLE}{Name of the table.}
#'   \item{DESCRIPTION}{Description of the table.}
#' }
#' @source \url{https://www.census.gov/data/datasets/2010/dec/summary-file-2.html}
"sf2_2010_tables"

#' SF2 2010 Summary Levels
#'
#' A dataset containing summary levels for state-specific files.
#'
#' \describe{
#'   \item{CODE}{Code of the summary level.}
#'   \item{PARENT_CODE}{Name of the table.}
#'   \item{DESCRIPTION}{Description of the summary level.}
#'   \item{TYPE}{\code{NATIONAL} or \code{STATE}.}
#'   \item{GQ}{Boolean; \code{TRUE} if level applies to GQs.}
#' }
#'
#' @details
#' Summary levels specify geography levels of the data. They follow a
#' hierarchical structure, which can be accessed using the \code{PARENT_CODE}
#' variable. A value of \code{NA} indicates the summary level is at the top
#' level of the hierarchy. Use the \code{TYPE} and \code{GQ} fields to select
#' the correct hierarchy corresponding to state-specific or national files,
#' and whether group quarters data are in use.
#'
#' @source \url{https://www.census.gov/data/datasets/2010/dec/summary-file-2.html}
#' @name sf2_2010_sumlev
"sf2_2010_sumlev"
