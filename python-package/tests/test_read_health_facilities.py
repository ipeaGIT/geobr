import geopandas as gpd
import pytest
from geobr import read_health_facilities


def test_read_health_facilities():

    df = read_health_facilities()

    assert isinstance(df, gpd.geodataframe.GeoDataFrame)

    assert len(df) == 360177

    with pytest.raises(Exception):
        read_health_facilities(year=9999999)
