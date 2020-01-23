# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

#' @export
Accumulator = R6Class("Accumulator", list(
  sum = 0,
  add = function(x = 1) {
    self$sum <- self$sum + x
    invisible(self)
  })
)

#' @export
aiansf2010_reader = R6Class("aiansf2010_reader",
	private = list(
    	path_to_files = NULL,
		col_defns = NULL,
		usgeo = NULL
	),
	public = list(
		initialize = function(path_to_files) {
			logger("Begin initializing reader\n")

			private$path_to_files = path_to_files

			# Build a data structure with geo information. This serves as
			# an index into all the other data files.
			geo_file = sprintf("%s/usgeo2010.an2", path_to_files)

			# Need the first 11 characters of each record to determine the type
			# (i.e. summary level) of each record.
			lines = readLines(geo_file)
			sl = substr(lines, 9, 11)

			summary_levels = names(aiansf2010_geo_cols)

			private$usgeo = list()
			for (idx_level in 1:length(summary_levels)) {
				summary_level = summary_levels[idx_level]
				logger("Processing summary_level %s\n", summary_level)

				cols = aiansf2010_geo_cols[[summary_level]]

				# We will interpret all columns as strings.
				ncols = nrow(cols)
				col_types = paste(rep("c", ncols), collapse = "")

				idx = which(sl == summary_level)
				private$usgeo[[idx_level]] = read_fwf(lines[idx],
					col_positions = cols, col_types = col_types)
			}

			names(private$usgeo) = summary_levels
			logger("Finished initializing reader\n")
		},
		getTableNames = function() {
			return(aiansf2010_tables)
		},
		getSummaryLevels = function() {
			return(aiansf2010_geo_cols)
		},
		getTable = function(table_name, sumlev) {
			stopifnot(sumlev %in% names(aiansf2010_geo_cols))

			target_segment = aiansf2010_tables %>%
				filter(name == table_name) %>%
				select(segment) %>%
				as.integer()
			if (is.na(target_segment)) {
				stop("Could not locate specified table")
			}

			# Be careful, we depend on the ordering here... it might
			# be better to code the ordering into aiansf2010_tables
			table_cols = aiansf2010_tables %>%
				filter(segment == target_segment) %>%
				mutate(ncols_cumul = as.integer(cumsum(ncols))) %>%
				filter(name == table_name)

			# Shift by five because there are five indexing columns in each file
			idx_start = table_cols$ncols_cumul - table_cols$ncols + 1 + 5
			idx_end = table_cols$ncols_cumul + 5
			idx_cols = seq(idx_start, idx_end)

			target_chariter = unique(private$usgeo[[sumlev]]$CHARITER)
			target_geo = private$usgeo[[sumlev]] %>%
				select(-FILEID, -STUSAB, -SUMLEV, -GEOCOMP, -CHARITER, -CIFSN)

			dat_files = list.files(
				path = private$path_to_files,
				pattern = sprintf("us%s%02d", target_chariter, target_segment),
				full.names = TRUE)

			dat = read_csv(dat_files[1], col_names = FALSE)
			for (j in setdiff(seq_along(dat_files), 1)) {
				dat = rbind(dat, read_csv(dat_files[j], col_names = FALSE))
			}

			dat_select = dat %>%
				rename(FILEID = 1, STUSAB = 2, CHARITER = 3, CIFSN = 4, LOGRECNO = 5) %>%
				select(LOGRECNO, idx_cols)

			# Try to make data column names match the ones from the documentation
			colnames(dat_select)[-1] = sprintf("PCT%03d%04d",
				parse_number(table_name),
				seq_len(table_cols$ncols))

			result = target_geo %>%
				inner_join(dat_select, by = c("LOGRECNO" = "LOGRECNO"))
			return(result)
		}
	)
)

# There are 76 total levels; I'm just specifying the levels that seem
# most important right now. I'm also ignoring fields further to the
# right that aren't crucial to navigating the main tables.
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

# We need some information to locate data tables. The following
# is from page 53 of the AIAN spec document. Also see Figure 2-2.
aiansf2010_tables = tribble(
	~name, ~description, ~ncols, ~segment,
	"PCT1", "TOTAL POPULATION", 1, 1L,
	"PCT2", "URBAN AND RURAL", 6, 2L,
	"PCT3", "SEX BY AGE", 209, 3L,
	"PCT4", "MEDIAN AGE BY SEX", 3, 3L,
	"PCT5", "SEX BY AGE FOR THE POPULATION IN HOUSEHOLDS", 49, 4L,
	"PCT6", "POPULATION IN HOUSEHOLDS BY AGE (ITERATED BY AMERICAN INDIAN OR ALASKA NATIVE TRIBE OR TRIBAL GROUPING OF THE HOUSEHOLDER)", 3, 4L,
	"PCT7", "AVERAGE HOUSEHOLD SIZE BY AGE", 3, 4L,
	"PCT8", "HOUSEHOLD TYPE", 9, 4L,
	"PCT9", "HOUSEHOLD SIZE BY HOUSEHOLD TYPE BY PRESENCE OF OWN CHILDREN", 19, 4L,
	"PCT10", "HOUSEHOLDS BY PRESENCE OF PEOPLE UNDER 18 YEARS BY HOUSEHOLD TYPE BY AGE OF PEOPLE UNDER 18 YEARS", 34, 4L,
	"PCT11", "HOUSEHOLDS BY AGE OF HOUSEHOLDER BY HOUSEHOLD TYPE BY PRESENCE OF RELATED CHILDREN", 31, 4L,
	"PCT12", "HOUSEHOLD TYPE BY AGE OF HOUSEHOLDER", 21, 4L,
	"PCT13", "HOUSEHOLDS BY PRESENCE OF PEOPLE 60 YEARS AND OVER BY HOUSEHOLD TYPE", 15, 4L,
	"PCT14", "HOUSEHOLDS BY PRESENCE OF PEOPLE 60 YEARS AND OVER, HOUSEHOLD SIZE, AND HOUSEHOLD TYPE", 11, 4L,
	"PCT15", "HOUSEHOLDS BY PRESENCE OF PEOPLE 65 YEARS AND OVER, HOUSEHOLD SIZE, AND HOUSEHOLD TYPE", 11, 4L,
	"PCT16", "HOUSEHOLDS BY PRESENCE OF PEOPLE 75 YEARS AND OVER, HOUSEHOLD SIZE, AND HOUSEHOLD TYPE", 11, 4L,
	"PCT17", "PRESENCE OF MULTIGENERATIONAL HOUSEHOLDS", 3, 4L,
	"PCT18", "HOUSEHOLDS BY PRESENCE OF NONRELATIVES", 3, 4L,
	"PCT19", "HUSBAND-WIFE AND UNMARRIED-PARTNER HOUSEHOLDS BY SEX OF PARTNER BY PRESENCE OF RELATED AND OWN CHILDREN UNDER 18 YEARS", 34, 5L,
	"PCT20", "HOUSEHOLD TYPE BY HOUSEHOLD SIZE", 16, 5L,
	"PCT21", "HOUSEHOLD TYPE BY NUMBER OF PEOPLE UNDER 18 YEARS (EXCLUDING HOUSEHOLDERS, SPOUSES, AND UNMARRIED PARTNERS)", 26, 5L,
	"PCT22", "HOUSEHOLD TYPE BY RELATIONSHIP", 28, 5L,
	"PCT23", "HOUSEHOLD TYPE FOR THE POPULATION IN HOUSEHOLDS", 13, 5L,
	"PCT24", "HOUSEHOLD TYPE BY RELATIONSHIP FOR THE POPULATION UNDER 18 YEARS", 16, 5L,
	"PCT25", "HOUSEHOLD TYPE BY RELATIONSHIP BY AGE FOR THE POPULATION UNDER 18 YEARS", 45, 5L,
	"PCT26", "HOUSEHOLD TYPE FOR THE POPULATION UNDER 18 YEARS IN HOUSEHOLDS (EXCLUDING HOUSEHOLDERS, SPOUSES, AND UNMARRIED PARTNERS)", 7, 5L,
	"PCT27", "PRESENCE OF UNMARRIED PARTNER OF HOUSEHOLDER BY HOUSEHOLD TYPE FOR THE POPULATION UNDER 18 YEARS IN HOUSEHOLDS (EXCLUDING HOUSEHOLDERS, SPOUSES, AND UNMARRIED PARTNERS)", 18, 5L,
	"PCT28", "HOUSEHOLD TYPE BY RELATIONSHIP FOR THE POPULATION 65 YEARS AND OVER", 23, 5L,
	"PCT29", "FAMILIES", 1, 5L,
	"PCT30", "POPULATION IN FAMILIES BY AGE (ITERATED BY AMERICAN INDIAN OR ALASKA NATIVE TRIBE OR TRIBAL GROUPING OF THE HOUSEHOLDER)", 3, 5L,
	"PCT31", "AVERAGE FAMILY SIZE BY AGE", 3, 5L,
	"PCT32", "FAMILY TYPE BY PRESENCE AND AGE OF OWN CHILDREN", 20, 6L,
	"PCT33", "FAMILY TYPE BY PRESENCE AND AGE OF RELATED CHILDREN", 20, 6L,
	"PCT34", "FAMILY TYPE AND AGE FOR OWN CHILDREN UNDER 18 YEARS", 20, 6L,
	"PCT35", "AGE OF GRANDCHILDREN UNDER 18 YEARS LIVING WITH A GRANDPARENT HOUSEHOLDER", 6, 6L,
	"PCT36", "NONFAMILY HOUSEHOLDS BY SEX OF HOUSEHOLDER BY LIVING ALONE BY AGE OF HOUSEHOLDER", 15, 6L,
	"PCT37", "NONRELATIVES BY HOUSEHOLD TYPE", 11, 6L,
	"PCT38", "GROUP QUARTERS POPULATION BY GROUP QUARTERS TYPE", 32, 6L,
	"PCT39", "GROUP QUARTERS POPULATION BY SEX BY AGE BY GROUP QUARTERS TYPE", 195, 7L,
	"PCT40", "POPULATION SUBSTITUTED", 3, 7L,
	"PCT41", "ALLOCATION OF POPULATION ITEMS", 3, 7L,
	"PCT42", "ALLOCATION OF RACE", 3, 7L,
	"PCT43", "ALLOCATION OF HISPANIC OR LATINO ORIGIN", 3, 7L,
	"PCT44", "ALLOCATION OF SEX", 3, 7L,
	"PCT45", "ALLOCATION OF AGE", 3, 7L,
	"PCT46", "ALLOCATION OF RELATIONSHIP", 3, 7L,
	"PCT47", "ALLOCATION OF POPULATION ITEMS FOR THE POPULATION IN GROUP QUARTERS", 3, 7L,
	"PCO1", "GROUP QUARTERS POPULATION BY SEX BY AGE", 39, 8L,
	"PCO2", "GROUP QUARTERS POPULATION IN INSTITUTIONAL FACILITIES BY SEX BY AGE", 39, 8L,
	"PCO3", "GROUP QUARTERS POPULATION IN CORRECTIONAL FACILITIES FOR ADULTS BY SEX BY AGE", 33, 8L,
	"PCO4", "GROUP QUARTERS POPULATION IN JUVENILE FACILITIES BY SEX BY AGE", 15, 8L,
	"PCO5", "GROUP QUARTERS POPULATION IN NURSING FACILITIES/SKILLED- NURSING FACILITIES BY SEX BY AGE", 31, 8L,
	"PCO6", "GROUP QUARTERS POPULATION IN OTHER INSTITUTIONAL FACILITIES BY SEX BY AGE", 39, 8L,
	"PCO7", "GROUP QUARTERS POPULATION IN NONINSTITUTIONAL FACILITIES BY SEX BY AGE", 39, 8L,
	"PCO8", "GROUP QUARTERS POPULATION IN COLLEGE/UNIVERSITY STUDENT HOUSING BY SEX BY AGE", 39, 9L,
	"PCO9", "GROUP QUARTERS POPULATION IN MILITARY QUARTERS BY SEX BY AGE", 25, 9L,
	"PCO10", "GROUP QUARTERS POPULATION IN OTHER NONINSTITUTIONAL FACILITIES BY SEX BY AGE", 39, 9L,
	"HCT1", "URBAN AND RURAL", 6, 10L,
	"HCT2", "TENURE", 4, 11L,
	"HCT3", "TOTAL POPULATION IN OCCUPIED HOUSING UNITS", 1, 11L,
	"HCT4", "TOTAL POPULATION IN OCCUPIED HOUSING UNITS BY TENURE", 4, 11L,
	"HCT5", "AVERAGE HOUSEHOLD SIZE OF OCCUPIED HOUSING UNITS BY TENURE", 3, 11L,
	"HCT6", "HOUSEHOLD SIZE", 8, 11L,
	"HCT7", "TENURE BY HOUSEHOLD SIZE", 17, 11L,
	"HCT8", "TENURE BY AGE OF HOUSEHOLDER", 21, 11L,
	"HCT9", "TENURE BY HOUSEHOLD TYPE BY AGE OF HOUSEHOLDER", 69, 11L,
	"HCT10", "TENURE BY PRESENCE AND AGE OF OWN CHILDREN", 13, 11L,
	"HCT11", "TENURE BY PRESENCE AND AGE OF RELATED CHILDREN", 13, 11L,
	"HCT12", "TENURE BY PRESENCE AND AGE OF PEOPLE UNDER 18 YEARS BY HOUSEHOLD TYPE (EXCLUDING HOUSEHOLDERS, SPOUSES, AND UNMARRIED PARTNERS)", 13, 11L,
	"HCT13", "OCCUPIED HOUSING UNITS SUBSTITUTED", 3, 11L,
	"HCT14", "ALLOCATION OF TENURE", 3,  11L
)
