import requests
url = 'https://www.ipea.gov.br/geobr/metadata/metadata_gpkg.csv'
a = requests.get(url,  verify=False).content


# requests.get(url, verify=False)
# 
#         content = requests.get(url).content
