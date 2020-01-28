library(sfreader)

dhc_dest_dir = "~/datasets/demo_2010_us/dhc"
pl94_dest_dir = "~/datasets/demo_2010_us/pl94"

if (FALSE) {
	dat = demosf2010_states %>%
		filter(abbreviation %in% c("ok", "ri", "md", ""))

	dat = demosf2010_states %>%
		filter(abbreviation %in% c("us"))

	demosf2010_dhc_download(dat$name, dhc_dest_dir)
	demosf2010_pl94_download(dat$name, pl94_dest_dir)
}

# The PL94 and DHC products each get their own reader
reader = demosf2010_dhc_reader$new(dhc_dest_dir)

reader$getTableNames()
reader$getSummaryLevels()
reader$getDataDictionary()

p3_040_ri = reader$getTable(table_name = "P1", state_name = "Maryland", sumlev = "020")
print(p3_040_ri)

make_sqlite_demosf2010_dhc(
	path_to_files = "~/datasets/demo_2010_us/dhc/",
	outfile = "demosf2010_dhc.sqlite",
	target_tables = c("P1","P3","P4","P5","P6","P7","P12","P13"))

conn = dbConnect(RSQLite::SQLite(), "demosf2010_dhc.sqlite")
dbListTables(conn)
rs = dbSendQuery(conn, statement = "
	select *
	from geo_050 g, P1 p
	where p.LOGRECNO == g.LOGRECNO
	and p.FILEID == g.FILEID
	order by state, county
")
dat = dbFetch(rs)
head(dat)
dbClearResult(rs)
dbDisconnect(conn)
