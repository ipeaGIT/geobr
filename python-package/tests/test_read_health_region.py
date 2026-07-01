import importlib

import geopandas as gpd
import pytest

from geobr import read_health_region


def test_read_health_region():
    gdf = read_health_region(year=2025, code_state="AP")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

    with pytest.raises(Exception):
        read_health_region(year=9999999)


def test_read_health_region_macro():
    with pytest.warns(DeprecationWarning):
        gdf = read_health_region(year=2025, macro=True)
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty


def test_read_health_region_micro():
    gdf = read_health_region(year=2025, code_state="AP", geometry_level="micro")
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty


def test_read_health_region_invalid_geometry():
    with pytest.raises(ValueError, match="must be one of"):
        read_health_region(year=2025, code_state="AP", geometry_level="invalid")
