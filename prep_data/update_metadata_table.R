# update metadata.rds


# create empty metadata 
  metadata <- data.frame(matrix(ncol = 5, nrow = 0))
  colnames(metadata) <- c("geo","year","code","download_path","code_abrev")

# list all data files available in the geobr package
  geo=list.files("//storage3/geobr/data")
  # geo<-"setor_censitario"
# populate the metadata table
  for (a in geo) {
    ano=list.files(paste("//storage3/geobr/data",a,sep="/"))
    ano=ano[!grepl("Urbano|Rural", ano)]
    for (b in ano) {
      estado=list.files(paste("//storage3/geobr/data",a,b,sep="/"))
      for (c in estado) {
        metadata[nrow(metadata) + 1,] = list(a,b,substr(c, 1, 2),paste("http://www.ipea.gov.br/geobr/data",a,b,c,sep="/"))
      }
    }
  }

  for (a in geo) {
    ano=list.files(paste("//storage3/geobr/data",a,sep="/"))
    ano=ano[grepl("Urbano", ano)]
    ano=list.files(paste("//storage3/geobr/data",a,ano,sep="/"))
    for (b in ano) {
      estado=list.files(paste("//storage3/geobr/data",a,"Urbano",b,sep="/"))
      for (c in estado) {
        metadata[nrow(metadata) + 1,] = list(a,b,paste0("U",substr(c, 1, 2)),paste("http://www.ipea.gov.br/geobr/data",a,"Urbano",b,c,sep="/"))
      }
    }
  }
  
  for (a in geo) {
    ano=list.files(paste("//storage3/geobr/data",a,sep="/"))
    ano=ano[grepl("Rural", ano)]
    ano=list.files(paste("//storage3/geobr/data",a,ano,sep="/"))
    for (b in ano) {
      estado=list.files(paste("//storage3/geobr/data",a,"Rural",b,sep="/"))
      for (c in estado) {
        metadata[nrow(metadata) + 1,] = list(a,b,paste0("R",substr(c, 1, 2)),paste("http://www.ipea.gov.br/geobr/data",a,"Rural",b,c,sep="/"))
      }
    }
  }
  
  
# get code abbreviations
  library(data.table)
  setDT(metadata)
  metadata[ grepl("11", code), code_abrev :=	"RO" ]
  metadata[ grepl("12", code), code_abrev :=	"AC" ]
  metadata[ grepl("13", code), code_abrev :=	"AM" ]
  metadata[ grepl("14", code), code_abrev :=	"RR" ]
  metadata[ grepl("15", code), code_abrev :=	"PA" ]
  metadata[ grepl("16", code), code_abrev :=	"AP" ]
  metadata[ grepl("17", code), code_abrev :=	"TO" ]
  metadata[ grepl("21", code), code_abrev :=	"MA" ]
  metadata[ grepl("22", code), code_abrev :=	"PI" ]
  metadata[ grepl("23", code), code_abrev :=	"CE" ]
  metadata[ grepl("24", code), code_abrev :=	"RN" ]
  metadata[ grepl("25", code), code_abrev :=	"PB" ]
  metadata[ grepl("26", code), code_abrev :=	"PE" ]
  metadata[ grepl("27", code), code_abrev :=	"AL" ]
  metadata[ grepl("28", code), code_abrev :=	"SE" ]
  metadata[ grepl("29", code), code_abrev :=	"BA" ]
  metadata[ grepl("31", code), code_abrev :=	"MG" ]
  metadata[ grepl("32", code), code_abrev :=	"ES" ]
  metadata[ grepl("33", code), code_abrev :=	"RJ" ]
  metadata[ grepl("35", code), code_abrev :=	"SP" ]
  metadata[ grepl("41", code), code_abrev :=	"PR" ]
  metadata[ grepl("42", code), code_abrev :=	"SC" ]
  metadata[ grepl("43", code), code_abrev :=	"RS" ]
  metadata[ grepl("50", code), code_abrev :=	"MS" ]
  metadata[ grepl("51", code), code_abrev :=	"MT" ]
  metadata[ grepl("52", code), code_abrev :=	"GO" ]
  metadata[ grepl("53", code), code_abrev :=	"DF" ]

# to avoid conflict with data.table
  metadata <- as.data.frame(metadata)
  table(metadata$geo)
  table(metadata$year)
  
# save updated metadata table
  # readr::write_rds(metadata,"//storage3/geobr/metadata/metadata.rds", compress = "gz")

