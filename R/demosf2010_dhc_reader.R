# TBD: This is different than the AIAN structure. We have to work through all the states.
# Also, the MS Access tables aren't provided, so it may be uglier to code...

#' @export
demosf2010_dhc_reader = R6Class("demosf2010_dhc_reader",
	private = list(
    	path_to_files = NULL,
		col_defns = NULL,
		usgeo = NULL
	),
	public = list(
		initialize = function(path_to_files) {
			logger("Begin initializing reader\n")
			private$path_to_files = path_to_files

			subdirs = data.frame(name = list.dirs(path_to_files, full.names = FALSE)) %>%
				mutate(name = as.character(name))
			state_dirs = demosf2010_states %>%
				inner_join(subdirs, by = c("name" = "name"))

			summary_levels = names(demosf2010_geo_cols)
			private$usgeo = list()

			for (idx_level in 1:length(summary_levels)) {
				summary_level = summary_levels[idx_level]
				logger("Processing summary_level %s\n", summary_level)

				# We will interpret all columns as strings.
				cols = demosf2010_geo_cols[[summary_level]]
				ncols = nrow(cols)
				col_types = paste(rep("c", ncols), collapse = "")

				# Create an empty table that we can append to
				private$usgeo[[idx_level]] = data.frame(matrix("NA", ncol = ncols, nrow = 0), stringsAsFactors = FALSE) %>%
					setNames(nm = cols$col_names)

				for (idx_state in 1:nrow(state_dirs)) {
					state_name = state_dirs$name[idx_state]
					state_abbr = state_dirs$abbreviation[idx_state]
					logger("Processing state: %s\n", state_name)

					# Build a data structure with geo information. This serves as
					# an index into all the other data files.
					geo_file = sprintf("%s/%s/%sgeo2010.dhc", path_to_files, state_name, state_abbr)

					# Need the first 11 characters of each record to determine the type
					# (i.e. summary level) of each record.
					lines = readLines(geo_file)
					sl = substr(lines, 9, 11)

					idx_lines = which(sl == summary_level)
					if (length(idx_lines) > 0) {
						dat_new = read_fwf(lines[idx_lines], col_positions = cols, col_types = col_types)
						private$usgeo[[idx_level]] = private$usgeo[[idx_level]] %>%
							union_all(dat_new)
					}
				}
			}

			names(private$usgeo) = summary_levels
			logger("Finished initializing reader\n")
		},
		getTableNames = function() {
			return(demosf2010_dhc_tables)
		},
		getSummaryLevels = function() {
			return(demosf2010_geo_cols)
		},
		getDataDictionary = function() {
			return(demosf2010_geoheader_dd)
		},
		getTable = function(table_name, state_name, sumlev, transform_colnames = FALSE) {
			stopifnot(sumlev %in% names(demosf2010_geo_cols))

			target_chariter = "000"

			target_segment = demosf2010_dhc_segments %>%
				filter(NUMBER == table_name) %>%
				select(SEGMENT) %>%
				as.integer()
			if (is.na(target_segment)) {
				stop("Could not locate specified table")
			}

			state_dat = demosf2010_states %>%
				filter(name == state_name)
			if (nrow(state_dat) == 0) {
				stop("Do not recognize specified state")
			}

			dat_file = list.files(
				path = private$path_to_files,
				pattern = sprintf("%s%s%02d", state_dat$abbreviation, target_chariter, target_segment),
				full.names = TRUE, recursive = TRUE)
			if (length(dat_file) == 0) {
				stop("Could not locate data for specified state")
			}

			dat = read_csv(file = dat_file, col_names = FALSE)

			dat_segment = demosf2010_dhc_segments %>%
				arrange(ORDERID) %>%
				filter(SEGMENT == target_segment) %>%
				mutate(start_pos = cumsum(NCOLS)) %>%
				filter(NUMBER == table_name)

			start_col = dat_segment$start_pos
			end_col = dat_segment$start_pos + dat_segment$NCOLS
			idx_cols = seq(start_col, end_col)

			# Try to reconstuct column names
			if (startsWith(table_name, "PCT")) {
				prefix = "PCT"
				num = substr(table_name, 4, nchar(table_name))
			} else if (startsWith(table_name, "PCO")) {
				prefix = "PCO"
				num = substr(table_name, 4, nchar(table_name))
			} else if (startsWith(table_name, "P")) {
				prefix = "P"
				num = substr(table_name, 2, nchar(table_name))
			} else if (startsWith(table_name, "H")) {
				prefix = "H"
				num = substr(table_name, 2, nchar(table_name))
			} else {
				stop("Don't know how to handle table name")
			}

			if (str_ends(num, "[0-9]+")) {
				num = paste0(num, "0")
			}
			padded_num = str_pad(num, 4, "left", pad = "0")
			cn = c("LOGRECNO",
				sprintf("%s%s%04d", prefix, padded_num, seq_along(idx_cols)))
			dat_table = dat[,c(5, idx_cols)]
			colnames(dat_table) = cn

			target_geo = private$usgeo[[sumlev]] %>%
				select(-FILEID, -STUSAB, -SUMLEV, -GEOCOMP, -CHARITER, -CIFSN)

			result = target_geo %>%
				inner_join(dat_table, by = c("LOGRECNO" = "LOGRECNO"))

			if (transform_colnames) {
				stop("TBD: Need to implement transformed colnames")
				dat_names = demosf2010_dhc_dd %>%
					filter(NUMBER == table_name) %>%
					filter(!is.na(CELL_COUNT)) %>%
					mutate(DESC = paste(DESC1, DESC2, DESC3, DESC4, DESC5, DESC6, DESC7, sep = " "))
			}

			return(result)
		}
	)
)
