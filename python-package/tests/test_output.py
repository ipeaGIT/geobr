from pathlib import Path
from unittest.mock import patch

import geopandas as gpd
import pytest
from shapely.geometry import Point

from geobr._output import convert_output


@pytest.fixture
def parquet_path(tmp_path):
    gdf = gpd.GeoDataFrame(
        {"code_state": [33]},
        geometry=[Point(-43.2, -22.9)],
        crs="EPSG:4674",
    )
    path = tmp_path / "test.parquet"
    gdf.to_parquet(path)
    return path


def test_convert_output_sf(parquet_path):
    out = convert_output(parquet_path, output="sf")
    assert isinstance(out, gpd.GeoDataFrame)
    assert len(out) == 1


def test_convert_output_duckdb_missing(parquet_path):
    with patch(
        "geobr._duckdb_backend._require_duckdb",
        side_effect=ImportError("pip install geobr[duckdb]"),
    ):
        with pytest.raises(ImportError, match="duckdb"):
            convert_output(parquet_path, output="duckdb")


def test_convert_output_arrow(parquet_path):
    import pyarrow as pa

    table = convert_output(parquet_path, output="arrow")
    assert isinstance(table, pa.Table)
    assert table.num_rows == 1
