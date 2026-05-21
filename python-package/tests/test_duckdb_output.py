import pytest

pytest.importorskip("duckdb")

from pathlib import Path
import geopandas as gpd
from shapely.geometry import Point

from geobr._output import convert_output


def test_duckdb_output(tmp_path):
    gdf = gpd.GeoDataFrame({"a": [1]}, geometry=[Point(0, 0)], crs="EPSG:4674")
    path = tmp_path / "t.parquet"
    gdf.to_parquet(path)
    rel = convert_output(path, output="duckdb")
    df = rel.df()
    assert len(df) == 1
