import importlib

import geopandas as gpd
import pytest
from unittest.mock import MagicMock

from geobr import read_urban_concentrations


def test_read_urban_concentrations(monkeypatch):
    mod = importlib.import_module("geobr.read_urban_concentrations")
    monkeypatch.setattr(
        mod,
        "read_geobr_hybrid",
        MagicMock(return_value=gpd.GeoDataFrame(geometry=[])),
    )
    assert isinstance(read_urban_concentrations(year=2010), gpd.GeoDataFrame)


def test_read_urban_concentrations_invalid_year():
    with pytest.raises((Exception, ValueError)):
        read_urban_concentrations(year=9999999)
