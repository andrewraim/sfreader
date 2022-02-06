library(sfreader)
library(stringr)

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

basedir = "/path/to/sf2/District_of_Columbia"

geo_path = sprintf("%s/dcgeo2010.sf2", basedir)
geo_dat = read_geo(geo_path)

data_paths = list.files(basedir, pattern = "dc.*.sf2", full.names = TRUE)
dat_files = interpret_data_filenames(data_paths)

sf2_2010_geo_cols
sf2_2010_iterations
sf2_2010_segments
sf2_2010_tables

# TBD: I think we're not supposed to join to CHARITER in the geo table; that
# always seems to be set to 100.

target_file = dat_files %>% filter(ITERATION_CODE == '002' & SEGMENT == '02')
col_defs = sf2_2010_segments %>% filter(SEGMENT == '02')
dat = read_csv(target_file$PATH, col_names = col_defs$FIELD)
dat_joined = geo_dat %>% select(FILEID, STUSAB, SUMLEV, GEOCOMP, CIFSN, LOGRECNO,
	REGION, DIVISION, STATE, COUNTY, COUNTYCC, COUNTYSC, COUSUB, COUSUBCC,
	COUSUBSC, PLACE, PLACECC, PLACESC, TRACT,  BLKGRP, BLOCK) %>%
	inner_join(dat, c("STUSAB" = "STUSAB", "LOGRECNO" = "LOGRECNO")) %>%
	inner_join(sf2_2010_iterations, c("CHARITER" = "CODE"))
View(dat_joined)

# Let's try to get all the county-level data for table PCT002
target_files = dat_files %>% filter(SEGMENT == '02')
col_defs = sf2_2010_segments %>% filter(SEGMENT == '02')

dat_joined = tibble()
for (i in 1:nrow(target_files)) {
	cat("Reading file", i, "of", nrow(target_files), "\n")
	dat = read_csv(target_files$PATH[i], col_names = col_defs$FIELD, col_types = 'cccccdddddd')
	dat_joined_part = geo_dat %>% select(-CHARITER) %>%
		inner_join(dat, c("STUSAB" = "STUSAB", "LOGRECNO" = "LOGRECNO")) %>%
		inner_join(sf2_2010_iterations, c("CHARITER" = "CODE")) %>%
		filter(SUMLEV == '050')
	dat_joined = rbind(dat_joined, dat_joined_part)
}
dat_result = dat_joined %>% select(STATE, COUNTY, CHARITER, PCT0020001, PCT0020002,
	PCT0020003, PCT0020004, PCT0020005, PCT0020006, DESCRIPTION)
View(dat_result)

