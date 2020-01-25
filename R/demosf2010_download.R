#' @export
demo2010sf_dhc_download = function(state_names, dest_dir, base_url = NULL)
{
	if (!dir.exists(dest_dir)) {
		stop("specified dest_dir does not exist")
	}

	if (is.null(base_url)) {
		base_url = paste("https://www2.census.gov", "programs-surveys",
			"decennial", "2020", "program-management", "data-product-planning",
			"2010-demonstration-data-products",
			"02-Demographic_and_Housing_Characteristics", sep = "/")
	}

	state_names = gsub(pattern = " ", replacement = "_", state_names)
	dat = demosf2010_states %>% filter(name %in% state_names)
	L = nrow(dat)
	if (L == 0) {
		stop("Must provide at least one valid state name")
	}

	for (l in 1:L) {
		dest_subdir = sprintf("%s/%s", dest_dir, dat$name[l])
		if (dir.exists(dest_subdir)) {
			logger("Directory %s exists. Skipping...\n", dest_subdir)
			next
		}

		url = sprintf("%s/%s/%s2010.dhc.zip", base_url, dat$name[l], dat$abbreviation[l])
		destfile = sprintf("%s/%s2010.dhc.zip", dest_dir, dat$abbreviation[l])
		download.file(url, destfile)
		unzip(destfile, exdir = dest_subdir)
	}
}

#' @export
demo2010sf_pl94_download = function(state_names, dest_dir, base_url = NULL)
{
	if (!dir.exists(dest_dir)) {
		stop("sppecified dest_dir does not exist")
	}

	if (is.null(base_url)) {
		base_url = paste("https://www2.census.gov", "programs-surveys",
			"decennial", "2020", "program-management", "data-product-planning",
			"2010-demonstration-data-products",
			"01-Redistricting_File--PL_94-171", sep = "/")
	}

	state_names = gsub(pattern = " ", replacement = "_", state_names)
	dat = demosf2010_states %>% filter(name %in% state_names)
	L = nrow(dat)
	if (L == 0) {
		stop("Must provide at least one valid state name")
	}

	for (l in 1:L) {
		dest_subdir = sprintf("%s/%s", dest_dir, dat$name[l])
		if (dir.exists(dest_subdir)) {
			logger("Directory %s exists. Skipping...\n", dest_subdir)
			next
		}

		url = sprintf("%s/%s/%s2010.pl.zip", base_url, dat$name[l], dat$abbreviation[l])
		destfile = sprintf("%s/%s2010.pl.zip", dest_dir, dat$abbreviation[l])
		download.file(url, destfile)
		unzip(destfile, exdir = dest_subdir)
	}
}
