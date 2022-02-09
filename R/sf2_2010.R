#' @export
SF2_2010 = function()
{
	new("SF2_2010")
}

#' @export
setMethod("read_geo", c(sf = "SF2_2010", path = "character"), function(sf, path)
{
	# Read in the geo file, which is in a fixed width format. Information about
	# widths and column types is stored in this package.
	geo_dat = read_fwf(file = geo_path,
		col_positions = fwf_widths(sf2_2010_geo_cols[['FIELD_SIZE']]),
		col_types = paste0(sf2_2010_geo_cols[['DATA_TYPE']], collapse = ""))

	# Assign column headers based on access specifications
	colnames(geo_dat) = sf2_2010_geo_cols[['FIELD']]
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
	function(sf, base_url = "https://www2.census.gov/census_2010/05-Summary_File_2/")
{
	sf2_2010_states %>%
		mutate(URL = sprintf("%s/%s/%s2010.sf2.zip", base_url, NAME, tolower(ABBREV)))
})

#' @export
setMethod("get_data_urls", c(sf = "SF2_2010", base_url = "missing"),
	function(sf)
{
	base_url = "https://www2.census.gov/census_2010/05-Summary_File_2/"
	get_data_urls(sf, base_url)
})

