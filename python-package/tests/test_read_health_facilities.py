import importlib

import geopandas as gpd
import pytest

from geobr import read_health_facilities


def test_read_health_facilities(monkeypatch):
    mod = importlib.import_module("geobr.read_health_facilities")
    monkeypatch.setattr(
        mod, "read_geobr_hybrid", lambda *a, **k: gpd.GeoDataFrame(geometry=[])
    )
    df = read_health_facilities(date=202303)
    assert isinstance(df, gpd.GeoDataFrame)


def test_read_health_facilities_invalid_year():
    with pytest.raises((Exception, ValueError)):
        read_health_facilities(date=9999999)
