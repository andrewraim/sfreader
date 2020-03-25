library(readr)
library(dplyr)
library(stringr)

src_path = "C:/Users/raim0001/Documents/datasets/sf2_2000"
dest_path = sprintf("%s/%s", getwd(), "data")

# Some of the links on the website for the 2000 SF2 dataset seemed to be broken.
# I found support files at: https://www.census.gov/support/cen2000.html
# Namely, the SAS file had the field widths coded in.

dat_geo = tribble(
	~FIELD, ~`STARTING POSITION`, ~`ENDING POSITION`,
   "FILEID", 1, 6,
   "STUSAB", 7, 8,
   "SUMLEV", 9, 11,
   "GEOCOMP", 12, 13,
   "CHARITER", 14, 16,
   "CIFSN", 17, 18,
   "LOGRECNO", 19, 25,
   "REGION", 26, 26,
   "DIVISION", 27, 27,
   "STATECE", 28, 29,
   "STATE", 30, 31,
   "COUNTY", 32, 34,
   "COUNTYSC", 35, 36,
   "COUSUB", 37, 41,
   "COUSUBCC", 42, 43,
   "COUSUBSC", 44, 45,
   "PLACE", 46, 50,
   "PLACECC", 51, 52,
   "PLACESC", 54, 55,
   "TRACT", 56, 61,
   "BLKGRP", 62, 62,
   "BLOCK", 63, 66,
   "IUC", 67, 68,
   "CONCIT", 69, 73,
   "CONCITCC", 74, 75,
   "CONCITSC", 76, 77,
   "AIANHH", 78, 81,
   "AIANHHFP", 82, 86,
   "AIANHHCC", 87, 88,
   "AIHHTLI", 89, 89,
   "AITSCE", 90, 92,
   "AITS", 93, 97,
   "AITSCC", 98, 99,
   "ANRC", 100, 104,
   "ANRCCC", 105, 106,
   "MSACMSA", 107, 110,
   "MASC", 111, 112,
   "CMSA", 113, 114,
   "MACCI", 115, 115,
   "PMSA", 116, 119,
   "NECMA", 120, 123,
   "NECMACCI", 124, 124,
   "NECMASC", 125, 126,
   "EXI", 127, 127,
   "UA", 128, 132,
   "UASC", 133, 134,
   "UATYPE", 135, 135,
   "UR", 136, 136,
   "CD106", 137, 138,
   "CD108", 139, 140,
   "CD109", 141, 142,
   "CD110", 143, 144,
   "SLDU", 145, 147,
   "SLDL", 148, 150,
   "VTD", 151, 156,
   "VTDI", 157, 157,
   "ZCTA3", 158, 160,
   "ZCTA5", 161, 165,
   "SUBMCD", 166, 170,
   "SUBMCDCC", 171, 172,
   "AREALAND", 173, 186,
   "AREAWATR", 187, 200,
   "NAME", 201, 290,
   "FUNCSTAT", 291, 291,
   "GCUNI", 292, 292,
   "POP100", 293, 301,
   "HU100", 302, 310,
   "INTPTLAT", 311, 319,
   "INTPTLON", 320, 329,
   "LSADC", 330, 331,
   "PARTFLAG", 332, 332,
   "SDELM", 333, 337,
   "SDSEC", 338, 342,
   "SDUNI", 343, 347,
   "TAZ", 348, 353,
   "UGA", 354, 358,
   "PUMA5", 359, 363,
   "PUMA1", 364, 368,
   "RESERVE2", 369, 383,
   "MACC", 384, 388,
   "UACP", 389, 393,
   "RESERVED", 394, 400)

sf2_2000_geo_cols = dat_geo %>%
	mutate(`STARTING POSITION` = as.integer(`STARTING POSITION`)) %>%
	mutate(`ENDING POSITION` = as.integer(`ENDING POSITION`)) %>%
	mutate(`FIELD SIZE` = `ENDING POSITION` - `STARTING POSITION` + 1L)

dest_file = sprintf("%s/%s.rda", dest_path, "sf2_2000_geo_cols")
save(sf2_2000_geo_cols, file = dest_file)


dat_colnames = tribble(
~DATA_FILE, ~ORDER, ~NAME
"01", FILEID
"01",         STUSAB
"01",         CHARITER
"01",         CIFSN
"01",         LOGRECNO
"01",         PCT001001
"01",         PCT002001
"01",         PCT002002
"01",         PCT002003
"01",         PCT002004
"01",         PCT002005
"01",         PCT002006
"01",         PCT003001
"01",         PCT003002
"01",         PCT003003
"01",         PCT003004
"01",         PCT003005
"01",         PCT003006
"01",         PCT003007
"01",         PCT003008
"01",         PCT003009
"01",         PCT003010
"01",         PCT003011
"01",         PCT003012
"01",         PCT003013
"01",         PCT003014
"01",         PCT003015
"01",         PCT003016
"01",         PCT003017
"01",         PCT003018
"01",         PCT003019
"01",         PCT003020
"01",         PCT003021
"01",         PCT003022
"01",         PCT003023
         PCT003024
         PCT003025
         PCT003026
         PCT003027
         PCT003028
         PCT003029
         PCT003030
         PCT003031
         PCT003032
         PCT003033
         PCT003034
         PCT003035
         PCT003036
         PCT003037
         PCT003038
         PCT003039
         PCT003040
         PCT003041
         PCT003042
         PCT003043
         PCT003044
         PCT003045
         PCT003046
         PCT003047
         PCT003048
         PCT003049
         PCT003050
         PCT003051
         PCT003052
         PCT003053
         PCT003054
         PCT003055
         PCT003056
         PCT003057
         PCT003058
         PCT003059
         PCT003060
         PCT003061
         PCT003062
         PCT003063
         PCT003064
         PCT003065
         PCT003066
         PCT003067
         PCT003068
         PCT003069
         PCT003070
         PCT003071
         PCT003072
         PCT003073
         PCT003074
         PCT003075
         PCT003076
         PCT003077
         PCT003078
         PCT003079
         PCT003080
         PCT003081
         PCT003082
         PCT003083
         PCT003084
         PCT003085
         PCT003086
         PCT003087
         PCT003088
         PCT003089
         PCT003090
         PCT003091
         PCT003092
         PCT003093
         PCT003094
         PCT003095
         PCT003096
         PCT003097
         PCT003098
         PCT003099
         PCT003100
         PCT003101
         PCT003102
         PCT003103
         PCT003104
         PCT003105
         PCT003106
         PCT003107
         PCT003108
         PCT003109
         PCT003110
         PCT003111
         PCT003112
         PCT003113
         PCT003114
         PCT003115
         PCT003116
         PCT003117
         PCT003118
         PCT003119
         PCT003120
         PCT003121
         PCT003122
         PCT003123
         PCT003124
         PCT003125
         PCT003126
         PCT003127
         PCT003128
         PCT003129
         PCT003130
         PCT003131
         PCT003132
         PCT003133
         PCT003134
         PCT003135
         PCT003136
         PCT003137
         PCT003138
         PCT003139
         PCT003140
         PCT003141
         PCT003142
         PCT003143
         PCT003144
         PCT003145
         PCT003146
         PCT003147
         PCT003148
         PCT003149
         PCT003150
         PCT003151
         PCT003152
         PCT003153
         PCT003154
         PCT003155
         PCT003156
         PCT003157
         PCT003158
         PCT003159
         PCT003160
         PCT003161
         PCT003162
         PCT003163
         PCT003164
         PCT003165
         PCT003166
         PCT003167
         PCT003168
         PCT003169
         PCT003170
         PCT003171
         PCT003172
         PCT003173
         PCT003174
         PCT003175
         PCT003176
         PCT003177
         PCT003178
         PCT003179
         PCT003180
         PCT003181
         PCT003182
         PCT003183
         PCT003184
         PCT003185
         PCT003186
         PCT003187
         PCT003188
         PCT003189
         PCT003190
         PCT003191
         PCT003192
         PCT003193
         PCT003194
         PCT003195
         PCT003196
         PCT003197
         PCT003198
         PCT003199
         PCT003200
         PCT003201
         PCT003202
         PCT003203
         PCT003204
         PCT003205
         PCT003206
         PCT003207
         PCT003208
         PCT003209
         PCT004001
         PCT004002
"01",         PCT004003)

# The following files come from SF2_MSAccess_2007.accdb, which is
# provided along with the dataset. I can't directly read Access DBs from
# R (I think I'm missing an ODBC driver), so I opened it in Access, and
# exported each table to a CSV. Then I read the CSVs here and save them
# to R datasets.

ff = sprintf("%s/%s", src_path, "Iterations_list.csv")
sf2_2010_iterations = read_csv(ff, col_types = cols(`SORT ID` = col_integer())) %>%
	filter(!is.na(`Iteration Code`))
dest_file = sprintf("%s/%s.rda", dest_path, "sf2_2010_iterations")
save(sf2_2010_iterations, file = dest_file)

ff = sprintf("%s/%s", src_path, "SF2_GeoHeader.csv")
sf2_2010_geoheader = read_csv(ff)
dest_file = sprintf("%s/%s.rda", dest_path, "sf2_2010_geoheader")
save(sf2_2010_geoheader, file = dest_file)

ff = sprintf("%s/%s", src_path, "DataDictionary_NOTES.csv")
sf2_2010_geoheader_dd_notes = read_csv(ff)
dest_file = sprintf("%s/%s.rda", dest_path, "sf2_2010_geoheader_dd_notes")
save(sf2_2010_geoheader_dd_notes, file = dest_file)

ff = sprintf("%s/%s", src_path, "DataDictionary.csv")
col_types = cols(SEGMENT = col_integer(), SORT_ID = col_integer())
sf2_2010_geoheader_dd = read_csv(ff, col_types = col_types, trim_ws = FALSE)
dest_file = sprintf("%s/%s.rda", dest_path, "sf2_2010_geoheader_dd")
save(sf2_2010_geoheader_dd, file = dest_file)

for (i in 1:11) {
	ff = sprintf("%s/SF2_Segment_%02d.csv", src_path, i)
	dat = read_csv(ff)
	dat_name = sprintf("sf2_2010_segment%02d", i)
	assign(dat_name, dat)
	dest_file = sprintf("%s/%s.rda", dest_path, dat_name)
	save(list = dat_name, file = dest_file)
}

# Create a list of available tables, along with their segments
table_segments = sf2_2010_geoheader_dd %>%
	filter(str_detect(`FIELD NAME`, "^Total")) %>%
	arrange(SORT_ID) %>%
	select(SEGMENT, NUMBER = TABLE)
table_descriptions = sf2_2010_geoheader_dd %>%
	filter(is.na(`FIELD CODE`)) %>%
	filter(!str_detect(`FIELD NAME`, "^Universe:")) %>%
	filter(str_detect(`FIELD NAME`, "\\[")) %>%
	filter(str_detect(`FIELD NAME`, "\\]")) %>%
	arrange(SORT_ID) %>%
	select(NUMBER = TABLE, DESCRIPTION = `FIELD NAME`)
sf2_2010_tables = table_segments %>%
	inner_join(table_descriptions, by = c('NUMBER' = 'NUMBER'))
dest_file = sprintf("%s/%s.rda", dest_path, "sf2_2010_tables")
save(sf2_2010_tables, file = dest_file)
