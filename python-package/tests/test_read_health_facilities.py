import geopandas as gpd
import pytest
from geobr import read_health_facilities


def test_read_health_facilities(monkeypatch):

    gdf = read_health_facilities(date=202604, code_muni="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_health_facilities(year=9999999)
