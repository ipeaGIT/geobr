# update metadata.csv

library(qdapRegex)
library(data.table)
library(pbapply)
library(dplyr)
library(piggyback)




######### Step 1 - create github release where data will be uploaded to ----------------------
# https://docs.ropensci.org/piggyback/articles/intro.html
# https://github.com/settings/tokens
# https://usethis.r-lib.org/articles/git-credentials.html

usethis::edit_r_environ() # ttt
gitcreds::gitcreds_set()


# create new release
pb_new_release("ipeaGIT/geobr",
               "v1.7.0")


######### Step 2 - create/update metadata table ( geo/ano/arquivo) ----------------------

# create empty metadata
  metadata <- data.frame(matrix(ncol = 5, nrow = 0))
  colnames(metadata) <- c("geo","year","code","download_path","code_abbrev")

# list all data files available in the geobr package
  geo = list.files("//storage1/geobr/data_gpkg")

  # populate the metadata table
  for (a in geo) {    # a="census_tract"
    ano=list.files(paste("//storage1/geobr/data_gpkg",a,sep="/"))
    for (b in ano) { # b=2000
      estado=list.files(paste("//storage1/geobr/data_gpkg",a,b,sep="/"))
      for (c in estado) { #c="Urbano"   c= "AC.gpkg"
        if (c=="Urbano"|c=="Rural"){
          estado2=list.files(paste("//storage1/geobr/data_gpkg",a,b,c,sep="/"))
          for (d in estado2) { #d=estado2[1]
            if (c=="Urbano") {
              metadata[nrow(metadata) + 1,] = list(a,b,paste0("U",substr(d, 1, 2)),paste("https://www.ipea.gov.br/geobr/data_gpkg",a,b,c,d,sep="/"))
            }
            if (c=="Rural") {
              metadata[nrow(metadata) + 1,] = list(a,b,paste0("R",substr(d, 1, 2)),paste("https://www.ipea.gov.br/geobr/data_gpkg",a,b,c,d,sep="/"))
            }
          }
        } else {
        metadata[nrow(metadata) + 1,] = list(a,b,substr(c, 1, 2),paste("https://www.ipea.gov.br/geobr/data_gpkg",a,b,c,sep="/"))}
      }
    }
  }


 # get code abbreviations
  library(data.table)
  setDT(metadata)
  metadata[ grepl("11", substr(code, 1, 3)), code_abbrev :=	"RO" ]
  metadata[ grepl("12", substr(code, 1, 3)), code_abbrev :=	"AC" ]
  metadata[ grepl("13", substr(code, 1, 3)), code_abbrev :=	"AM" ]
  metadata[ grepl("14", substr(code, 1, 3)), code_abbrev :=	"RR" ]
  metadata[ grepl("15", substr(code, 1, 3)), code_abbrev :=	"PA" ]
  metadata[ grepl("16", substr(code, 1, 3)), code_abbrev :=	"AP" ]
  metadata[ grepl("17", substr(code, 1, 3)), code_abbrev :=	"TO" ]
  metadata[ grepl("21", substr(code, 1, 3)), code_abbrev :=	"MA" ]
  metadata[ grepl("22", substr(code, 1, 3)), code_abbrev :=	"PI" ]
  metadata[ grepl("23", substr(code, 1, 3)), code_abbrev :=	"CE" ]
  metadata[ grepl("24", substr(code, 1, 3)), code_abbrev :=	"RN" ]
  metadata[ grepl("25", substr(code, 1, 3)), code_abbrev :=	"PB" ]
  metadata[ grepl("26", substr(code, 1, 3)), code_abbrev :=	"PE" ]
  metadata[ grepl("27", substr(code, 1, 3)), code_abbrev :=	"AL" ]
  metadata[ grepl("28", substr(code, 1, 3)), code_abbrev :=	"SE" ]
  metadata[ grepl("29", substr(code, 1, 3)), code_abbrev :=	"BA" ]
  metadata[ grepl("31", substr(code, 1, 3)), code_abbrev :=	"MG" ]
  metadata[ grepl("32", substr(code, 1, 3)), code_abbrev :=	"ES" ]
  metadata[ grepl("33", substr(code, 1, 3)), code_abbrev :=	"RJ" ]
  metadata[ grepl("35", substr(code, 1, 3)), code_abbrev :=	"SP" ]
  metadata[ grepl("41", substr(code, 1, 3)), code_abbrev :=	"PR" ]
  metadata[ grepl("42", substr(code, 1, 3)), code_abbrev :=	"SC" ]
  metadata[ grepl("43", substr(code, 1, 3)), code_abbrev :=	"RS" ]
  metadata[ grepl("50", substr(code, 1, 3)), code_abbrev :=	"MS" ]
  metadata[ grepl("51", substr(code, 1, 3)), code_abbrev :=	"MT" ]
  metadata[ grepl("52", substr(code, 1, 3)), code_abbrev :=	"GO" ]
  metadata[ grepl("53", substr(code, 1, 3)), code_abbrev :=	"DF" ]


  # # add file name
  # metadata[, file_name := basename(download_path)]

  # order by file_name
  metadata <- unique(metadata)
  # metadata <- metadata[order(file_name)]
  # head(metadata)


  metadata[geo=='semiarid']

a <- metadata[geo=='health_facilities']


######### Step 3 -  upload data to github ----------------------
all_files <- list.files("//storage1/geobr/data_gpkg",  full.names = T, recursive = T)

  all_files <- all_files[all_files %like% 'semiarid']
  # all_files <- all_files[all_files %like% '2022']

# upload data
piggyback::pb_upload(all_files,
                     "ipeaGIT/geobr",
                     "v1.7.0"
                     #,.token = ttt
                     )

#' https://docs.github.com/rest/overview/resources-in-the-rest-api#rate-limiting


# get url to all data files on github repo release
github_liks <- pb_download_url(repo = "ipeaGIT/geobr",
                               tag = "v1.7.0")
# names of uploaded files
uploaded <- basename(github_liks)

# check which files have not been uploaded yet
not_yet <- setdiff(basename(all_files), uploaded)
to_go <- all_files[basename(all_files) %in% not_yet]

# upload data
piggyback::pb_upload(to_go,
                     "ipeaGIT/geobr",
                     "v1.7.0")


# ######### Etapa 4 - add github url paths ----------------------
#
# # ignore urls to metadata and package binaries
# github_liks <- github_liks[ ! (github_liks %like% 'metadata.csv') ]
# github_liks <- github_liks[ ! (github_liks %like% '.tar.gz') ]
#
# # sort
# github_liks[order(github_liks)] <- github_liks[order(github_liks)]
#
# # add url paths from github to metadata
# metadata[, download_path2 := github_liks ]
#
#
# ### check if both url likns correspond to the same files
# metadata[, file_name2 := basename(download_path2)]
# metadata[, check := file_name == file_name2]
#
# sum(metadata$check) == nrow(metadata)
# metadata$check <- NULL
# metadata$file_name <- NULL




######### Step 5 - check and save metadata ----------------------

  # reorder columns
  setcolorder(metadata, c("geo", "year", "code", "download_path", "code_abbrev"))

  # to avoid conflict with data.table
  metadata <- as.data.frame(metadata)
  table(metadata$geo)
  table(metadata$year)

  subset(metadata, geo == 'semiarid')
  subset(metadata, geo == 'urban_concentrations')
  subset(metadata, geo == 'meso_region')[1:4,]
  subset(metadata, geo == 'micro_region')[1:4,]
  subset(metadata, geo == 'census_tract' & year==2020)
  subset(metadata, year==2020)

# save updated metadata table
  # readr::write_csv(metadata,"//storage1/geobr/metadata/metadata_1.7.0_gpkg.csv")

  # upload updated metadata table github
  piggyback::pb_upload("//storage1/geobr/metadata/metadata_1.7.0_gpkg.csv",
                       "ipeaGIT/geobr",
                       "v1.7.0"
                     #  , .token = gh::gh_token()
                       )





