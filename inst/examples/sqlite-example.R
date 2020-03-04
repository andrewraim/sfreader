library(RSQLite)

data("mtcars")
mtcars$car_names = rownames(mtcars)
rownames(mtcars) = c()
head(mtcars)

conn = dbConnect(RSQLite::SQLite(), "cars.db")

dbWriteTable(conn, "mtcars_table", mtcars)
dbListTables(conn)

rs = dbSendQuery(conn,
	"SELECT * FROM mtcars_table WHERE cyl = 4"
)
dat = dbFetch(rs)
dbClearResult(rs)

print(dat)
summary(dat)
class(dat)


rs = dbSendQuery(conn,
	"select * from P1"
)
dbFetch(rs)
dbClearResult(rs)



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
order by state, county")
dat = dbFetch(rs)
head(dat)
dbClearResult(rs)
dbDisconnect(conn)
