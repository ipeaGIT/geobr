"""Unit tests for read_geobr_hybrid simplified retry and gpkg fallback."""

import pytest

from geobr.utils import _simplified_attempts, read_geobr_hybrid


def test_simplified_attempts_prefers_original_when_true():
    assert _simplified_attempts(True) == [True, False]


def test_simplified_attempts_respects_explicit_false():
    assert _simplified_attempts(False) == [False]


def test_read_geobr_hybrid_retries_non_simplified_v2(monkeypatch):
    calls = []

    def fake_read_geobr_v2(geography, year, *, simplified, **kwargs):
        calls.append(simplified)
        if simplified:
            raise ValueError("No simplified data for schools in year 2020.")
        return "v2-ok"

    monkeypatch.setattr("geobr.utils.read_geobr_v2", fake_read_geobr_v2)

    result = read_geobr_hybrid("schools", "schools", 2020, simplified=True)
    assert result == "v2-ok"
    assert calls == [True, False]


def test_read_geobr_hybrid_explicit_non_simplified_skips_retry(monkeypatch):
    calls = []

    def fake_read_geobr_v2(geography, year, *, simplified, **kwargs):
        calls.append(simplified)
        return "v2-ok"

    monkeypatch.setattr("geobr.utils.read_geobr_v2", fake_read_geobr_v2)

    result = read_geobr_hybrid("schools", "schools", 2020, simplified=False)
    assert result == "v2-ok"
    assert calls == [False]


def test_read_geobr_hybrid_gpkg_fallback_retries_non_simplified(monkeypatch):
    v2_calls = []
    gpkg_calls = []

    def fake_read_geobr_v2(geography, year, *, simplified, **kwargs):
        v2_calls.append(simplified)
        raise ValueError(f"v2 failed simplified={simplified}")

    def fake_select_metadata(geo, year, simplified):
        gpkg_calls.append(simplified)
        if simplified:
            raise Exception("no simplified gpkg for year")
        return {"download_link": "http://example.com/schools.gpkg"}

    def fake_download_gpkg(metadata):
        return "gdf"

    monkeypatch.setattr("geobr.utils.read_geobr_v2", fake_read_geobr_v2)
    monkeypatch.setattr("geobr.utils.select_metadata", fake_select_metadata)
    monkeypatch.setattr("geobr.utils.download_gpkg", fake_download_gpkg)

    result = read_geobr_hybrid("schools", "schools", 2020, simplified=True)
    assert result == "gdf"
    assert v2_calls == [True, False]
    assert gpkg_calls == [True, False]


def test_read_geobr_hybrid_raises_when_all_attempts_fail(monkeypatch):
    def fake_read_geobr_v2(geography, year, *, simplified, **kwargs):
        raise ValueError(f"v2 failed simplified={simplified}")

    def fake_select_metadata(geo, year, simplified):
        raise Exception(f"gpkg failed simplified={simplified}")

    monkeypatch.setattr("geobr.utils.read_geobr_v2", fake_read_geobr_v2)
    monkeypatch.setattr("geobr.utils.select_metadata", fake_select_metadata)

    with pytest.raises(Exception, match="gpkg failed simplified=False"):
        read_geobr_hybrid("schools", "schools", 2020, simplified=True)


def test_read_geobr_hybrid_duckdb_output_passes_through(monkeypatch):
    calls = []

    def fake_read_geobr_v2(geography, year, *, simplified, output, connection, view_name, **kwargs):
        calls.append((simplified, output, view_name))
        if simplified:
            raise ValueError("No simplified data for schools in year 2020.")
        return f"duckdb:{view_name}"

    monkeypatch.setattr("geobr.utils.read_geobr_v2", fake_read_geobr_v2)

    result = read_geobr_hybrid(
        "schools",
        "schools",
        2020,
        simplified=True,
        output="duckdb",
        connection="conn",
        view_name="schools_2020",
    )
    assert result == "duckdb:schools_2020"
    assert calls == [(True, "duckdb", "schools_2020"), (False, "duckdb", "schools_2020")]
