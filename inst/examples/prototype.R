# Census 2010 SF2 Example
# Data source: https://www.census.gov/data/datasets/2010/dec/summary-file-2.html

library(sfreader)
library(stringr)
library(readr)
library(tibble)
library(dplyr)

read_geo = function(path) {
	# Read in the fixed width geoheader
	geo_dat = read_fwf(file = geo_path,
		col_positions = fwf_widths(sf2_2010_geo_cols[['FIELD_SIZE']]),
		col_types = paste0(sf2_2010_geo_cols[['DATA_TYPE']], collapse = ""))

	# Assign column headers based on access specifications
	colnames(geo_dat) = sf2_2010_geo_cols[['FIELD']]
	return(geo_dat)
}

interpret_data_filenames = function(paths) {
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
}

# Assume files are in the following locations
basedir = "/path/to/sf2/District_of_Columbia"
geo_path = sprintf("%s/dcgeo2010.sf2", basedir)
data_paths = list.files(basedir, pattern = "dc.*.sf2", full.names = TRUE)

# Interpret the Geo file. This only needs to be done once for this set of files.
geo_dat = read_geo(geo_path)

sf2_2010_geo_cols
sf2_2010_iterations
sf2_2010_segments
sf2_2010_tables

# ----- Example 1 -----

# Identify segments for table PCT002
segments = sf2_2010_segments %>%
	filter(TABLE == 'PCT002') %>%
	pull(SEGMENT)

# Identify CHARITER of interest. Let's select AIAN alone, without any
# modifiers. Note that we need to escape parantheses with backslashes here.
chariters = sf2_2010_iterations %>%
	filter(str_detect(DESCRIPTION, "American Indian and Alaska Native alone \\(300, A01-Z99\\)")) %>%
	pull(CODE)

# The names of the data files indicate their contents. The following functions
# extracts the information from the names for easier processing.
dat_files = interpret_data_filenames(data_paths)

# Find the files with our target chariters and segments. (There should only
# be one file in this example).
target_file = dat_files %>%
	filter(ITERATION_CODE %in% chariters & SEGMENT %in% segments) %>%
	pull(PATH)

# The data files do not have headers, so let's get the column definitions from
# the sfreader package.
col_defs = sf2_2010_segments %>%
	filter(SEGMENT %in% segments)

# Load the data file and apply the header.
dat = read_csv(target_file, col_names = col_defs$FIELD)

# Join the data file to the geo file for information about the geography of
# the records. On the last line, "everything" is a placeholder in tidyselect
# for the columns not named earlier in the statement.
#
# I think we are not supposed to join to CHARITER in the geo table; that
# always seems to be set to 100.

dat_joined = geo_dat %>%
	select(-CHARITER) %>%
	inner_join(dat, c("FILEID" = "FILEID", "STUSAB" = "STUSAB", "LOGRECNO" = "LOGRECNO")) %>%
	inner_join(sf2_2010_iterations, c("CHARITER" = "CODE")) %>%
	select(LOGRECNO, PCT0020001, PCT0020002, PCT0020003, PCT0020004, PCT0020005, PCT0020006, everything())

# View the result
View(dat_joined)

# ----- Example 2 -----
# Let's try to get all the county-level data for table PCT002 in our files.

# Identify segments for table PCT002
segments = sf2_2010_segments %>%
	filter(TABLE == 'PCT002') %>%
	pull(SEGMENT)

# Find the files with our target chariters and segments.
target_files = dat_files %>%
	filter(SEGMENT %in% segments)

# The data files do not have headers, so let's get the column definitions from
# the sfreader package.
col_defs = sf2_2010_segments %>%
	filter(SEGMENT %in% segments)

# Build up a big table from the individual table files.
dat_joined = tibble()
for (i in 1:nrow(target_files)) {
	cat("Reading file", i, "of", nrow(target_files), "\n")

	# Read the next file. Set col_types argument to specify data types.
	dat = read_csv(target_files$PATH[i],
		col_names = col_defs$FIELD,
		col_types = 'cccccdddddd')

	# Join data to geo file and CHARITER definition. Filter to SUMLEV 50, which
	# represents county level data.
	dat_joined_part = geo_dat %>%
		select(-CHARITER) %>%
		inner_join(dat, c("FILEID" = "FILEID", "STUSAB" = "STUSAB", "LOGRECNO" = "LOGRECNO")) %>%
		inner_join(sf2_2010_iterations, c("CHARITER" = "CODE")) %>%
		filter(SUMLEV == '050')

	# Using rbind to append new data to running result. This is not
	# the most efficient to compose large tables, but it's okay for this
	# demonstration.
	dat_joined = rbind(dat_joined, dat_joined_part)
}

# Select only the columns of interest to get the final result.
dat_result = dat_joined %>%
	select(PCT0020001, PCT0020002, PCT0020003, PCT0020004, PCT0020005,
		PCT0020006, STATE, COUNTY, CHARITER, DESCRIPTION)

# View the result.
View(dat_result)

