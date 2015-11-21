
library(RSQLite)
library(DBI)
library(sqldf)

# connect to the sqlite file
con = dbConnect(RSQLite::SQLite(), dbname="database.sqlite")


# get a list of all tables
alltables = dbListTables(con)
# get the column names
column_names <- dbGetQuery(con, 'PRAGMA table_info(May2015)');
# get the first 100 rows
sample <- dbGetQuery(con,'select * from May2015 limit 100')
# count the areas in the SQLite table
nrow.reddit <- dbGetQuery(con,'select count(*) from May2015')[1,1]

set.seed(5)
sample.indexes <- sample(nrow.reddit, 500000)
sample.indexes <- paste(shQuote(sample.indexes), collapse=", ")
sample.cmd <- paste0("SELECT * FROM May2015 WHERE _ROWID_ in (", sample.indexes, ")")

ptm <- proc.time()
random500K <- dbGetQuery(con, sample.cmd)
proc.time() - ptm

# Create an empty database.
sqldf("ATTACH 'reddit500k.sqlite' AS new")

# Import data frames from Tables into database
sqldf("CREATE TABLE May2015 AS SELECT * FROM random500K", dbname = "reddit500k.sqlite")

# Processing times.
# 5      = 0.7
# 50     = 1.0
# 500    = 5.6
# 5000   = 42.4  
# 50000  = 212.5
# 500000 = 326.5
x <- c(5,50,500,5000,50000, 500000)
y <- c(0.7, 1.0, 5.6, 42.4, 212.5, 326.5)
plot(x,y)
326/60
