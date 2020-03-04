library(readr)
library(dplyr)
library(stringr)

src_path = "C:/Users/raim0001/Documents/datasets/sf2_2010"
dest_path = sprintf("%s/%s", getwd(), "data")

# The following files come from SF2_MSAccess_2007.accdb, which is
# provided along with the dataset. I can't directly read Access DBs from
# R (I think I'm missing an ODBC driver), so I opened it in Access, and
# exported each table to a CSV. Then I read the CSVs here and save them
# to R datasets.

ff = sprintf("%s/%s", src_path, "GeoHeader_Specifications.csv")
col_types = cols(ID = col_integer(), `FIELD SIZE` = col_integer(), `STARTING POSITION` = col_integer())
sf2_2010_geo_cols = read_csv(ff, col_types = col_types)
dest_file = sprintf("%s/%s.rda", dest_path, "sf2_2010_geo_cols")
save(sf2_2010_geo_cols, file = dest_file)

ff = sprintf("%s/%s", src_path, "Iterations_list.csv")
sf2_2010_iterations = read_csv(ff, col_types = cols(`SORT ID` = col_integer())) %>%
	filter(!is.na(`Iteration Code`))
dest_file = sprintf("%s/%s.rda", dest_path, "sf2_2010_iterations")
save(sf2_2010_iterations, file = dest_file)

ff = sprintf("%s/%s", src_path, "SF2_GeoHeader.csv")
sf2_2010_geoheader = read_csv(ff)
dest_file = sprintf("%s/%s.rda", dest_path, "sf2_2010_geoheader")
save(sf2_2010_geoheader, file = dest_file)

ff = sprintf("%s/%s", src_path, "DataDictionary_NOTES.csv")
sf2_2010_geoheader_dd_notes = read_csv(ff)
dest_file = sprintf("%s/%s.rda", dest_path, "sf2_2010_geoheader_dd_notes")
save(sf2_2010_geoheader_dd_notes, file = dest_file)

ff = sprintf("%s/%s", src_path, "DataDictionary.csv")
col_types = cols(SEGMENT = col_integer(), SORT_ID = col_integer())
sf2_2010_geoheader_dd = read_csv(ff, col_types = col_types, trim_ws = FALSE)
dest_file = sprintf("%s/%s.rda", dest_path, "sf2_2010_geoheader_dd")
save(sf2_2010_geoheader_dd, file = dest_file)

for (i in 1:11) {
	ff = sprintf("%s/SF2_Segment_%02d.csv", src_path, i)
	dat = read_csv(ff)
	dat_name = sprintf("sf2_2010_segment%02d", i)
	assign(dat_name, dat)
	dest_file = sprintf("%s/%s.rda", dest_path, dat_name)
	save(list = dat_name, file = dest_file)
}

# Create a list of available tables, along with their segments
table_segments = sf2_2010_geoheader_dd %>%
	filter(str_detect(`FIELD NAME`, "^Total")) %>%
	arrange(SORT_ID) %>%
	select(SEGMENT, NUMBER = TABLE)
table_descriptions = sf2_2010_geoheader_dd %>%
	filter(is.na(`FIELD CODE`)) %>%
	filter(!str_detect(`FIELD NAME`, "^Universe:")) %>%
	filter(str_detect(`FIELD NAME`, "\\[")) %>%
	filter(str_detect(`FIELD NAME`, "\\]")) %>%
	arrange(SORT_ID) %>%
	select(NUMBER = TABLE, DESCRIPTION = `FIELD NAME`)
sf2_2010_tables = table_segments %>%
	inner_join(table_descriptions, by = c('NUMBER' = 'NUMBER'))
dest_file = sprintf("%s/%s.rda", dest_path, "sf2_2010_tables")
save(sf2_2010_tables, file = dest_file)
