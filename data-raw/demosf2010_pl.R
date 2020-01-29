library(tibble)
library(readr)
library(readxl)
library(dplyr)
library(stringr)

dest_path = sprintf("%s/%s", getwd(), "data")

demosf2010_pl_geo_cols = list(
	'010' = fwf_widths(c(6,2,3,2,2,3,2,7,60,51),
		col_names = c('FILEID', 'STUSAB', 'SUMLEV', 'GEOVAR', 'GEOCOMP', 'CHARITER',
					  'CIFSN', 'LOGRECNO', 'GEOID', 'GEOCODE')),
	'020' = fwf_widths(c(6,2,3,2,2,3,2,7,60,51,1),
		col_names = c('FILEID', 'STUSAB', 'SUMLEV', 'GEOVAR', 'GEOCOMP', 'CHARITER',
					  'CIFSN', 'LOGRECNO', 'GEOID', 'GEOCODE', 'REGION')),
	'030' = fwf_widths(c(6,2,3,2,2,3,2,7,60,51,1,1),
		col_names = c('FILEID', 'STUSAB', 'SUMLEV', 'GEOVAR', 'GEOCOMP', 'CHARITER',
					  'CIFSN', 'LOGRECNO', 'GEOID', 'GEOCODE', 'REGION', 'DIVISION')),
	'040' = fwf_widths(c(6,2,3,2,2,3,2,7,60,51,1,1,2),
		col_names = c('FILEID', 'STUSAB', 'SUMLEV', 'GEOVAR', 'GEOCOMP', 'CHARITER',
					  'CIFSN', 'LOGRECNO', 'GEOID', 'GEOCODE', 'REGION', 'DIVISION', 'STATE')),
	'050' = fwf_widths(c(6,2,3,2,2,3,2,7,60,51,1,1,2,3),
		col_names = c('FILEID', 'STUSAB', 'SUMLEV', 'GEOVAR', 'GEOCOMP', 'CHARITER',
					  'CIFSN', 'LOGRECNO', 'GEOID', 'GEOCODE', 'REGION', 'DIVISION', 'STATE',
					  'COUNTY')),
	'140' = fwf_widths(c(6,2,3,2,2,3,2,7,60,51,1,1,2,3,10,6),
		col_names = c('FILEID', 'STUSAB', 'SUMLEV', 'GEOVAR', 'GEOCOMP', 'CHARITER',
					  'CIFSN', 'LOGRECNO', 'GEOID', 'GEOCODE', 'REGION', 'DIVISION', 'STATE',
					  'COUNTY', 'JUNK', 'TRACT'))
)
dest_file = sprintf("%s/%s.rda", dest_path, "demosf2010_pl_geo_cols")
save(demosf2010_pl_geo_cols, file = dest_file)

# cols = read_xlsx("~/Documents/datasets/demosf2010/2020-census-data-products-planning-crosswalk.xlsx", sheet = "PL Tables", skip = 1, n_max = 1, col_names = FALSE)
cols = read_xlsx("~/datasets/demo_2010_us/2020-census-data-products-planning-crosswalk.xlsx", sheet = "PL Tables", skip = 1, n_max = 1, col_names = FALSE)
col_names = c("NUMBER", "CELL_COUNT", "INDENT", sprintf("DESC%d", 1:5))
col_types = c("text", "numeric", "numeric", rep("text", 5))
demosf2010_pl_dd =
	# read_xlsx("~/Documents/datasets/demosf2010/2020-census-data-products-planning-crosswalk.xlsx",
	read_xlsx("~/datasets/demo_2010_us/2020-census-data-products-planning-crosswalk.xlsx",
		sheet = "PL Tables", skip = 2, col_names = col_names, col_types = col_types) %>%
	filter(!is.na(NUMBER))
demosf2010_pl_dd$NUMBER = str_replace(demosf2010_pl_dd$NUMBER, pattern = "\\.", replacement = "")
dest_file = sprintf("%s/%s.rda", dest_path, "demosf2010_pl_dd")
save(demosf2010_pl_dd, file = dest_file)

# I got this information from the "2010_Demonstration_Data_Product_Technical_Document" PDF.
# The accompanying Excel file did not appear to be accurate.
# ORDERID here is just a guess based on Figure 2-2.
demosf2010_pl_segments = tribble(
	~NUMBER, ~SEGMENT, ~NCOLS, ~ORDERID,
	"P1", 1, 71, 1,
	"P2", 1, 73, 2,
	"P3", 2, 71, 1,
	"P4", 2, 73, 2,
	"P5", 3, 10, 1,
	"H1", 2, 3, 1
)
dest_file = sprintf("%s/%s.rda", dest_path, "demosf2010_pl_segments")
save(demosf2010_pl_segments, file = dest_file)

demosf2010_pl_tables = demosf2010_pl_dd %>%
	select(NUMBER = NUMBER, DESCRIPTION = DESC1) %>%
	filter(!str_detect(DESCRIPTION, "^Universe:")) %>%
	filter(str_detect(DESCRIPTION, "\\[")) %>%
	filter(str_detect(DESCRIPTION, "\\]")) %>%
	inner_join(demosf2010_pl_segments, by = c("NUMBER" = "NUMBER")) %>%
	select(NUMBER, DESCRIPTION)
dest_file = sprintf("%s/%s.rda", dest_path, "demosf2010_pl_tables")
save(demosf2010_pl_tables, file = dest_file)
