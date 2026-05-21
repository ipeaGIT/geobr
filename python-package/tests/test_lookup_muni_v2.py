import importlib

import pytest
import geopandas as gpd
from shapely.geometry import Point

from geobr.lookup_muni import lookup_muni


@pytest.fixture
def mock_seat():
    return gpd.GeoDataFrame(
        {
            "code_muni": [3304557, 3550308],
            "name_muni": ["Rio de Janeiro", "São Paulo"],
            "abbrev_state": ["RJ", "SP"],
            "code_state": [33, 35],
        },
        geometry=[Point(0, 0)] * 2,
        crs="EPSG:4674",
    )


def _patch_seat(monkeypatch, mock_seat):
    mod = importlib.import_module("geobr.read_municipal_seat")
    monkeypatch.setattr(mod, "read_municipal_seat", lambda **k: mock_seat)


def test_mutual_exclusion(mock_seat, monkeypatch):
    _patch_seat(monkeypatch, mock_seat)
    with pytest.raises(ValueError, match="cannot be used"):
        lookup_muni(name_muni="Rio", code_muni=3304557)


def test_lookup_by_code(mock_seat, monkeypatch):
    _patch_seat(monkeypatch, mock_seat)
    out = lookup_muni(code_muni=3304557, year=2010)
    assert len(out) == 1
    assert out.iloc[0]["name_muni"].lower() == "rio de janeiro"


def test_lookup_requires_input(mock_seat, monkeypatch):
    _patch_seat(monkeypatch, mock_seat)
    with pytest.raises(ValueError):
        lookup_muni(year=2010, name_muni=None, code_muni=None)
