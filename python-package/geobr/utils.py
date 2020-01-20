import requests

def download_metadata():

    metadata_url = 'http://www.ipea.gov.br/geobr/metadata/metadata.rds'

    metadata = requests.get(metadata_url)

    # return pd.DataFrame(metadata)

    return 'metadata'

def get_metadata(geo):

    metadata = download_metadata()

    # select metadata based on geo
    # ...

    return 'metadata_selected_geo'