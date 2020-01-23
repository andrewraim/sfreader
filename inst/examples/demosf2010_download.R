library(sfreader)

dat = demo2010_states %>%
	filter(abbreviation %in% c("ok", "ri", "md"))

demo2010_dhc_download(dat$name,
	dest_dir = "C:/Users/raim0001/Documents/demo_dhc_2010_us")
demo2010_pl94_download(dat$name,
	dest_dir = "C:/Users/raim0001/Documents/demo_pl94_2010_us")
