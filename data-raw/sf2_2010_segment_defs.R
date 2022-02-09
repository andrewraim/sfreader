# This is a utility to process the DataDictionary table from SF2 2010 into
# variable descriptions which are easier to work with in code. This table
# is from the Microsoft Access database which is available on the Census
# website along with the SF data.
#
# The variable names are originally written with indentations which indicate
# that they are subcategories of a previous variable.

library(readr)

na_if_empty = function(x) {
	ifelse(length(x) > 0, x, NA)
}

process_segment = function(x, indent = "      ")
{
	out = x %>% mutate(PARENT_FIELD = NA, DESCRIPTION_FULL = NA)

	field_path = c()
	desc_path = c()

	for (i in 1:nrow(x)) {
		desc_node_raw = x$DESCRIPTION[i]
		desc_node_strp = str_replace(desc_node_raw, ":(\\s)*$", "")
		tok = str_split(desc_node_strp, indent, simplify = TRUE) %>% as.character()
		indent_level = length(tok)
		desc_node = tok[indent_level]

		desc_path = c(desc_path[seq_len(indent_level - 1)], desc_node)
		field_path = c(field_path[seq_len(indent_level - 1)], x$FIELD[i])

		out$DESCRIPTION_FULL[i] = paste(desc_path, collapse = ": ")
		out$PARENT_FIELD[i] = na_if_empty( field_path[indent_level-1] )
	}

	out %>%
		mutate(PARENT_FIELD = as.character(PARENT_FIELD))
}

prep_table = function(x, segment)
{
	seg_str = sprintf("%02d", segment)

	header_dat = tribble(
		~SEGMENT, ~POSITION, ~FIELD, ~PARENT_FIELD, ~TABLE, ~DESCRIPTION,
		seg_str, 1L, "FILEID",   NA, "HEAD", "File Identification",
		seg_str, 2L, "STUSAB",   NA, "HEAD", "State/US-Abbreviation (USPS)",
		seg_str, 3L, "CHARITER", NA, "HEAD", "Characteristic iteration",
		seg_str, 4L, "CIFSN",    NA, "HEAD", "Characteristic Iteration File Sequence Number",
		seg_str, 5L, "LOGRECNO", NA, "HEAD", "Logical Record Number"
	) %>% mutate(PARENT_FIELD = as.character(PARENT_FIELD))

	# Note that we take table name to be the prefix of the variable name; e.g.,
	# "PCT002" rather than "PCT2". The latter appears to be more readable, but
	# the former appears to be more useful in processing.
	other_dat = process_segment(dat %>% filter(SEGMENT == segment)) %>%
		mutate(SEGMENT = sprintf("%02d", SEGMENT)) %>%
		mutate(POSITION = row_number() + 5L) %>%
		mutate(TABLE = substr(FIELD, 1, 6)) %>%
		select(SEGMENT, POSITION, FIELD, PARENT_FIELD, TABLE, DESCRIPTION = DESCRIPTION_FULL)

	rbind(header_dat, other_dat)
}

path = "/path/to/sf2_2010/DataDictionary.csv"
dat = read_csv(path, col_types = 'icicc', trim_ws = FALSE) %>%
	rename(DESCRIPTION = 4, FIELD = 5)

sf2_2010_segments = rbind(
	prep_table(dat, 1L),
	prep_table(dat, 2L),
	prep_table(dat, 3L),
	prep_table(dat, 4L),
	prep_table(dat, 5L),
	prep_table(dat, 6L),
	prep_table(dat, 7L),
	prep_table(dat, 8L),
	prep_table(dat, 9L),
	prep_table(dat, 10L),
	prep_table(dat, 11L)
)

write.csv(sf2_2010_segments, file = "data-raw/sf2_2010_segments.csv", quote = c(6), row.names = FALSE)
