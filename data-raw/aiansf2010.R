library(readr)
library(dplyr)
library(stringr)

src_path = "C:/Users/raim0001/Documents/aian_2010_us"
dest_path = sprintf("%s/%s", getwd(), "data")

# There are 76 total levels; I'm just specifying the levels that seem
# most important right now. I'm also ignoring fields further to the
# right that aren't crucial to navigating the main tables.
#
# This does not appear to be provided in the MS Access database that's
# packaged with the dataset...
aiansf2010_geo_cols = list(
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
dest_file = sprintf("%s/%s.rda", dest_path, "aiansf2010_geo_cols")
save(aiansf2010_geo_cols, file = dest_file)

# The following files come from 2010_AIANSF_MSAccessShell.zip, which is
# provided along with the dataset. I can't directly read Access DBs from
# R (I think I'm missing an ODBC driver), so I opened it in Access, and
# exported each table to a CSV. Then I read the CSVs here and save them
# to R datasets.

ff = sprintf("%s/%s", src_path, "ITERATIONS.csv")
aiansf2010_iterations = read_csv(ff, col_types = cols(SORTID = col_integer()))
dest_file = sprintf("%s/%s.rda", dest_path, "aiansf2010_iterations")
save(aiansf2010_iterations, file = dest_file)

ff = sprintf("%s/%s", src_path, "AIAN_GeoHeader.csv")
aiansf2010_geoheader = read_csv(ff)
dest_file = sprintf("%s/%s.rda", dest_path, "aiansf2010_geoheader")
save(aiansf2010_geoheader, file = dest_file)

ff = sprintf("%s/%s", src_path, "DataDictionary_NOTES.csv")
aiansf2010_geoheader_dd_notes = read_csv(ff)
dest_file = sprintf("%s/%s.rda", dest_path, "aiansf2010_geoheader_dd_notes")
save(aiansf2010_geoheader_dd_notes, file = dest_file)

ff = sprintf("%s/%s", src_path, "DATA_DICTIONARY.csv")
aiansf2010_geoheader_dd = read_csv(ff, col_types = cols(DECIMAL = col_integer()), trim_ws = FALSE)
dest_file = sprintf("%s/%s.rda", dest_path, "aiansf2010_geoheader_dd")
save(aiansf2010_geoheader_dd, file = dest_file)

ff = sprintf("%s/%s", src_path, "GeoHeader_Specifications.csv")
aiansf2010_GeoHeader_Specifications = read_csv(ff,
	col_types = cols(`FIELD SIZE` = col_integer(), `STARTING POSITION` = col_integer()))
dest_file = sprintf("%s/%s.rda", dest_path, "aiansf2010_GeoHeader_Specifications")
save(aiansf2010_GeoHeader_Specifications, file = dest_file)

for (i in 1:11) {
	ff = sprintf("%s/AIANSF_Segment_%02d.csv", src_path, i)
	dat = read_csv(ff)
	dat_name = sprintf("aiansf2010_segment%02d", i)
	assign(dat_name, dat)
	dest_file = sprintf("%s/%s.rda", dest_path, dat_name)
	save(list = dat_name, file = dest_file)
}

# Create a list of available tables, along with their segments
aiansf2010_tables = aiansf2010_geoheader_dd %>%
	filter(is.na(`FIELD CODE`)) %>%
	filter(!str_detect(`FIELD NAME`, "^Universe:")) %>%
	filter(str_detect(`FIELD NAME`, "\\[")) %>%
	filter(str_detect(`FIELD NAME`, "\\]")) %>%
	arrange(SORTID) %>%
	select(SEGMENT = `DATA SEGMENT`, NUMBER = `TABLE NUMBER`, DESCRIPTION = `FIELD NAME`)

dest_file = sprintf("%s/%s.rda", dest_path, "aiansf2010_tables")
save(aiansf2010_tables, file = dest_file)
