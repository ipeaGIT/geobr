# update metadata.rds


# create empty metadata 
  metadata <- data.frame(matrix(ncol = 4, nrow = 0))
  colnames(indice) <- c("geo","year","code","code_abrev","download_path")

# list all data files available in the geobr package
  geo=list.files("//storage3/geobr/data")
  
# populate the metadata table
  for (a in geo) {
    ano=list.files(paste("//storage3/geobr/data",a,sep="/"))
    for (b in ano) {
      estado=list.files(paste("//storage3/geobr/data",a,b,sep="/"))
      for (c in estado) {
        indice[nrow(indice) + 1,] = list(a,b,substr(c, 1, 2),paste("http://www.ipea.gov.br/geobr/data",a,b,c,sep="/"))
      }
    }
  }

# get code abbreviations
  setDT(metadata)
  metadata[ code== 11, code_abrev :=	"RO" ]
  metadata[ code== 12, code_abrev :=	"AC" ]
  metadata[ code== 13, code_abrev :=	"AM" ]
  metadata[ code== 14, code_abrev :=	"RR" ]
  metadata[ code== 15, code_abrev :=	"PA" ]
  metadata[ code== 16, code_abrev :=	"AP" ]
  metadata[ code== 17, code_abrev :=	"TO" ]
  metadata[ code== 21, code_abrev :=	"MA" ]
  metadata[ code== 22, code_abrev :=	"PI" ]
  metadata[ code== 23, code_abrev :=	"CE" ]
  metadata[ code== 24, code_abrev :=	"RN" ]
  metadata[ code== 25, code_abrev :=	"PB" ]
  metadata[ code== 26, code_abrev :=	"PE" ]
  metadata[ code== 27, code_abrev :=	"AL" ]
  metadata[ code== 28, code_abrev :=	"SE" ]
  metadata[ code== 29, code_abrev :=	"BA" ]
  metadata[ code== 31, code_abrev :=	"MG" ]
  metadata[ code== 32, code_abrev :=	"ES" ]
  metadata[ code== 33, code_abrev :=	"RJ" ]
  metadata[ code== 35, code_abrev :=	"SP" ]
  metadata[ code== 41, code_abrev :=	"PR" ]
  metadata[ code== 42, code_abrev :=	"SC" ]
  metadata[ code== 43, code_abrev :=	"RS" ]
  metadata[ code== 50, code_abrev :=	"MS" ]
  metadata[ code== 51, code_abrev :=	"MT" ]
  metadata[ code== 52, code_abrev :=	"GO" ]
  metadata[ code== 53, code_abrev :=	"DF" ]

  
# save updated metadata table
  # writeRDS(metadata,"//storage3/geobr/metadata/metadata.rds")

