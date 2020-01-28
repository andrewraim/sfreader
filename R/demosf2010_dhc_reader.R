# TBD: This is different than the AIAN structure. We have to work through all the states.
# Also, the MS Access tables aren't provided, so it may be uglier to code...

#' @export
demosf2010_dhc_reader = R6Class("demosf2010_dhc_reader",
	private = list(
    	path_to_files = NULL,
		geo_list = NULL,
		readSummaryLevels = function() {
			logger("Begin reading summary levels\n")
			subdirs = data.frame(name = list.dirs(
				private$path_to_files,
				full.names = FALSE)) %>%
				mutate(name = as.character(name))
			state_dirs = demosf2010_states %>%
				inner_join(subdirs, by = c("name" = "name"))

			summary_levels = names(demosf2010_geo_cols)
			private$geo_list = list()

			for (idx_level in 1:length(summary_levels)) {
				summary_level = summary_levels[idx_level]
				logger("Processing summary_level %s\n", summary_level)

				# We will interpret all columns as strings.
				cols = demosf2010_geo_cols[[summary_level]]
				ncols = nrow(cols)
				col_types = paste(rep("c", ncols), collapse = "")

				# Create an empty table that we can append to
				private$geo_list[[idx_level]] = data.frame(matrix("NA", ncol = ncols, nrow = 0), stringsAsFactors = FALSE) %>%
					setNames(nm = cols$col_names)

				for (idx_state in 1:nrow(state_dirs)) {
					state_name = state_dirs$name[idx_state]
					state_abbr = state_dirs$abbreviation[idx_state]
					logger("Processing state: %s\n", state_name)

					# Build a data structure with geo information. This serves as
					# an index into all the other data files.
					geo_file = sprintf("%s/%s/%sgeo2010.dhc",
						private$path_to_files, state_name, state_abbr)

					# Need the first 11 characters of each record to determine the type
					# (i.e. summary level) of each record.
					lines = readLines(geo_file)
					sl = substr(lines, 9, 11)

					idx_lines = which(sl == summary_level)
					if (length(idx_lines) > 0) {
						dat_new = read_fwf(lines[idx_lines], col_positions = cols, col_types = col_types)
						private$geo_list[[idx_level]] = private$geo_list[[idx_level]] %>%
							union_all(dat_new)
					}
				}
			}

			names(private$geo_list) = summary_levels
			logger("Finished reading summary levels\n")
		}
	),
	public = list(
		initialize = function(path_to_files) {
			private$path_to_files = path_to_files
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
		write_sqlite = function(conn, target_tables = NULL)
		{
			stopifnot(dbIsValid(conn))

			if (is.null(target_tables)) {
				logger("Saving all available tables to the database\n")
				target_tables = demosf2010_dhc_segments$NUMBER
			}

			private$readSummaryLevels()
			summary_levels = names(private$geo_list)

			for (idx_level in 1:length(summary_levels)) {
				summary_level = summary_levels[idx_level]
				logger("Creating sqlite table for summary_level %s\n", summary_level)
				table_name = sprintf("geo_%s", summary_level)
				dbWriteTable(conn, table_name, private$geo_list[[idx_level]])
			}

			# Now read each SF table and make a corresponding sqlite table
			# To prevent having to read CSVs over and over again, let's try to go
			# one segment at a time...
			target_chariter = "000"
			segments = demosf2010_dhc_segments %>%
				filter(NUMBER %in% target_tables) %>%
				group_by(SEGMENT) %>%
				summarize(n = n())
			for (idx_segment in 1:nrow(segments)) {
				target_segment = segments$SEGMENT[idx_segment]
				logger("Processing segment %d files\n", target_segment)

				data_files = list.files(
					path = private$path_to_files,
					pattern = sprintf("*%s%02d", target_chariter, target_segment),
					full.names = TRUE, recursive = TRUE)

				dat_list = list()
				for (idx_file in 1:length(data_files)) {
					data_file = data_files[idx_file]
					logger("Processing file %s\n", data_file)
					dat = read_csv(file = data_file, col_names = FALSE)

					dat_segment = demosf2010_dhc_segments %>%
						arrange(ORDERID) %>%
						filter(SEGMENT == target_segment) %>%
						filter(NUMBER %in% target_tables) %>%
						mutate(end_pos = cumsum(NCOLS))

					for (idx_tables in 1:nrow(dat_segment)) {
						table_name = dat_segment$NUMBER[idx_tables]
						logger("Processing table %s\n", table_name)

						start_col = dat_segment$end_pos[idx_tables] - dat_segment$NCOLS[idx_tables] + 1 + 5
						end_col = dat_segment$end_pos[idx_tables] + 5
						idx_cols = seq(start_col, end_col)

						# Try to reconstuct column names
						cn = c("FILEID", "STUSAB", "CHARITER", "CIFSN", "LOGRECNO",
							self$getRawColNames(table_name, length(idx_cols)))

						if (is.null(dat_list[[table_name]])) {
							dat_list[[table_name]] = list()
						}
						dat_selected = dat[,c(1:5, idx_cols)]
						colnames(dat_selected) = cn
						dat_list[[table_name]][[idx_file]] = dat_selected
					}
				}

				for (idx_table in 1:length(dat_list)) {
					table_name = names(dat_list)[idx_table]
					dat = dat_list[[table_name]][[1]]
					seq_files = setdiff(seq_along(dat_list[[table_name]]), 1)
					for (idx_file in seq_files) {
						dat = dat %>% union_all(dat_list[[table_name]][[idx_file]])
					}
					dbWriteTable(conn, table_name, dat)
				}
			}
		},
		getRawColNames = function(table_name, count) {
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
			sprintf("%s%s%04d", prefix, padded_num, 1:count)
		}
	)
)
