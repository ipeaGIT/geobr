import geopandas as gpd
import pytest
from geobr import read_schools

def test_read_schools():

    gdf = read_schools(year=2025, code_muni="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_schools(year=9999999)
