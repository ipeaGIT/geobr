import pytest

pytest.importorskip("duckdb")

from shapely.geometry import box

from geobr._duckdb_backend import duckdb_connection, session
from tests.conftest import register_geom_view, write_geom_parquet


def test_sessions_are_isolated(tmp_path):
    path_a = write_geom_parquet(
        tmp_path / "a.parquet",
        {"id": [1]},
        geometry=[box(0, 0, 1, 1)],
    )
    path_b = write_geom_parquet(
        tmp_path / "b.parquet",
        {"id": [2]},
        geometry=[box(1, 1, 2, 2)],
    )

    with session() as s1, session() as s2:
        register_geom_view(s1.connection, "dataset_a", path_a)
        register_geom_view(s2.connection, "dataset_b", path_b)

        assert s1.query("SELECT count(*) FROM dataset_a").fetchone()[0] == 1
        assert s2.query("SELECT count(*) FROM dataset_b").fetchone()[0] == 1

        with pytest.raises(Exception):
            s1.query("SELECT count(*) FROM dataset_b")

        with pytest.raises(Exception):
            s2.query("SELECT count(*) FROM dataset_a")

    shared = duckdb_connection()
    tables = {row[0] for row in shared.execute("SHOW TABLES").fetchall()}
    assert "states_2020" not in tables
    assert "states_2010" not in tables
