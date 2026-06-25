import pytest

pytest.importorskip("duckdb")

from shapely.geometry import Point, box

from geobr._duckdb_backend import query, register_dataset
from tests.conftest import write_geom_parquet


def test_spatial_join_schools_biomes(duckdb_conn, tmp_path):
    schools_path = write_geom_parquet(
        tmp_path / "schools.parquet",
        {
            "code_school": [1, 2],
            "code_state": [33, 35],
        },
        geometry=[Point(0.5, 0.5), Point(5, 5)],
    )
    biomes_path = write_geom_parquet(
        tmp_path / "biomes.parquet",
        {"name_biome": ["Atlantic", "Amazonia"]},
        geometry=[box(0, 0, 1, 1), box(4, 4, 6, 6)],
    )
    register_dataset("schools_2020", schools_path, connection=duckdb_conn)
    register_dataset("biomes_2019", biomes_path, connection=duckdb_conn)

    joined = query(
        """
        SELECT s.code_school, b.name_biome
        FROM schools_2020 s
        JOIN biomes_2019 b ON ST_Within(s.geometry, b.geometry)
        ORDER BY s.code_school
        """,
        connection=duckdb_conn,
    ).df()

    assert list(joined.columns) == ["code_school", "name_biome"]
    assert joined["code_school"].tolist() == [1, 2]
    assert joined["name_biome"].tolist() == ["Atlantic", "Amazonia"]
