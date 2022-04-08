# Census 2010 SF2 Example
# Data source: https://www.census.gov/data/datasets/2010/dec/summary-file-2.html

library(sfreader)
library(stringr)
library(readr)
library(tibble)
library(dplyr)

# Assume files for a state of interest are in the folder "basedir".
#
# The geo filename will have format:
# 1. Two letters abbreviating the state
# 2. The string "geo"
# 3. Four digits indicating the year
# 4. An extension indicating the type of summary file
#
# Data filenames will have format:
# 1. Two letters abbreviating the state
# 2. Five numbers indicating characteristic iteration and segment
# 3. Four digits indicating the year
# 4. An extension indicating the type of summary file
basedir = "~/data/pr2010.sf2/"
geo_path = list.files(basedir, pattern = '(\\w){2}geo(\\d){4}.sf2', full.names = TRUE)
data_paths = list.files(basedir, pattern = '(\\w){2}(\\d){5}(\\d){4}.sf2', full.names = TRUE)

# Create a "summary file" object
sf = SF2_2010()

# Interpret the Geo file. This only needs to be done once for this set of files.
geo_dat = read_geo(sf, geo_path)

# Here are helper tables we need to interpret the data. Should they be accessed
# through methods like "get_geo_cols(sf)", or is that overkill with the object
# orientation? Also, will all (or most) summary files have similar helper
# tables?
print(sf2_2010_geo_format, n = 10)
print(sf2_2010_iterations, n = 10)
print(sf2_2010_fields, n = 10)
print(sf2_2010_tables, n = 10)

unique(sf2_2010_fields$NAME)

# ----- Example 1 -----
# Let's try to read data for table PCT002 from one file.

# Identify segments for table PCT002
segments = sf2_2010_fields %>%
	filter(TABLE == 'PCT002') %>%
	pull(SEGMENT)

# Identify CHARITER of interest. Let's select AIAN alone, without any
# modifiers. Note that fixed() makes str_detect treat the pattern argument as
# a fixed string instead of a regex.
chariters = sf2_2010_iterations %>%
	filter(str_detect(DESCRIPTION, fixed("American Indian and Alaska Native alone (300, A01-Z99)"))) %>%
	pull(CODE)

# The names of the data files indicate their contents. The following functions
# extracts the information from the names for easier processing.
dat_files = interpret_data_filenames(sf, data_paths)

# Find the files with our target chariters and segments. (There should only
# be one file in this example).
target_file = dat_files %>%
	filter(ITERATION_CODE %in% chariters & SEGMENT %in% segments) %>%
	pull(PATH)

# The data files do not have headers, so let's get the column definitions from
# the sfreader package.
col_defs = sf2_2010_fields %>%
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

#### Puerto Rico Only
# subminor civil division (SUBMCD)
submcd <- dat_joined %>%
	filter(!is.na(SUBMCD)) %>%
	View()

dat_joined$SUBMCD



# ----- Example 2 -----
# Let's try to get all the county-level data for table PCT002 in our files.

# Identify segments for table PCT002
segments = sf2_2010_fields %>%
	filter(TABLE == 'PCT002') %>%
	pull(SEGMENT)

# Find the files with our target chariters and segments.
target_files = dat_files %>%
	filter(SEGMENT %in% segments)

# The data files do not have headers, so let's get the column definitions from
# the sfreader package.
col_defs = sf2_2010_fields %>%
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

# ----- Example 3 -----
# Total number of males
# Iteration 001
# Table PCT003
# County level

# Identify segments for table PCT002
segments = sf2_2010_fields %>%
	filter(TABLE == 'PCT003') %>%
	pull(SEGMENT)

# Identify CHARITER of interest. Let's select AIAN alone, without any
# modifiers. Note that fixed() makes str_detect treat the pattern argument as
# a fixed string instead of a regex.
chariters = sf2_2010_iterations %>%
	filter(str_detect(DESCRIPTION, fixed("Total"))) %>%
	pull(CODE)

# The names of the data files indicate their contents. The following functions
# extracts the information from the names for easier processing.
dat_files = interpret_data_filenames(sf, data_paths)

# Find the files with our target chariters and segments. (There should only
# be one file in this example).
target_file = dat_files %>%
	filter(ITERATION_CODE %in% chariters & SEGMENT %in% segments) %>%
	pull(PATH)

# The data files do not have headers, so let's get the column definitions from
# the sfreader package.
col_defs = sf2_2010_fields %>%
	filter(SEGMENT %in% segments)

# Load the data file and apply the header.
dat = read_csv(target_file, col_names = col_defs$FIELD) %>%
	select(FILEID, STUSAB, CHARITER, CIFSN, LOGRECNO, PCT0030002)

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
	select(LOGRECNO, PCT0030002, everything())

# View the result
View(dat_joined)

# ----- Example 4 -----
# Get URLs of the data files for DC and download/unzip in R
library(curl)

dat_url = get_data_urls(sf) %>%
	filter(ABBREV == "DC") %>%
	pull(URL)

dest_dir = "my_sf2_files"
dir.create(dest_dir)

local_zip_file = basename(dat_url)
curl_download(url = dat_url, destfile = local_zip_file)

unzip(local_zip_file, exdir = dest_dir)


# ---- Example 5 ----
# White and black renters over 18 in NY by lowest level of geography available
# Renter = segment
# white and black = iteration

basedir = "~/data/ny2010.sf2/"
geo_path = list.files(basedir, pattern = '(\\w){2}geo(\\d){4}.sf2', full.names = TRUE)
data_paths = list.files(basedir, pattern = '(\\w){2}(\\d){5}(\\d){4}.sf2', full.names = TRUE)

# Create a "summary file" object
sf = SF2_2010()

# The names of the data files indicate their contents. The following functions
# extracts the information from the names for easier processing.
dat_files = interpret_data_filenames(sf, data_paths)

# Interpret the Geo file. This only needs to be done once for this set of files.
geo_dat = read_geo(sf, geo_path)

### Step 1: find the table number. We do this by looking at segments df.

# Find segments that relate to renters
idx <-
grep(pattern = "\\brent",
	 x = sf2_2010_fields$DESCRIPTION,
	 ignore.case = TRUE,
	 value = FALSE)

sf2_2010_fields %>%
	filter(row_number() %in% idx) %>%
	View()
# Looks like 18+ is not available. Only 15-24, 25-34, 35-44, ..., 85+
# Maybe those ages are only for the householder? Like head of household?
# Let's just use: "Total: Renter-occupied"


# Filter by "Total: Renter-occupied" and nothing after it ($)
sf2_2010_fields %>%
	filter(grepl("Total: Renter-occupied$", DESCRIPTION))
# What is difference between these 3 tables?


sf2_2010_tables %>%
	filter(NUMBER %in% c("HCT010")) %>%
	View()

sf2_2010_fields %>%
	filter(TABLE == "HCT010") %>%
	View()

# I have Identified segments in table HCT010.
# Set segments variable to filter data_files by
segments = sf2_2010_fields %>%
	filter(TABLE == 'HCT010') %>%
	pull(SEGMENT)


# What is lowest level of geo available?
geo_dat %>%
	select(COUNTY, TRACT, BLKGRP, BLOCK) %>%
	summarise_all(n_distinct)

table(geo_dat$SUMLEV)
# Looks like TRACT is lowest
# I'm not sure where this actually gets used...
# Maybe the data will exist at all levels of geography in the target files
#	that are specified by segments and chariters?


### Step 2: Identify CHARITER of interest.
grep(pattern = "black",
	 x = sf2_2010_iterations$DESCRIPTION,
	 ignore.case = TRUE,
	 value = TRUE)

# Set chariters variable to filter data_files by
chariters = sf2_2010_iterations %>%
		filter(grepl("Black or African American alone$", DESCRIPTION)) %>%
		pull(CODE)

# Find the files with our target chariters and segments. (There should only
# be one file in this example).
target_file = dat_files %>%
	filter(ITERATION_CODE %in% chariters & SEGMENT %in% segments) %>%
	pull(PATH)

# The data files do not have headers, so let's get the column definitions from
# the sfreader package.
col_defs = sf2_2010_fields %>%
	filter(SEGMENT %in% segments)

# Load the data file and apply the header.
# the data file you read in will come with extra columns (maybe)
#	can filter based on: sf2_2010_fields %>%
#                                filter(TABLE == "HCT010") %>%
#	                             View()
dat = read_csv(target_file, col_names = col_defs$FIELD) %>%
	select(1:5, HCT0100008)

View(dat)

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
	select(LOGRECNO, HCT0100008, everything())

# View the result
View(dat_joined)

dat_joined[13:17, ] %>% View()

dat_joined %>%
	filter(SUMLEV == 140)







