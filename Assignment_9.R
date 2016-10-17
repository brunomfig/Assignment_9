# Packages to be used
library(RSQLite)
library(dplyr)

# ---------- Problem 1 ----------
# 2 Connect to the portal sqlite database
portaldb <- "./data/portal_mammals.sqlite"
portalconn <- dbConnect(drv = SQLite(), dbname = portaldb)

# 3 Table inside the database
dbListTables(portalconn)

# 4 Fields inside the surveys and plots tables
dbListFields(portalconn, "surveys")
dbListFields(portalconn, "plots")

# 5 select and print average hind foot lenght and weight
# - all D. spectabilis on the control plots
q1 <- "SELECT AVG(hindfoot_length), AVG(weight)
      FROM surveys
      JOIN plots
      ON surveys.plot_id = plots.plot_id
      WHERE species_id IS 'DS' AND plot_type IS 'Control'"
dbGetQuery(portalconn, q1)

# - male D. spectabilis on the control plots
q2 <- "SELECT AVG(hindfoot_length), AVG(weight)
      FROM surveys
      JOIN plots
      ON surveys.plot_id = plots.plot_id
      WHERE species_id IS 'DS' AND plot_type IS 'Control' AND sex IS 'M'"
dbGetQuery(portalconn, q2)

# - female D. spectabilis on the control plots
q3 <- "SELECT AVG(hindfoot_length), AVG(weight)
      FROM surveys
      JOIN plots
      ON surveys.plot_id = plots.plot_id
      WHERE species_id IS 'DS' AND plot_type IS 'Control' AND sex IS 'F'"
dbGetQuery(portalconn, q3)

# ---------- Problem 2 ----------
# Data frame species_id, sex, avg_hindfoot_length and avg_weight by species and sex
# using SQL
q4 <- "SELECT species_id, sex, AVG(hindfoot_length), AVG(weight)
      FROM surveys
      WHERE species_id IS NOT NULL AND sex IS NOT NULL
      GROUP BY species_id, sex"
dbGetQuery(portalconn, q4)

# using dplyr
surveys <- tbl(src_sqlite(portaldb), "surveys")
dplyr_avg <- surveys %>%
  group_by(species_id, sex) %>%
  summarise(avg_hindfoot_length = mean(hindfoot_length), avg_weight = mean(weight)) %>%
  filter(!is.na(sex))
avg_sps_df <- data.frame(dplyr_avg)

# ---------- Problem 3 ----------
# Connecting to sql database (Done in problem 1)
# portaldb <- "./data/portal_mammals.sqlite"
# portalconn <- dbConnect(drv = SQLite(), dbname = portaldb)

# Data frame year, species_id and avg_weight
# using SQL
q5 <- "SELECT year, species_id, AVG(weight)
      FROM surveys
      WHERE (species_id = 'DS') OR (species_id = 'OT') OR (species_id = 'PE') OR (species_id = 'PP')
      GROUP BY year, species_id
      ORDER BY species_id"
avgweight_sp_s <- dbGetQuery(portalconn, q5)
print(avgweight_sp_s)

# Include table created above in the sqlite file
dbWriteTable(portalconn, "avgweight_sp_s", avgweight_sp_s, overwrite = TRUE)

# ---------- Problem 4 ----------

