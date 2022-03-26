library(readr)
library(dplyr)
library(stringr)
library(tibble)
library(usethis)

# Geo file
# The geo file specifies geography information; it is joined to the record data.
# This specifies the fixed width format of the data in the geo file.
sf2_2010_geo_format = read_csv("data-raw/sf2_2010_geo_format.csv", col_types = "iciicc")

# Characteristic iterations
sf2_2010_iterations = read_csv("data-raw/sf2_2010_iterations.csv", col_types = "cc")

# Segment definitions, including logical tables and variable descriptions
sf2_2010_fields = read_csv("data-raw/sf2_2010_fields.csv", col_types = "cicccc")

# Table definitions
sf2_2010_tables = read_csv("data-raw/sf2_2010_tables.csv", col_types = "cc")

# Data composition definitions
sf2_2010_geocomp = read_csv("data-raw/sf2_2010_geocomp.csv", col_types = "cc")

# State information
sf2_2010_states = read_csv("data-raw/sf2_2010_states.csv", col_types = "cc")

# Summary levels
sf2_2010_sumlev_state = read_csv("data-raw/sf2_2010_sumlev_state.csv", col_types = "ccc")
sf2_2010_sumlev_state_gq = read_csv("data-raw/sf2_2010_sumlev_state_gq.csv", col_types = "ccc")
sf2_2010_sumlev_national = read_csv("data-raw/sf2_2010_sumlev_national.csv", col_types = "ccc")
sf2_2010_sumlev_national_gq = read_csv("data-raw/sf2_2010_sumlev_national_gq.csv", col_types = "ccc")

# Save data for use in the package
use_data(sf2_2010_geo_format, internal = FALSE, overwrite = TRUE)
use_data(sf2_2010_iterations, internal = FALSE, overwrite = TRUE)
use_data(sf2_2010_fields, internal = FALSE, overwrite = TRUE)
use_data(sf2_2010_tables, internal = FALSE, overwrite = TRUE)
use_data(sf2_2010_geocomp, internal = FALSE, overwrite = TRUE)
use_data(sf2_2010_states, internal = FALSE, overwrite = TRUE)
use_data(sf2_2010_sumlev_state, internal = FALSE, overwrite = TRUE)
use_data(sf2_2010_sumlev_state_gq, internal = FALSE, overwrite = TRUE)
use_data(sf2_2010_sumlev_national, internal = FALSE, overwrite = TRUE)
use_data(sf2_2010_sumlev_national_gq, internal = FALSE, overwrite = TRUE)

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
