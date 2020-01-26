library(sfreader)

dhc_dest_dir = "~/Documents/datasets/demo_2010_us/dhc"
pl94_dest_dir = "~/Documents/datasets/demo_2010_us/pl94"

if (FALSE) {
	dat = demosf2010_states %>%
		filter(abbreviation %in% c("ok", "ri", "md"))
	demosf2010_dhc_download(dat$name, dhc_dest_dir)
	demosf2010_dhc_download(dat$name, pl94_dest_dir)
}

# The PL94 and DHC products each get their own reader
reader = demosf2010_dhc_reader$new(dhc_dest_dir)

reader$getTableNames()
reader$getSummaryLevels()
reader$getDataDictionary()

p3_040_ri = reader$getTable(table_name = "P1", state_name = "National", sumlev = "020")
print(p3_040_ri)
