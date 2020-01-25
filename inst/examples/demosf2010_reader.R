library(sfreader)

if (FALSE) {
	state_names = c("Maryland", "Oklahoma")

	dest_dir = "~/Documents/datasets/demosf2010/dhc/"
	demo2010sf_dhc_download(state_names, dest_dir, base_url = NULL)

	dest_dir = "~/Documents/datasets/demosf2010/pl94/"
	demo2010sf_dhc_download(state_names, dest_dir, base_url = NULL)
}

# The PL94 and DHC products each get their own reader
reader = demosf2010_dhc_reader$new("~/Documents/datasets/demosf2010/dhc/")

reader$getTableNames()
reader$getSummaryLevels()
reader$getIterations()
reader$getDataDictionary()

