# update metadata.rds


######### Etapa 1 - bases padrao ( geo/ano/arquivo) ----------------------



# create empty metadata
metadata <- data.frame(matrix(ncol = 5, nrow = 0))
colnames(metadata) <- c("geo","year","code","download_path","code_abrev")

# list all data files available in the geobr package
geo=list.files("//storage1/geobr/data_gpkg")

# populate the metadata table
for (a in geo) {    # a="setor_censitario"
  ano=list.files(paste("//storage1/geobr/data_gpkg",a,sep="/"))
  for (b in ano) { # b=2000
    estado=list.files(paste("//storage1/geobr/data_gpkg",a,b,sep="/"))
    for (c in estado) { #c="Urbano"
      if (c=="Urbano"|c=="Rural"){
        estado2=list.files(paste("//storage1/geobr/data_gpkg",a,b,c,sep="/"))
        for (d in estado2) { #d=estado2[1]
          if (c=="Urbano") {
            metadata[nrow(metadata) + 1,] = list(a,b,paste0("U",substr(d, 1, 2)),paste("http://www.ipea.gov.br/geobr/data_gpkg",a,b,c,d,sep="/"))
          }
          if (c=="Rural") {
            metadata[nrow(metadata) + 1,] = list(a,b,paste0("R",substr(d, 1, 2)),paste("http://www.ipea.gov.br/geobr/data_gpkg",a,b,c,d,sep="/"))
          }
        }
      } else {
        metadata[nrow(metadata) + 1,] = list(a,b,substr(c, 1, 2),paste("http://www.ipea.gov.br/geobr/data_gpkg",a,b,c,sep="/"))}
    }
  }
}


# table(metadata$geo)
# temp_ano <- subset(metadata, geo=="health_region")
# temp_ano <- subset(metadata, geo=="country")



# get code abbreviations
library(data.table)
setDT(metadata)
metadata[ grepl("11", substr(code, 1, 3)), code_abrev :=	"RO" ]
metadata[ grepl("12", substr(code, 1, 3)), code_abrev :=	"AC" ]
metadata[ grepl("13", substr(code, 1, 3)), code_abrev :=	"AM" ]
metadata[ grepl("14", substr(code, 1, 3)), code_abrev :=	"RR" ]
metadata[ grepl("15", substr(code, 1, 3)), code_abrev :=	"PA" ]
metadata[ grepl("16", substr(code, 1, 3)), code_abrev :=	"AP" ]
metadata[ grepl("17", substr(code, 1, 3)), code_abrev :=	"TO" ]
metadata[ grepl("21", substr(code, 1, 3)), code_abrev :=	"MA" ]
metadata[ grepl("22", substr(code, 1, 3)), code_abrev :=	"PI" ]
metadata[ grepl("23", substr(code, 1, 3)), code_abrev :=	"CE" ]
metadata[ grepl("24", substr(code, 1, 3)), code_abrev :=	"RN" ]
metadata[ grepl("25", substr(code, 1, 3)), code_abrev :=	"PB" ]
metadata[ grepl("26", substr(code, 1, 3)), code_abrev :=	"PE" ]
metadata[ grepl("27", substr(code, 1, 3)), code_abrev :=	"AL" ]
metadata[ grepl("28", substr(code, 1, 3)), code_abrev :=	"SE" ]
metadata[ grepl("29", substr(code, 1, 3)), code_abrev :=	"BA" ]
metadata[ grepl("31", substr(code, 1, 3)), code_abrev :=	"MG" ]
metadata[ grepl("32", substr(code, 1, 3)), code_abrev :=	"ES" ]
metadata[ grepl("33", substr(code, 1, 3)), code_abrev :=	"RJ" ]
metadata[ grepl("35", substr(code, 1, 3)), code_abrev :=	"SP" ]
metadata[ grepl("41", substr(code, 1, 3)), code_abrev :=	"PR" ]
metadata[ grepl("42", substr(code, 1, 3)), code_abrev :=	"SC" ]
metadata[ grepl("43", substr(code, 1, 3)), code_abrev :=	"RS" ]
metadata[ grepl("50", substr(code, 1, 3)), code_abrev :=	"MS" ]
metadata[ grepl("51", substr(code, 1, 3)), code_abrev :=	"MT" ]
metadata[ grepl("52", substr(code, 1, 3)), code_abrev :=	"GO" ]
metadata[ grepl("53", substr(code, 1, 3)), code_abrev :=	"DF" ]

# to avoid conflict with data.table
metadata <- as.data.frame(metadata)
table(metadata$geo)
table(metadata$year)

subset(metadata, geo == 'health_region')

# save updated metadata table
# data.table::fwrite(metadata,"//storage1/geobr/metadata/metadata_gpkg.csv")

