#' @export
sf2_2010_reader = R6Class("sf2_2010_reader",
	private = list(
    	path_to_files = NULL,
		geo_list = NULL,
		readGeoFile = function() {
			logger("Begin reading summary levels\n")

			# Build a data structure with geo information. This serves as
			# an index into all the other data files.
			ff = list.files(path = private$path_to_files, pattern = "geo2010.sf2")
			if (length(ff) != 1) {
				msg = sprintf("Could not find geo file in %s\n", private$path_to_files)
				stop(msg)
			}

			geo_file = sprintf("%s/%s", private$path_to_files, ff[1])

			# Read in the fixed width geoheader
			geo_dat = read_fwf(file = geo_file,
				col_positions = fwf_widths(sf2_2010_geo_cols[['FIELD SIZE']]))

			# Assign column headers based on access specifications
			colnames(geo_dat) = sf2_2010_geo_cols[['DATA DICTIONARY REFERENCE']]

			summary_levels = sort(unique(geo_dat$SUMLEV))
			private$geo_list = list()
			for (idx_level in 1:length(summary_levels)) {
				summary_level = summary_levels[idx_level]
				logger("Processing summary_level %s\n", summary_level)
				private$geo_list[[idx_level]] = geo_dat %>%
					filter(SUMLEV == summary_level)
			}

			names(private$geo_list) = summary_levels
			logger("Finished reading summary levels\n")
		}
	),
	public = list(
		initialize = function(path_to_files) {
			private$path_to_files = path_to_files

			logger("Begin reading Geo file\n")
			private$readGeoFile()
			summary_levels = names(private$geo_list)
			logger("Finished reading Geo file\n")
		},
		getTableNames = function() {
			return(sf2_2010_tables)
		},
		getSummaryLevels = function() {
			return(names(private$geo_list))
		},
		getIterations = function() {
			return(sf2_2010_iterations)
		},
		getDataDictionary = function() {
			return(sf2_2010_geoheader_dd)
		},
		write_sqlite = function(conn, target_tables = NULL)
		{
			stopifnot(dbIsValid(conn))

			if (is.null(target_tables)) {
				logger("Saving all available tables to the database\n")
				target_tables = sf2_2010_tables$NUMBER
			}

			for (idx_level in 1:length(summary_levels)) {
				summary_level = summary_levels[idx_level]
				logger("Creating sqlite table for summary_level %s\n", summary_level)
				table_name = sprintf("geo_%s", summary_level)
				dbWriteTable(conn, table_name, private$geo_list[[idx_level]])
			}

			# Now read each SF table and make a corresponding sqlite table
			# To prevent having to read CSVs over and over again, let's try to go
			# one segment at a time...

			# Let's try to collapse over chariters (detailed races), so they they
			# just form another column in the table.
			# sf2_2010_iterations
			target_chariters = sf2_2010_iterations$Code

			segments = sf2_2010_tables %>%
				filter(NUMBER %in% target_tables) %>%
				group_by(SEGMENT) %>%
				summarize(n = n())
			for (idx_segment in 1:nrow(segments)) {
				target_segment = as.integer(segments$SEGMENT[idx_segment])
				logger("Processing segment %d files\n", target_segment)

				data_files = list.files(
					path = sprintf("%s/National", private$path_to_files),
					pattern = sprintf("us.*%02d2010.an2", target_segment),
					full.names = TRUE, recursive = TRUE)

				dat_segment = sf2_2010_tables %>%
					filter(as.integer(SEGMENT) == target_segment)

				segment_dd = sf2_2010_geoheader_dd %>%
					filter(as.integer(`DATA SEGMENT`) == target_segment) %>%
					filter(`FIELD CODE` != "") %>%
					arrange(SORTID)

				dat_list = list()
				for (idx_file in 1:length(data_files)) {
					data_file = data_files[idx_file]
					logger("Processing file %s\n", data_file)
					dat = read_csv(file = data_file, col_names = FALSE)
					# chariter = substr(basename(data_file), 3, 5)

					cn_dat = sprintf("sf2_2010_segment%02d", target_segment)
					cn = colnames(get(cn_dat))
					colnames(dat) = cn

					for (idx_tables in 1:nrow(dat_segment)) {
						table_name = dat_segment$NUMBER[idx_tables]
						logger("Processing table %s\n", table_name)

						idx_col = which(segment_dd$`TABLE NUMBER` == table_name) + 5

						dat_selected = dat[,c(1:5, idx_col)] %>%
							mutate(FILEID = as.character(FILEID)) %>%
							mutate(STUSAB = as.character(STUSAB)) %>%
							mutate(CHARITER = as.character(CHARITER)) %>%
							mutate(CIFSN = as.character(CIFSN)) %>%
							mutate(LOGRECNO = as.character(LOGRECNO))
						if (length(dat_list) < idx_tables) {
							dat_list[[idx_tables]] = list()
						}
						dat_list[[idx_tables]][[idx_file]] = dat_selected
					}
				}

				for (idx_table in 1:length(dat_list)) {
					table_name = dat_segment$NUMBER[idx_table]
					dat_table = dat_list[[idx_table]][[1]]
					seq_files = setdiff(seq_along(dat_list[[table_name]]), 1)
					for (idx_file in seq_files) {
						dat_table = dat_table %>%
							union_all(dat_list[[table_name]][[idx_file]])
					}
					dbWriteTable(conn, table_name, dat)
				}
			}
		},
		getTable = function(table_name, sumlev, iteration, transform_colnames = FALSE) {
			stopifnot(sumlev %in% names(sf2_2010_geo_cols))

			target_segment = sf2_2010_tables %>%
				filter(NUMBER == table_name) %>%
				select(SEGMENT) %>%
				as.integer()
			if (is.na(target_segment)) {
				stop("Could not locate specified table")
			}

			table_dd = sf2_2010_geoheader_dd %>%
				filter(`TABLE NUMBER` == table_name) %>%
				filter(`FIELD CODE` != "") %>%
				arrange(SORTID)

			target_chariter = iteration
			target_geo = private$geo_list[[sumlev]] %>%
				select(-FILEID, -STUSAB, -SUMLEV, -GEOCOMP, -CHARITER, -CIFSN)

			dat_file = list.files(
				path = private$path_to_files,
				pattern = sprintf("us%s%02d", target_chariter, target_segment),
				full.names = TRUE)

			cn_dat = sprintf("sf2_2010_segment%02d", target_segment)
			cn = colnames(get(cn_dat))
			dat = read_csv(dat_file, col_names = cn) %>%
				select(LOGRECNO, table_dd$`FIELD CODE`)

			result = target_geo %>%
				inner_join(dat, by = c("LOGRECNO" = "LOGRECNO"))

			if (transform_colnames) {
				# This seems a little fragile, the indentations and colons in the
				# column names seem to coorrespond to logical hierarchical names.
				# Try to convert them so that each column name is interpretable on
				# its own.
				#
				# It looks like there are five spaces used to indent at each level.
				table_dd = table_dd %>%
					mutate(cn_xform = transform_col_names(table_dd$`FIELD NAME`, 5))

				dat_colnames = data.frame(col = colnames(result)) %>%
					mutate(col = as.character(col)) %>%
					left_join(table_dd, c("col" = "FIELD CODE")) %>%
					mutate(cn_xform = ifelse(!is.na(cn_xform), cn_xform, col))

				colnames(result) = dat_colnames$cn_xform
			}

			return(result)
		}
	)
)
