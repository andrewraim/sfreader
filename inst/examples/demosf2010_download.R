library(sfreader)
library(dplyr)

dat = demosf2010_states %>%
	filter(abbreviation %in% c("ok", "ri", "md"))

demosf2010_dhc_download(dat$name, dest_dir = "~/Documents/datasets/demo_dhc_2010_us")
demosf2010_pl94_download(dat$name, dest_dir = "~/Documents/datasets/demo_pl94_2010_us")
