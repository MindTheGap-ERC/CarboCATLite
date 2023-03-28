## Generate sea level curve for scenario B from Miller et al 2020

# Import data on sea level from Miller et al. 2020
# https://doi.org/10.1126/sciadv.aaz1346
# Extracted from supp. Info table S1
data_imported <- read.csv(file = "Rcode/miller_et_al_2020/Miller_et_al_2020_SL_from_table_S1.csv")

# extract data necessary to cover Pleistocene
rel_ind = 1:min(which(data_imported$Age_.ka.>2580))

sea_level_miller_raw <- data.frame(
  age_kyr = data_imported$Age_.ka.[rel_ind],
  sea_level_m = data_imported$Sea_level_.m.[rel_ind]
)

# plot temporal resolution
hist(
  x = diff(sea_level_miller_raw$age_kyr),
  xlab = "Temporal Resolution [kyr]"
)
mean(diff(sea_level_miller_raw$age_kyr))
median(diff(sea_level_miller_raw$age_kyr))

# interpolate Sea level on 1 kyr res until end of Pleistocene
sea_level_interpol_1kyr <- approx(
  x = sea_level_miller_raw$age_kyr,
  y = sea_level_miller_raw$sea_level_m,
  xout = seq(
    from = 0,
    to = 2580,
    by = 1
  )
)



# convert age to time and normalize to mean eustatic sea level 0

sl_for_carbocat <- data.frame(
  time_kyr = seq(
    from = 0,
    to = 2580,
    by = 1
  ),
  sea_level_m = rev(sea_level_interpol_1kyr$y) - mean(rev(sea_level_interpol_1kyr$y)) #normalize to 0
)

plot(
  x = sl_for_carbocat$time_kyr,
  y = sl_for_carbocat$sea_level_m,
  type = "l"
)

## export data

write.table(
  x = sl_for_carbocat$sea_level_m,
  file = "params/DbPlatform/sea_level_scenarioB.txt",
  col.names = FALSE,
  row.names = FALSE
)
