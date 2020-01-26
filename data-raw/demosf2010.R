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

cols = read_xlsx("~/Documents/datasets/demo_2010_us/2020-census-data-products-planning-crosswalk.xlsx",
	sheet = "DHC Tables", skip = 1, n_max = 1, col_names = FALSE)
col_names = c("NUMBER", "CELL_COUNT", "INDENT", sprintf("DESC%d", 1:7))
col_types = c("text", "numeric", "numeric", rep("text", 7))
demosf2010_dhc_dd =
	read_xlsx("~/Documents/datasets/demo_2010_us/2020-census-data-products-planning-crosswalk.xlsx",
		sheet = "DHC Tables", skip = 3, col_names = col_names, col_types = col_types) %>%
	filter(!is.na(NUMBER))
demosf2010_dhc_dd$NUMBER = str_replace(demosf2010_dhc_dd$NUMBER, pattern = "\\.", replacement = "")
dest_file = sprintf("%s/%s.rda", dest_path, "demosf2010_dhc_dd")
save(demosf2010_dhc_dd, file = dest_file)

# I got this information from the "2010_Demonstration_Data_Product_Technical_Document" PDF.
# The accompanying Excel file did not appear to be accurate.
# ORDERID here is just a guess based on Figure 2-2.
demosf2010_dhc_segments = tribble(
	~NUMBER, ~SEGMENT, ~NCOLS, ~ORDERID,
	"P1", 1, 1, 1,
	"P3", 1, 8, 2,
	"P4", 1, 3, 3,
	"P5", 1, 17, 4,
	"P6", 1, 7, 5,
	"P7", 1, 15, 6,
	"P12", 1, 49, 7,
	"P13", 1, 3, 8,
	"P14", 1, 43, 9,
	"P15", 1, 17, 10,
	"P16", 1, 3, 11,
	"P18", 1, 9, 12,
	"P19", 1, 19, 13,
	"P20", 1, 19, 14,
	"P22", 1, 21, 15,
	"P23", 1, 15, 16,
	"P24", 2, 11, 1,
	"P25", 2, 11, 2,
	"P26", 2, 11, 3,
	"P28", 2, 16, 4,
	"P38", 2, 20, 5,
	"P43", 2, 63, 6,
	"P12A", 2, 49, 7,
	"P12B", 2, 49, 8,
	"P12C", 3, 49, 1,
	"P12D", 3, 49, 2,
	"P12E", 3, 49, 3,
	"P12F", 3, 49, 4,
	"P12G", 3, 49, 5,
	"P12H", 4, 49, 1,
	"P12I", 4, 49, 2,
	"P13A", 4, 3, 3,
	"P13B", 4, 3, 4,
	"P13C", 4, 3, 5,
	"P13D", 4, 3, 6,
	"P13E", 4, 3, 7,
	"P13F", 4, 3, 8,
	"P13G", 4, 3, 9,
	"P13H", 4, 3, 10,
	"P13I", 4, 3, 11,
	"P18A", 4, 9, 12,
	"P18B", 4, 9, 13,
	"P18C", 4, 9, 14,
	"P18D", 4, 9, 15,
	"P18E", 4, 9, 16,
	"P18F", 4, 9, 17,
	"P18G", 4, 9, 18,
	"P18H", 4, 9, 19,
	"P18I", 4, 9, 20,
	"P28A", 4, 16, 21,
	"P28B", 4, 16, 22,
	"P28C", 5, 16, 1,
	"P28D", 5, 16, 2,
	"P28E", 5, 16, 3,
	"P28F", 5, 16, 4,
	"P28G", 5, 16, 5,
	"P28H", 5, 16, 6,
	"P28I", 5, 16, 7,
	"P38A", 5, 20, 8,
	"P38B", 5, 20, 9,
	"P38C", 5, 20, 10,
	"P38D", 5, 20, 11,
	"P38E", 5, 20, 12,
	"P38F", 5, 20, 13,
	"P38G", 6, 20, 1,
	"P38H", 6, 20, 2,
	"P38I", 6, 20, 3,
	"PCT12", 7, 209, 1,
	"PCT13", 8, 49, 1,
	"PCT14", 8, 3, 2,
	"PCT14A", 8, 3, 3,
	"PCT14A", 8, 3, 4,
	"PCT14B", 8, 3, 5,
	"PCT14C", 8, 3, 6,
	"PCT14D", 8, 3, 7,
	"PCT14E", 8, 3, 8,
	"PCT14F", 8, 3, 9,
	"PCT14G", 8, 3, 10,
	"PCT14I", 8, 3, 11,
	"PCT15", 8, 12, 12,
	"PCT18", 8, 15, 13,
	"PCT22", 8, 21, 14,
	"PCO1", 9, 39, 1,
	"PCO2", 9, 39, 2,
	"PCO3", 9, 39, 3,
	"PCO4", 9, 39, 4,
	"PCO5", 9, 39, 5,
	"PCO6", 9, 39, 6,
	"PCO7", 10, 39, 1,
	"PCO8", 10, 39, 2,
	"PCO9", 10, 39, 3,
	"PCO10", 10, 39, 4,
	"PCO43A", 11, 63, 1,
	"PCO43B", 11, 63, 2,
	"PCO43C", 11, 63, 3,
	"PCO43D", 12, 63, 1,
	"PCO43E", 12, 63, 2,
	"PCO43F", 12, 63, 3,
	"PCO43G", 13, 63, 1,
	"PCO43H", 13, 63, 2,
	"PCO43I", 13, 63, 3,
	"H1", 14, 1, 1,
	"H3", 14, 3, 2,
	"H6", 14, 8, 3,
	"H7", 14, 17, 3,
	"H10", 14, 1, 3,
	"H13", 14, 8, 3
)
dest_file = sprintf("%s/%s.rda", dest_path, "demosf2010_dhc_segments")
save(demosf2010_dhc_segments, file = dest_file)

demosf2010_dhc_tables = demosf2010_dhc_dd %>%
	select(NUMBER = NUMBER, DESCRIPTION = DESC1) %>%
	filter(!str_detect(DESCRIPTION, "^Universe:")) %>%
	filter(str_detect(DESCRIPTION, "\\[")) %>%
	filter(str_detect(DESCRIPTION, "\\]")) %>%
	inner_join(demosf2010_dhc_segments, by = c("NUMBER" = "NUMBER")) %>%
	select(NUMBER, DESCRIPTION)
dest_file = sprintf("%s/%s.rda", dest_path, "demosf2010_dhc_tables")
save(demosf2010_dhc_tables, file = dest_file)
