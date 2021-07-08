import geopandas as gpd
import pytest
from geobr import read_comparable_areas


def test_read_comparable_areas():

    assert isinstance(read_comparable_areas(), gpd.geodataframe.GeoDataFrame)

    with pytest.raises(Exception):
        read_comparable_areas(year=9999999)
        read_comparable_areas(12323423, 2010)

    assert isinstance(read_comparable_areas(2000, 2010), gpd.geodataframe.GeoDataFrame)
