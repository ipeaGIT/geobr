import importlib

import geopandas as gpd
import pytest
from unittest.mock import MagicMock

from geobr import read_pop_arrangements


def test_read_pop_arrangements(monkeypatch):
    mod = importlib.import_module("geobr.read_pop_arrangements")
    monkeypatch.setattr(
        mod,
        "read_geobr_hybrid",
        MagicMock(return_value=gpd.GeoDataFrame(geometry=[])),
    )
    assert isinstance(read_pop_arrangements(year=2010), gpd.GeoDataFrame)


def test_read_pop_arrangements_invalid_year():
    with pytest.raises((Exception, ValueError)):
        read_pop_arrangements(year=9999999)
