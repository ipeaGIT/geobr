import geopandas as gpd
import pytest
from geobr import read_polling_places


def test_read_polling_places():

    gdf = read_polling_places(2024, code_muni="AP")
    assert isinstance(gdf, gpd.geodataframe.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_polling_places(year=9999999)
