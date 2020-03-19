library(readr)
library(dplyr)
library(stringr)

src_path = "C:/Users/raim0001/Documents/datasets/aian_2010"
dest_path = sprintf("%s/%s", getwd(), "data")

# The following files come from 2010_AIANSF_MSAccessShell.zip, which is
# provided along with the dataset. I can't directly read Access DBs from
# R (I think I'm missing an ODBC driver), so I opened it in Access, and
# exported each table to a CSV. Then I read the CSVs here and save them
# to R datasets.

ff = sprintf("%s/%s", src_path, "ITERATIONS.csv")
aiansf_2010_iterations = read_csv(ff, col_types = cols(SORTID = col_integer()))
dest_file = sprintf("%s/%s.rda", dest_path, "aiansf_2010_iterations")
save(aiansf_2010_iterations, file = dest_file)

ff = sprintf("%s/%s", src_path, "AIAN_GeoHeader.csv")
aiansf_2010_geoheader = read_csv(ff)
dest_file = sprintf("%s/%s.rda", dest_path, "aiansf_2010_geoheader")
save(aiansf_2010_geoheader, file = dest_file)

ff = sprintf("%s/%s", src_path, "DataDictionary_NOTES.csv")
aiansf_2010_geoheader_dd_notes = read_csv(ff)
dest_file = sprintf("%s/%s.rda", dest_path, "aiansf_2010_geoheader_dd_notes")
save(aiansf_2010_geoheader_dd_notes, file = dest_file)

ff = sprintf("%s/%s", src_path, "DATA_DICTIONARY.csv")
aiansf_2010_geoheader_dd = read_csv(ff, col_types = cols(DECIMAL = col_integer()), trim_ws = FALSE)
dest_file = sprintf("%s/%s.rda", dest_path, "aiansf_2010_geoheader_dd")
save(aiansf_2010_geoheader_dd, file = dest_file)

ff = sprintf("%s/%s", src_path, "GeoHeader_Specifications.csv")
aiansf_2010_geo_cols = read_csv(ff,
	col_types = cols(`FIELD SIZE` = col_integer(), `STARTING POSITION` = col_integer()))
dest_file = sprintf("%s/%s.rda", dest_path, "aiansf_2010_geo_cols")
save(aiansf_2010_geo_cols, file = dest_file)

for (i in 1:11) {
	ff = sprintf("%s/AIANSF_Segment_%02d.csv", src_path, i)
	dat = read_csv(ff)
	dat_name = sprintf("aiansf_2010_segment%02d", i)
	assign(dat_name, dat)
	dest_file = sprintf("%s/%s.rda", dest_path, dat_name)
	save(list = dat_name, file = dest_file)
}

# Create a list of available tables, along with their segments
aiansf_2010_tables = aiansf_2010_geoheader_dd %>%
	filter(is.na(`FIELD CODE`)) %>%
	filter(!str_detect(`FIELD NAME`, "^Universe:")) %>%
	filter(str_detect(`FIELD NAME`, "\\[")) %>%
	filter(str_detect(`FIELD NAME`, "\\]")) %>%
	arrange(SORTID) %>%
	select(SEGMENT = `DATA SEGMENT`, NUMBER = `TABLE NUMBER`, DESCRIPTION = `FIELD NAME`)

dest_file = sprintf("%s/%s.rda", dest_path, "aiansf_2010_tables")
save(aiansf_2010_tables, file = dest_file)
