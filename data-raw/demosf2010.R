library(tibble)
library(readxl)
library(dplyr)
library(stringr)

dest_path = sprintf("%s/%s", getwd(), "data")

demosf2010_states = tribble(
	~name, ~abbreviation,
	"Alabama", "al",
	"Alaska", "ak",
	"Arizona", "az",
	"Arkansas", "ar",
	"California", "ca",
	"Colorado", "co",
	"Connecticut", "ct",
	"Delaware", "de",
	"District_of_Columbia", "dc",
	"Florida", "fl",
	"Georgia", "ga",
	"Hawaii", "hi",
	"Idaho", "id",
	"Illinois", "il",
	"Indiana", "in",
	"Iowa", "ia",
	"Kansas", "ks",
	"Kentucky", "ky",
	"Louisiana", "la",
	"Maine", "me",
	"Maryland", "md",
	"Massachusetts", "ma",
	"Michigan", "mi",
	"Minnesota", "mn",
	"Mississippi", "ms",
	"Missouri", "mo",
	"Montana", "mt",
	"National", "us",
	"Nebraska", "nb",
	"Nevada", "nv",
	"New_Hampshire", "nh",
	"New_Jersey", "nj",
	"New_Mexico", "nm",
	"New_York", "ny",
	"North_Carolina", "nc",
	"North_Dakota", "nd",
	"Ohio", "oh",
	"Oklahoma", "ok",
	"Oregon", "or",
	"Pennsylvania", "pa",
	"Puerto_Rico", "pr",
	"Rhode_Island", "ri",
	"South_Carolina", "sc",
	"South_Dakota", "sd",
	"Tennessee", "tn",
	"Texas", "tx",
	"Utah", "ut",
	"Vermont", "vt",
	"Virginia", "va",
	"Washington", "wa",
	"West_Virginia", "wv",
	"Wisconsin", "wi",
	"Wyoming", "wy")
dest_file = sprintf("%s/%s.rda", dest_path, "demosf2010_states")
save(demosf2010_states, file = dest_file)

demosf2010_geo_cols = list(
	'010' = fwf_widths(c(6,2,3,2,3,2,7),
		col_names = c('FILEID', 'STUSAB', 'SUMLEV', 'GEOCOMP', 'CHARITER',
					  'CIFSN', 'LOGRECNO')),
	'020' = fwf_widths(c(6,2,3,2,3,2,7,1),
		col_names = c('FILEID', 'STUSAB', 'SUMLEV', 'GEOCOMP', 'CHARITER',
					  'CIFSN', 'LOGRECNO', 'REGION')),
	'030' = fwf_widths(c(6,2,3,2,3,2,7,1,1),
		col_names = c('FILEID', 'STUSAB', 'SUMLEV', 'GEOCOMP', 'CHARITER',
					  'CIFSN', 'LOGRECNO', 'REGION', 'DIVISION')),
	'040' = fwf_widths(c(6,2,3,2,3,2,7,1,1,2),
		col_names = c('FILEID', 'STUSAB', 'SUMLEV', 'GEOCOMP', 'CHARITER',
					  'CIFSN', 'LOGRECNO', 'REGION', 'DIVISION', 'STATE')),
	'050' = fwf_widths(c(6,2,3,2,3,2,7,1,1,2,3),
		col_names = c('FILEID', 'STUSAB', 'SUMLEV', 'GEOCOMP', 'CHARITER',
					  'CIFSN', 'LOGRECNO', 'REGION', 'DIVISION', 'STATE',
					  'COUNTY')),
	'140' = fwf_widths(c(6,2,3,2,3,2,7,1,1,2,3,2,2,18,6),
		col_names = c('FILEID', 'STUSAB', 'SUMLEV', 'GEOCOMP', 'CHARITER',
					  'CIFSN', 'LOGRECNO', 'REGION', 'DIVISION', 'STATE',
					  'COUNTY', 'COUNTYCC', 'COUNTYSC', 'JUNK', 'TRACT'))
)
dest_file = sprintf("%s/%s.rda", dest_path, "demosf2010_geo_cols")
save(demosf2010_geo_cols, file = dest_file)

cols = read_xlsx("~/Documents/datasets/demosf2010/2020-census-data-products-planning-crosswalk.xlsx", sheet = "DHC Tables", skip = 1, n_max = 1, col_names = FALSE)
col_names = c("NUMBER", "CELL_COUNT", "INDENT", sprintf("DESC%d", 1:7))
col_types = c("text", "numeric", "numeric", rep("text", 7))
demosf2010_dhc_dd =
	read_xlsx("~/Documents/datasets/demosf2010/2020-census-data-products-planning-crosswalk.xlsx",
		sheet = "DHC Tables", skip = 3, col_names = col_names, col_types = col_types) %>%
	filter(!is.na(NUMBER))
dest_file = sprintf("%s/%s.rda", dest_path, "demosf2010_dhc_dd")
save(demosf2010_dhc_dd, file = dest_file)

demosf2010_dhc_tables = demosf2010_dhc_dd %>%
	select(NUMBER = NUMBER, DESCRIPTION = DESC1) %>%
	filter(!str_detect(DESCRIPTION, "^Universe:")) %>%
	filter(str_detect(DESCRIPTION, "\\[")) %>%
	filter(str_detect(DESCRIPTION, "\\]"))
dest_file = sprintf("%s/%s.rda", dest_path, "demosf2010_dhc_tables")
save(demosf2010_dhc_tables, file = dest_file)
