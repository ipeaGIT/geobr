import pytest

pytest.importorskip("duckdb")
import geopandas as gpd
from shapely.geometry import box

from geobr._duckdb_backend import register_dataset, to_geopandas
from tests.conftest import write_geom_parquet


def test_to_geopandas_roundtrip(duckdb_conn, tmp_path):
    path = write_geom_parquet(
        tmp_path / "states.parquet",
        {"name_state": ["RJ"], "code_state": [33]},
        geometry=[box(0, 0, 1, 1)],
    )
    register_dataset("states_2020", path, connection=duckdb_conn)

    gdf = to_geopandas("states_2020", connection=duckdb_conn)
    assert isinstance(gdf, gpd.GeoDataFrame)
    assert gdf.crs.to_epsg() == 4674
    assert gdf.iloc[0]["name_state"] == "RJ"
    assert gdf.geometry.iloc[0].area == pytest.approx(1.0)
