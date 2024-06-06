
####### Load Support functions to use in the preprocessing of the data  ------------------------------

source("./prep_data/prep_functions.R")
source("./prep_data/amc_algorithm/_Crosswalk_main.R")



##### list o all years available  ------------------------------
years_available <- c(1872,1900,1911,1920,1933,1940,1950,1960,1970,1980,1991,2000,2010,2020)

# get combinations
all_combinations <- expand.grid(years_available, years_available) %>% as.data.frame()
names(all_combinations) <- c('start_year', 'end_year')
all_combinations <- subset(all_combinations, start_year < end_year)




####### Function prep AMC ------------------------------

prep_amc <- function(i){

  table_amc(startyear = all_combinations$start_year[i],
            endyear = all_combinations$end_year[i]
            )
}




# apply function in parallel
future::plan("multisession")
furrr::future_map(.x = 1:nrow(all_combinations),
                  .f = prep_amc,
                  .progress = TRUE
                  )


