import geopandas as gpd
import pytest
from geobr import read_favela


def test_read_favela():

    gdf = read_favela(2022, code_muni="AP")
    assert isinstance(gdf, gpd.geodataframe.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_favela(year=9999999)
