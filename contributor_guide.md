under construction.... please drop by latter. :)

# Become a contributor to **geobr** <img align="right" src="man/figures/geobr_logo_b.png" alt="logo" width="160"> <img align="right" src="man/figures/geobr_logo_y.png" alt="logo" width="160">

If you would like to contribute to **geobr**, please open a [Github issue](https://github.com/ipeaGIT/geobr/issues) with your suggestion of ***function*** or ***dataset*** you would like to see in the package. Keep in mind that, as a rule, the package only includes geospatial data sets with national spatial coverage that are created/managed by govermental institutions and which are publicly available. 

The inclusion of every dataset in geobr follows a three-step process, as follows:

### Step 1. Data preparation

In the first step, the contributor should write an `R` script that will prepare the raw original data set to be used in th geobr. This script should (1) download the raw data from the original website source, (2) clean the data harmonizing column names*, (3) ensure the data uses spatial projection EPSG 4674, (4) ensure every string column is `as.character` with UTF-8 encoding, (5) fix eventual topology issues in the data, and (6) save the data in `.rds` format. 

This script can use any `R` package, but it needs to be 100% reproducible. There are various preparation scripts in the [prep_data directory](https://github.com/ipeaGIT/geobr/blob/master/prep_data) that you can use as a reference. Mind you though that every data set has its own particularities so every prep_ script will be a little bit different accordingly.

'*' Name conventions


### Step 2. Data validation and upload

Once the prep_ script is ready, the geobr team will test the script and validate the data output. If everything works fine, the geobr team will upload the data to our servers so it will become available for download.


### Step 3. Download an test functions


The contributor writes the package function that will be used to download the proposed data










