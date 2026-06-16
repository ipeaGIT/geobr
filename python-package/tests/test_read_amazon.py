import geopandas as gpd
import pytest
from geobr import read_amazon


def test_read_amazon():

    gdf = read_amazon(2024)
    assert isinstance(gdf, gpd.geodataframe.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_amazon(year=9999999)
