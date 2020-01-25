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
		getIterations = function() {
			return(aiansf2010_iterations)
		},
		getDataDictionary = function() {
			return(aiansf2010_geoheader_dd)
		},
		getTable = function(table_name, sumlev, iteration, transform_colnames = FALSE) {
			stopifnot(sumlev %in% names(aiansf2010_geo_cols))

			target_segment = aiansf2010_tables %>%
				filter(NUMBER == table_name) %>%
				select(SEGMENT) %>%
				as.integer()
			if (is.na(target_segment)) {
				stop("Could not locate specified table")
			}

			table_dd = aiansf2010_geoheader_dd %>%
				filter(`TABLE NUMBER` == table_name) %>%
				filter(`FIELD CODE` != "") %>%
				arrange(SORTID)

			target_chariter = iteration
			target_geo = private$usgeo[[sumlev]] %>%
				select(-FILEID, -STUSAB, -SUMLEV, -GEOCOMP, -CHARITER, -CIFSN)

			dat_file = list.files(
				path = private$path_to_files,
				pattern = sprintf("us%s%02d", target_chariter, target_segment),
				full.names = TRUE)

			cn_dat = sprintf("aiansf2010_segment%02d", target_segment)
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
