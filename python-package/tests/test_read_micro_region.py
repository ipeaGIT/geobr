import geopandas as gpd
import pytest
from geobr import read_micro_region


def test_read_micro_region():

    gdf = read_micro_region(year=2022, code_micro="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_micro_region(year=9999999)
        read_micro_region(year=2022, code_micro=9999999)
