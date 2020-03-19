#' @export
aiansf2010_download = function(dest_dir, base_url = NULL)
{
	if (!dir.exists(dest_dir)) {
		stop("specified dest_dir does not exist")
	}

	if (is.null(base_url)) {
		base_url = paste("https://www2.census.gov", "census_2010", "07-AIAN_Summary_File", sep = "/")
	}

	url = sprintf("%s/National/us2010.an2.zip", base_url)
	destfile = sprintf("%s/us2010.an2.zip", dest_dir)
	download.file(url, destfile)
	unzip(destfile, exdir = dest_subdir)

	url = sprintf("%s/National/2010_AIANSF_MSAccessShell.zip", base_url)
	destfile = sprintf("%s/2010_AIANSF_MSAccessShell.zip", dest_dir)
	download.file(url, destfile)
	unzip(destfile, exdir = dest_subdir)


	state_names = gsub(pattern = " ", replacement = "_", state_names)
	dat = demo2010_states %>% filter(name %in% state_names)
	L = nrow(dat)
	if (L == 0) {
		stop("Must provide at least one valid state name")
	}
}
