import pytest

pytest.importorskip("duckdb")

from shapely.geometry import box

from geobr._duckdb_backend import query, register_dataset
from tests.conftest import write_geom_parquet


def test_st_area_centroid_buffer(duckdb_conn, tmp_path):
    path = write_geom_parquet(
        tmp_path / "states.parquet",
        {"name_state": ["RJ", "SP"], "code_state": [33, 35]},
        geometry=[box(0, 0, 1, 1), box(0, 0, 2, 2)],
    )
    register_dataset("states_2020", path, connection=duckdb_conn)

    areas = query(
        "SELECT name_state, ST_Area(geometry) AS area FROM states_2020 ORDER BY name_state",
        connection=duckdb_conn,
    ).df()
    assert areas["area"].tolist() == pytest.approx([1.0, 4.0])

    centroid = query(
        "SELECT ST_X(ST_Centroid(geometry)) AS x FROM states_2020 WHERE name_state = 'RJ'",
        connection=duckdb_conn,
    ).fetchone()[0]
    assert centroid == pytest.approx(0.5)

    buffered = query(
        "SELECT ST_Area(ST_Buffer(geometry, 0.1)) > ST_Area(geometry) AS grew "
        "FROM states_2020 WHERE name_state = 'RJ'",
        connection=duckdb_conn,
    ).fetchone()[0]
    assert buffered is True
