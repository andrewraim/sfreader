library(sfreader)
library(RSQLite)

dest_dir = "~/datasets/demo_2010_us/pl"

if (FALSE) {
	dat = demosf2010_states %>%
		filter(abbreviation %in% c("ok", "ri", "md"))
	demosf2010_pl_download(dat$name, dest_dir)
}

# The PL and DHC products each get their own reader
reader = demosf2010_pl_reader$new(dest_dir)

reader$getTableNames()
reader$getSummaryLevels()
reader$getDataDictionary()

sqlite_file = "demosf2010_pl.sqlite"
unlink(sqlite_file)
conn = dbConnect(RSQLite::SQLite(), sqlite_file)
reader$write_sqlite(conn,
	target_tables = c("P1","P2", "P3","P4","P5", "H1"))
dbDisconnect(conn)

conn = dbConnect(RSQLite::SQLite(), sqlite_file)
dbListTables(conn)

dat = dbGetQuery(conn, statement = "
	select *
	from geo_140 g, P1 p
	where p.LOGRECNO == g.LOGRECNO
	and p.FILEID == g.FILEID
")
head(dat)
nrow(dat)

dat = dbGetQuery(conn, statement = "
	select *
	from P1
	where LOGRECNO == '0000002'
")
head(dat)

dat_geo = dbGetQuery(conn, statement = "
	select *
	from geo_040
")
head(dat_geo)

dbDisconnect(conn)
