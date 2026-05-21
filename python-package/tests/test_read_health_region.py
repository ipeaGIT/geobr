import importlib

import geopandas as gpd
import pytest

from geobr import read_health_region


def test_read_health_region(monkeypatch):
    mod = importlib.import_module("geobr.read_health_region")
    monkeypatch.setattr(
        mod, "read_geobr_hybrid", lambda *a, **k: gpd.GeoDataFrame(geometry=[])
    )
    assert isinstance(read_health_region(year=2013), gpd.GeoDataFrame)


def test_read_health_region_macro(monkeypatch):
    mod = importlib.import_module("geobr.read_health_region")
    gdf = gpd.GeoDataFrame(
        {
            "code_muni": [1, 2],
            "code_health_region": [1, 1],
            "name_health_region": ["R1", "R1"],
            "code_health_macroregion": [10, 10],
            "abbrev_state": ["RJ", "RJ"],
            "code_state": [33, 33],
        },
        geometry=[None, None],
        crs="EPSG:4674",
    )
    monkeypatch.setattr(mod, "read_geobr_hybrid", lambda *a, **k: gdf)
    with pytest.warns(DeprecationWarning):
        out = read_health_region(year=2013, macro=True)
    assert isinstance(out, gpd.GeoDataFrame)


def test_read_health_region_invalid_year():
    with pytest.raises((Exception, ValueError)):
        read_health_region(year=9999999)
