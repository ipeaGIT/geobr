"""Tests for code_muni / code_state filtering via mocked downloads."""

import importlib

import geopandas as gpd
import pytest
from shapely.geometry import Point

from geobr._filter import filter_by_code


@pytest.fixture
def mock_gdf():
    return gpd.GeoDataFrame(
        {
            "code_muni": [3304557, 3550308],
            "abbrev_state": ["RJ", "SP"],
            "code_state": [33, 35],
        },
        geometry=[Point(0, 0), Point(1, 1)],
        crs="EPSG:4674",
    )


def test_read_schools_filter(mock_gdf, monkeypatch):
    mod = importlib.import_module("geobr.read_schools")
    monkeypatch.setattr(
        mod,
        "read_geobr_hybrid",
        lambda *a, **k: filter_by_code(mock_gdf, k.get("code", "all")),
    )
    from geobr import read_schools

    out = read_schools(year=2020, code_muni="RJ")
    assert len(out) == 1


def test_read_conservation_units_filter(mock_gdf, monkeypatch):
    mod = importlib.import_module("geobr.read_conservation_units")
    monkeypatch.setattr(
        mod,
        "read_geobr_hybrid",
        lambda *a, **k: filter_by_code(mock_gdf, k.get("code", "all")),
    )
    from geobr import read_conservation_units

    out = read_conservation_units(date=201909, code_state=33)
    assert len(out) == 1
