library(sfreader)
library(RSQLite)

dest_dir = "~/datasets/demo_2010_us/pl94"

if (FALSE) {
	dat = demosf2010_states %>%
		filter(abbreviation %in% c("ok", "ri", "md"))
	demosf2010_dhc_download(dat$name, dest_dir)
}

# The PL94 and DHC products each get their own reader
reader = demosf2010_dhc_reader$new(dest_dir)

reader$getTableNames()
reader$getSummaryLevels()
reader$getDataDictionary()

sqlite_file = "demosf2010_dhc.sqlite"
unlink(sqlite_file)
conn = dbConnect(RSQLite::SQLite(), sqlite_file)
reader$write_sqlite(conn,
	target_tables = c("P1","P3","P4","P5","P6","P7","P12","P13"))
dbDisconnect(conn)

conn = dbConnect(RSQLite::SQLite(), sqlite_file)
dbListTables(conn)
dat = dbGetQuery(conn, statement = "
	select *
	from geo_050 g, P1 p
	where p.LOGRECNO == g.LOGRECNO
	and p.FILEID == g.FILEID
	order by state, county
")
head(dat)
dbClearResult(rs)
dbDisconnect(conn)



rs = dbSendQuery(conn, statement = "
	select *
	from geo_050 g
")
dat = dbFetch(rs)
