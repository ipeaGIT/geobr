import importlib

import pandas as pd
import pytest
import geopandas as gpd
from shapely.geometry import Point

from geobr.lookup_muni import lookup_muni


@pytest.fixture
def mock_lookup_table():
    return gpd.GeoDataFrame(
        {
            "code_muni": [2304400, 3304557],
            "name_muni": ["Fortaleza", "Rio de Janeiro"],
            "abbrev_state": ["CE", "RJ"],
            "code_state": [23, 33],
        },
        geometry=[Point(0, 0), Point(1, 1)],
        crs="EPSG:4674",
    )


def test_lookup_muni_by_code(mock_lookup_table, monkeypatch):
    mod = importlib.import_module("geobr.read_municipal_seat")
    monkeypatch.setattr(mod, "read_municipal_seat", lambda **k: mock_lookup_table)
    out = lookup_muni(code_muni=2304400, year=2010)
    assert isinstance(out, pd.DataFrame)
    assert len(out) == 1


def test_lookup_muni_all(mock_lookup_table, monkeypatch):
    mod = importlib.import_module("geobr.read_municipal_seat")
    monkeypatch.setattr(mod, "read_municipal_seat", lambda **k: mock_lookup_table)
    out = lookup_muni(code_muni="all", year=2010)
    assert len(out) == len(mock_lookup_table)


def test_lookup_muni_mutual_exclusion(mock_lookup_table, monkeypatch):
    mod = importlib.import_module("geobr.read_municipal_seat")
    monkeypatch.setattr(mod, "read_municipal_seat", lambda **k: mock_lookup_table)
    with pytest.raises(ValueError):
        lookup_muni(name_muni="Fortaleza", code_muni=2304400, year=2010)
