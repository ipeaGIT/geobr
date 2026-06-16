"""Tests for code filtering through the v2 read pipeline."""

import pandas as pd

from geobr.utils import read_geobr_v2


def test_read_geobr_v2_applies_code_state_filter(sample_gdf, monkeypatch, tmp_path):
    path = tmp_path / "schools.parquet"
    sample_gdf.to_parquet(path)

    def fake_select_metadata_v2(geography, year, simplified=True, verbose=False, zone=None):
        return pd.Series({"file_name": path.name, "download_url": "", "geo": geography, "year": year})

    monkeypatch.setattr("geobr.utils.select_metadata_v2", fake_select_metadata_v2)
    monkeypatch.setattr("geobr.utils.download_parquet", lambda fn, url, **k: path)
    monkeypatch.setattr("geobr._cache.is_cached", lambda fn: True)

    out = read_geobr_v2("schools", 2020, code="RJ")
    assert len(out) == 1
    assert out.iloc[0]["abbrev_state"] == "RJ"


def test_read_geobr_v2_applies_code_muni_filter(sample_gdf, monkeypatch, tmp_path):
    path = tmp_path / "schools.parquet"
    sample_gdf.to_parquet(path)

    def fake_select_metadata_v2(geography, year, simplified=True, verbose=False, zone=None):
        return pd.Series({"file_name": path.name, "download_url": "", "geo": geography, "year": year})

    monkeypatch.setattr("geobr.utils.select_metadata_v2", fake_select_metadata_v2)
    monkeypatch.setattr("geobr.utils.download_parquet", lambda fn, url, **k: path)
    monkeypatch.setattr("geobr._cache.is_cached", lambda fn: True)

    out = read_geobr_v2("schools", 2020, code=3550308)
    assert len(out) == 1
    assert out.iloc[0]["abbrev_state"] == "SP"


def test_read_geobr_v2_applies_multiple_codes_filter(sample_gdf, monkeypatch, tmp_path):
    path = tmp_path / "schools.parquet"
    sample_gdf.to_parquet(path)

    def fake_select_metadata_v2(geography, year, simplified=True, verbose=False, zone=None):
        return pd.Series({"file_name": path.name, "download_url": "", "geo": geography, "year": year})

    monkeypatch.setattr("geobr.utils.select_metadata_v2", fake_select_metadata_v2)
    monkeypatch.setattr("geobr.utils.download_parquet", lambda fn, url, **k: path)
    monkeypatch.setattr("geobr._cache.is_cached", lambda fn: True)

    out = read_geobr_v2("schools", 2020, code=["RJ", "BA"])
    assert len(out) == 2
    assert out.iloc[0]["abbrev_state"] == "RJ"
    assert out.iloc[1]["abbrev_state"] == "BA"
