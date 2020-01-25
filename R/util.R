#' @export
printf = function(msg, ...)
{
        cat(sprintf(msg, ...))
}

#' @export
logger = function(msg, ...)
{
        sys.time = as.character(Sys.time())
        cat(sys.time, "-", sprintf(msg, ...))
}

# Take an ordered list of field names; try to use their indentation level
# to construct names with the hierarchy intact.
#' @export
transform_col_names = function(x, indent_spaces)
{
	L = length(x)
	out = character(L)

	prefix = c()
	for (l in 1:L) {
		leadws = str_extract(x[l], pattern = "^( )*")
		trimmed = trimws(x[l])
		indent_level = nchar(leadws) / indent_spaces
		idx = seq_len(indent_level)

		if (indent_level < length(prefix)) {
			prefix = prefix[idx]
		} else if (indent_level > length(prefix)) {
			stop("Something went wrong... indentiations and colons didn't line up")
		}

		out[l] = paste(c(prefix, trimmed), collapse = " ")

		if (endsWith(x[l], ":")) {
			prefix = c(prefix, trimmed)
		}
	}

	return(out)
}
