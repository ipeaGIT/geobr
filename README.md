# geobr

**geobr** is an R package that allows users to easily access shapefiles of the Brazilian Institute of Geography and Statistics (IBGE). The package includes a wide set of geographic datasets as *simple features*, availabe at various geographic scales and for various years (see detailed list below):


## Available datasets:

|Recorte|Anos|Fonte|Incluido no pacote?| Função de leitura|
|-----|-----|-----|-----|-----|
| Brasil | ... | ... | ... | ... |
| UFs | ... | ... | ... | ... |
| Macro região | ... | ... | ... | ... |
| Meso região | ... | ... | ... | ... |
| Micro região | ... | ... | ... | ... |
| Município | 2000, 2001, 2005, 2007, 2010, 2013, 2014, 2015 | [IBGE](https://mapas.ibge.gov.br/bases-e-referenciais/bases-cartograficas/malhas-digitais.html) | ... | ... | 
| Área de ponderação | 2010 | [IBGE](ftp://geoftp.ibge.gov.br/recortes_para_fins_estatisticos/malha_de_areas_de_ponderacao/) | ... | ... |
| Setor Censitário | 2000, 2007, 2010 | [IBGE](https://mapas.ibge.gov.br/bases-e-referenciais/bases-cartograficas/malhas-digitais.html) | ... | ... |




## Future development

|Recorte|Anos|Fonte|Incluido no pacote?| Função de leitura|
|-----|-----|-----|-----|-----|
| Regioes Metropolitanas | ... | ... | ... | ... |
| AMC* de municípios | ... | ... | ... | ... |
| AMC* de microregiões | ... | ... | ... | ... |
| AMC* de setores censitários | ... | ... | ... | ... |
| Área urbanizada | 2005, 2015 | [IBGE](https://www.ibge.gov.br/geociencias-novoportal/cartas-e-mapas/redes-geograficas/15789-areas-urbanizadas.html) | ... | ... |
| Áreas de risco | 2010 | [IBGE/Cemaden](https://www.ibge.gov.br/geociencias-novoportal/organizacao-do-territorio/tipologias-do-territorio/21538-populacao-em-areas-de-risco-no-brasil.html?=&t=downloads) | ... | ... |
| ... | ... | ... | ... | ... |
| ... | ... | ... | ... | ... |

'*' AMC - áreas mínimas comparáveis

Outros arquivos e recortes estão disponiveis em [ftp://geoftp.ibge.gov.br/](ftp://geoftp.ibge.gov.br/).


### Related projects
As of today, there are two other packges in R with similar functionalities. These are the packages [simplefeaturesbr](https://github.com/RobertMyles/simplefeaturesbr) and [brazilmaps](https://cran.r-project.org/web/packages/brazilmaps/brazilmaps.pdf). The **geobr** package has a few advantages when compared to these packages that include, for example:
- Access to a wider set of shapefiles, including not only country, states and municipalities, but also macro-, me- and micro-regions, sampling areas, census tracts, urbanized areas etc etc
- Access to shape files with updated geometries across various years
- Harmonazied attributes and geographic projections across geographies and years







