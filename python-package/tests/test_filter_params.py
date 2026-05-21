"""Tests for code filtering through the v2 read pipeline."""

import geopandas as gpd
import pandas as pd
import pytest
from shapely.geometry import Point

from geobr.utils import read_geobr_v2


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


def test_read_geobr_v2_applies_code_filter(mock_gdf, monkeypatch, tmp_path):
    path = tmp_path / "schools.parquet"
    mock_gdf.to_parquet(path)

    def fake_select_metadata_v2(geography, year, simplified=True, verbose=False):
        return pd.Series({"file_name": path.name, "geo": geography, "year": year})

    monkeypatch.setattr("geobr.utils.select_metadata_v2", fake_select_metadata_v2)
    monkeypatch.setattr("geobr.utils.download_parquet", lambda fn, **k: path)
    monkeypatch.setattr("geobr._cache.is_cached", lambda fn: True)

    out = read_geobr_v2("schools", 2020, code="RJ")
    assert len(out) == 1
    assert out.iloc[0]["abbrev_state"] == "RJ"
