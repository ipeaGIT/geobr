import importlib
import warnings

import geopandas as gpd
import pytest
from shapely.geometry import Point

from geobr.read_health_region import read_health_region


@pytest.fixture
def health_gdf():
    return gpd.GeoDataFrame(
        {
            "code_muni": [3304557, 3304558],
            "code_health_region": [1, 1],
            "name_health_region": ["R1", "R1"],
            "code_health_macroregion": [10, 10],
            "abbrev_state": ["RJ", "RJ"],
            "code_state": [33, 33],
        },
        geometry=[Point(0, 0), Point(1, 1)],
        crs="EPSG:4674",
    )


def test_geometry_level_micro(health_gdf, monkeypatch):
    mod = importlib.import_module("geobr.read_health_region")
    monkeypatch.setattr(mod, "read_geobr_hybrid", lambda *a, **k: health_gdf)
    out = read_health_region(year=2024, geometry_level="micro")
    assert len(out) >= 1


def test_deprecation_macro(health_gdf, monkeypatch):
    mod = importlib.import_module("geobr.read_health_region")
    monkeypatch.setattr(mod, "read_geobr_hybrid", lambda *a, **k: health_gdf)
    with pytest.warns(DeprecationWarning):
        read_health_region(year=2024, macro=True)
