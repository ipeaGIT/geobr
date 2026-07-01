from pathlib import Path
from unittest.mock import MagicMock, patch
import requests

import geopandas as gpd
import pytest

import geobr
from geobr import utils
from geobr._cache import cache_dir, is_cached
from geobr.utils import download_metadata_v2, select_metadata_v2, _download_file, read_geobr_hybrid


class MockStreamResponse:
    def __init__(self, content_bytes, status_code=200):
        self.content_bytes = content_bytes
        self.status_code = status_code
        self.headers = {"content-length": str(len(content_bytes))}

    def iter_content(self, chunk_size=8192):
        for i in range(0, len(self.content_bytes), chunk_size):
            yield self.content_bytes[i : i + chunk_size]


@pytest.fixture
def metadata_file():
    return geobr.utils.download_metadata()

def test_cache_dir_exists():
    d = cache_dir()
    assert d.exists()


def test_select_metadata_v2():
    row = select_metadata_v2("states", 2010, simplified=True, verbose=True)
    assert row["file_name"] == "states_2010_simplified.parquet"


def test_select_metadata_v2_no_year():
    row = select_metadata_v2("states", year=None, simplified=True, verbose=True)
    assert row["file_name"] == "states_2025_simplified.parquet"


def test_select_metadata_v2_invalid_year():
    with pytest.raises(ValueError, match="year"):
        select_metadata_v2("states", 1999, simplified=True)


def test_select_metadata_v2_invalid_geo():
    with pytest.raises(ValueError, match="Geography"):
        select_metadata_v2("invalid", 2010, simplified=True)


def test_select_metadata_v2_invalid_simplified():
    with pytest.raises(ValueError, match="No simplified data"):
        select_metadata_v2("schools", year=2025, simplified=True)


def test_download_file(monkeypatch, tmp_path):
    dest = tmp_path / ".parquet"
    data = b"A" * 8192 + b"B" * 8192 + b"C" * 100

    def mock_get(url, stream=False, timeout=None, verify=True):
        return MockStreamResponse(data, status_code=200)

    monkeypatch.setattr(requests, "get", mock_get)

    resultado = _download_file(
        urls=["https://exemplo.com"],
        dest=dest,
        show_progress=True
    )

    assert resultado is True
    assert dest.exists()
    assert dest.read_bytes() == data 
    assert dest.stat().st_size == len(data)


def test_download_file_no_progress(monkeypatch, tmp_path):
    dest = tmp_path / ".parquet"
    data = b"A" * 8192 + b"B" * 8192 + b"C" * 100

    def mock_get(url, stream=False, timeout=None, verify=True):
        return MockStreamResponse(data, status_code=200)

    monkeypatch.setattr(requests, "get", mock_get)

    resultado = _download_file(
        urls=["https://exemplo.com"],
        dest=dest,
        show_progress=False
    )

    assert resultado is True
    assert dest.exists()
    assert dest.read_bytes() == data 
    assert dest.stat().st_size == len(data)


def test_download_file_status_error(monkeypatch, tmp_path):
    dest = tmp_path / ".parquet"
    data = b"A" * 8192 + b"B" * 8192 + b"C" * 100

    def mock_get(url, stream=False, timeout=None, verify=True):
        return MockStreamResponse(data, status_code=404)

    monkeypatch.setattr(requests, "get", mock_get)

    resultado = _download_file(urls=["https://exemplo.com"], dest=dest, show_progress=False)

    assert resultado is False


def test_download_file_exception(monkeypatch, tmp_path):
    dest = tmp_path / ".parquet"

    def mock_get(url, stream=False, timeout=None, verify=True):
        raise ConnectionError()

    monkeypatch.setattr(requests, "get", mock_get)

    resultado = _download_file(urls=["https://exemplo.com"], dest=dest, show_progress=False)

    assert resultado is False


def test_read_geobr_hybrid():
    gdf = read_geobr_hybrid(
        geography_v2="states",
        geography_gpkg="states",
        year=2025
    )
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty

def test_read_geobr_hybrid_legacy(monkeypatch, sample_gdf):
    monkeypatch.setattr(utils, "download_gpkg", lambda a: sample_gdf)
    gdf = read_geobr_hybrid(
        geography_v2="invalid",
        geography_gpkg="state",
        year=2010,
        code="AP"
    )
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert not gdf.empty


@pytest.mark.network
def test_download_metadata_v2_live():
    meta = download_metadata_v2()
    assert "file_name" in meta.columns
    assert "geo" in meta.columns
    assert len(meta) > 0


@pytest.mark.network
def test_schools_v2_has_no_simplified_parquet():
    meta = download_metadata_v2()
    schools_2020 = meta[(meta["geo"] == "schools") & (meta["year"] == 2020)]
    assert len(schools_2020) == 1
    assert not schools_2020.iloc[0]["simplified"]
    assert "simplified" not in schools_2020.iloc[0]["file_name"]

    with pytest.raises(ValueError, match="No simplified data for schools"):
        select_metadata_v2("schools", 2020, simplified=True)
