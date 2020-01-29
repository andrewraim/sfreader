library(tibble)
library(readr)
library(readxl)
library(dplyr)
library(stringr)

dest_path = sprintf("%s/%s", getwd(), "data")

demosf2010_states = tribble(
	~name, ~abbreviation,
	"Alabama", "al",
	"Alaska", "ak",
	"Arizona", "az",
	"Arkansas", "ar",
	"California", "ca",
	"Colorado", "co",
	"Connecticut", "ct",
	"Delaware", "de",
	"District_of_Columbia", "dc",
	"Florida", "fl",
	"Georgia", "ga",
	"Hawaii", "hi",
	"Idaho", "id",
	"Illinois", "il",
	"Indiana", "in",
	"Iowa", "ia",
	"Kansas", "ks",
	"Kentucky", "ky",
	"Louisiana", "la",
	"Maine", "me",
	"Maryland", "md",
	"Massachusetts", "ma",
	"Michigan", "mi",
	"Minnesota", "mn",
	"Mississippi", "ms",
	"Missouri", "mo",
	"Montana", "mt",
	"National", "us",
	"Nebraska", "ne",
	"Nevada", "nv",
	"New_Hampshire", "nh",
	"New_Jersey", "nj",
	"New_Mexico", "nm",
	"New_York", "ny",
	"North_Carolina", "nc",
	"North_Dakota", "nd",
	"Ohio", "oh",
	"Oklahoma", "ok",
	"Oregon", "or",
	"Pennsylvania", "pa",
	"Puerto_Rico", "pr",
	"Rhode_Island", "ri",
	"South_Carolina", "sc",
	"South_Dakota", "sd",
	"Tennessee", "tn",
	"Texas", "tx",
	"Utah", "ut",
	"Vermont", "vt",
	"Virginia", "va",
	"Washington", "wa",
	"West_Virginia", "wv",
	"Wisconsin", "wi",
	"Wyoming", "wy")
dest_file = sprintf("%s/%s.rda", dest_path, "demosf2010_states")
save(demosf2010_states, file = dest_file)

