import geopandas as gpd
import pytest
from geobr import read_country


def test_read_country():

    gdf = read_country(2025)
    assert isinstance(gdf, gpd.geodataframe.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_country(year=9999999)
        read_country()
