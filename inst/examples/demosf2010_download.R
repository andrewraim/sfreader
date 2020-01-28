library(sfreader)
library(dplyr)

dat = demosf2010_states %>%
	filter(abbreviation %in% c("ok", "ri", "md"))

demosf2010_crosswalk_download("C:/Users/raim0001/Documents/datasets/demo_2010_us")
demosf2010_dhc_download(dat$name,
	dest_dir = "C:/Users/raim0001/Documents/datasets/demo_2010_us/dhc")
demosf2010_pl94_download(dat$name,
	dest_dir = "C:/Users/raim0001/Documents/datasets/demo_2010_us/pl94")

