library(readr)
library(dplyr)
library(stringr)
library(tibble)
library(usethis)

# Geo file
# The geo file specifies geography information; it is joined to the record data.
# This specifies the fixed width format of the data in the geo file.
sf2_2010_geo_cols = read_csv("data-raw/sf2_2010_geo_cols.csv", col_types = "iciicc")

# Characteristic iterations
sf2_2010_iterations = read_csv("data-raw/sf2_2010_iterations.csv", col_types = "cc")

# Segments
# These partition of table variables into 11 types of files. Note that the
# "logical" table name (e.g. "PCT001") is a prefix in the variable name.
# Variable names in the vectors above are assumed to be in order of the columns
# in each associated file.
segment01_fields = read_csv("data-raw/sf2_2010_segment01.csv", col_types = "c", col_names = FALSE) %>% pull()
segment02_fields = read_csv("data-raw/sf2_2010_segment02.csv", col_types = "c", col_names = FALSE) %>% pull()
segment03_fields = read_csv("data-raw/sf2_2010_segment03.csv", col_types = "c", col_names = FALSE) %>% pull()
segment04_fields = read_csv("data-raw/sf2_2010_segment04.csv", col_types = "c", col_names = FALSE) %>% pull()
segment05_fields = read_csv("data-raw/sf2_2010_segment05.csv", col_types = "c", col_names = FALSE) %>% pull()
segment06_fields = read_csv("data-raw/sf2_2010_segment06.csv", col_types = "c", col_names = FALSE) %>% pull()
segment07_fields = read_csv("data-raw/sf2_2010_segment07.csv", col_types = "c", col_names = FALSE) %>% pull()
segment08_fields = read_csv("data-raw/sf2_2010_segment08.csv", col_types = "c", col_names = FALSE) %>% pull()
segment09_fields = read_csv("data-raw/sf2_2010_segment09.csv", col_types = "c", col_names = FALSE) %>% pull()
segment10_fields = read_csv("data-raw/sf2_2010_segment10.csv", col_types = "c", col_names = FALSE) %>% pull()
segment11_fields = read_csv("data-raw/sf2_2010_segment11.csv", col_types = "c", col_names = FALSE) %>% pull()

sf2_2010_segments = rbind(
	tibble(FIELD = segment01_fields) %>% mutate(SEGMENT = "01", POSITION = row_number()),
	tibble(FIELD = segment02_fields) %>% mutate(SEGMENT = "02", POSITION = row_number()),
	tibble(FIELD = segment03_fields) %>% mutate(SEGMENT = "03", POSITION = row_number()),
	tibble(FIELD = segment04_fields) %>% mutate(SEGMENT = "04", POSITION = row_number()),
	tibble(FIELD = segment05_fields) %>% mutate(SEGMENT = "05", POSITION = row_number()),
	tibble(FIELD = segment06_fields) %>% mutate(SEGMENT = "06", POSITION = row_number()),
	tibble(FIELD = segment07_fields) %>% mutate(SEGMENT = "07", POSITION = row_number()),
	tibble(FIELD = segment08_fields) %>% mutate(SEGMENT = "08", POSITION = row_number()),
	tibble(FIELD = segment09_fields) %>% mutate(SEGMENT = "09", POSITION = row_number()),
	tibble(FIELD = segment10_fields) %>% mutate(SEGMENT = "10", POSITION = row_number()),
	tibble(FIELD = segment11_fields) %>% mutate(SEGMENT = "11", POSITION = row_number())
) %>% select(SEGMENT, POSITION, FIELD) %>%
	mutate(TABLE = case_when(
		startsWith(FIELD, "PCT") ~ substring(FIELD, 1, 6),
		startsWith(FIELD, "PCO") ~ substring(FIELD, 1, 6),
		startsWith(FIELD, "HCT") ~ substring(FIELD, 1, 6),
		TRUE ~ "HEAD"))

# Table definitions
sf2_2010_tables = read_csv("data-raw/sf2_2010_tables.csv", col_types = "cc")

# Save data for use in the package
use_data(sf2_2010_geo_cols, internal = TRUE, overwrite = TRUE)
use_data(sf2_2010_iterations, internal = TRUE, overwrite = TRUE)
use_data(sf2_2010_segments, internal = TRUE, overwrite = TRUE)
use_data(sf2_2010_tables, internal = TRUE, overwrite = TRUE)

# TBD: Do we still need the following information from the Access database?
# There is some additional information in here; e.g., descriptive table names,
# but those are given in a hierarchical-style format which may not be easy to
# work with.
if (FALSE) {
	ff = sprintf("%s/%s", src_path, "DataDictionary.csv")
	col_types = cols(SEGMENT = col_integer(), SORT_ID = col_integer())
	sf2_2010_geoheader_dd = read_csv(ff, col_types = col_types, trim_ws = FALSE)
	dest_file = sprintf("%s/%s.rda", dest_path, "sf2_2010_geoheader_dd")
	save(sf2_2010_geoheader_dd, file = dest_file)

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
}
