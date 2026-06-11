import importlib

import geopandas as gpd
import pandas as pd
import pytest
from shapely.geometry import Point

from geobr._duckdb_backend import duckdb_connection, _reset_shared_connection


@pytest.fixture
def sample_gdf():
    """Minimal GeoDataFrame for filter tests."""
    return gpd.GeoDataFrame(
        {
            "code_muni": [3304557, 3550308, 2927408],
            "abbrev_state": ["RJ", "SP", "BA"],
            "code_state": [33, 35, 29],
            "name_muni": ["Rio de Janeiro", "São Paulo", "Salvador"],
        },
        geometry=[Point(0, 0), Point(1, 1), Point(2, 2)],
        crs="EPSG:4674",
    )


@pytest.fixture
def sample_metadata_v2():
    return pd.DataFrame(
        {
            "file_name": ["states_2010_simplified.parquet", "states_2018_simplified.parquet"],
            "geo": ["states", "states"],
            "year": [2010, 2018],
            "simplified": [True, True],
        }
    )


def patch_module_attr(monkeypatch, module_path: str, attr: str, value):
    """Patch attribute on a submodule (avoids geobr namespace shadowing)."""
    mod = importlib.import_module(module_path)
    monkeypatch.setattr(mod, attr, value)
    return mod


@pytest.fixture
def duckdb_conn():
    _reset_shared_connection()
    conn = duckdb_connection()
    conn.execute("SET threads TO 1;")
    yield conn
    conn.close()
    _reset_shared_connection()


def write_geom_parquet(path, data, geometry):
    """Write a minimal GeoParquet file for DuckDB spatial tests."""
    import geopandas as gpd

    gdf = gpd.GeoDataFrame(data, geometry=geometry, crs="EPSG:4674")
    gdf.to_parquet(path)
    return path


def register_geom_view(conn, view_name, parquet_path):
    from geobr._duckdb_backend import register_dataset

    register_dataset(view_name, parquet_path, connection=conn)
