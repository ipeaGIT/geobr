from geobr import read_mining_processes
import geopandas as gpd

# Testa download dos dados
print("Baixando dados de processos minerários...")
gdf = read_mining_processes()

# Verifica se é um GeoDataFrame
print("\nTipo do objeto retornado:", type(gdf))

# Mostra informações básicas
print("\nInformações do DataFrame:")
print(gdf.info())

# Mostra primeiras linhas
print("\nPrimeiras linhas dos dados:")
print(gdf.head())

# Mostra colunas disponíveis
print("\nColunas disponíveis:")
print(gdf.columns.tolist())

# Mostra algumas estatísticas básicas
print("\nQuantidade de processos por fase:")
print(gdf['FASE'].value_counts())

print("\nQuantidade de processos por UF:")
print(gdf['UF'].value_counts())
