"""Live DuckDB tests that download geobr data from the network."""

import pytest

pytest.importorskip("duckdb")

from geobr import query, to_geopandas
from geobr._duckdb_backend import _reset_shared_connection
from geobr.utils import read_geobr_hybrid, select_metadata_v2


@pytest.fixture(autouse=True)
def reset_duckdb():
    _reset_shared_connection()
    yield
    _reset_shared_connection()


@pytest.mark.network
def test_network_query_states_2020_auto_resolve(duckdb_conn):
    count = query(
        "SELECT count(*) FROM states_2020",
        connection=duckdb_conn,
    ).fetchone()[0]
    assert count == 27

    rj = query(
        """
        SELECT name_state, abbrev_state
        FROM states_2020
        WHERE abbrev_state = 'RJ'
        """,
        connection=duckdb_conn,
    ).df()
    assert len(rj) == 1
    assert rj.iloc[0]["name_state"] == "Rio de Janeiro"


@pytest.mark.network
def test_network_read_geobr_hybrid_schools_duckdb(duckdb_conn):
    rel = read_geobr_hybrid(
        "schools",
        "schools",
        2020,
        simplified=True,
        output="duckdb",
        show_progress=False,
        connection=duckdb_conn,
        view_name="schools_2020",
    )
    count = rel.aggregate("count(*)").fetchone()[0]
    assert count > 100_000

    tables = {row[0] for row in duckdb_conn.execute("SHOW TABLES").fetchall()}
    assert "schools_2020" in tables


@pytest.mark.network
def test_network_query_schools_2020_auto_resolve(duckdb_conn):
    count = query(
        "SELECT count(*) FROM schools_2020",
        connection=duckdb_conn,
    ).fetchone()[0]
    assert count > 100_000


@pytest.mark.network
def test_network_query_biomes_2019_auto_resolve(duckdb_conn):
    count = query(
        "SELECT count(*) FROM biomes_2019",
        connection=duckdb_conn,
    ).fetchone()[0]
    assert count == 7


@pytest.mark.network
def test_network_spatial_join_schools_biomes(duckdb_conn):
    schools_in_amazon = query(
        """
        SELECT count(*) AS schools_in_amazon
        FROM schools_2020 AS s
        JOIN biomes_2019 AS b
          ON ST_Within(s.geometry, b.geometry)
        WHERE b.name_biome ILIKE '%Amaz%'
        """,
        connection=duckdb_conn,
    ).fetchone()[0]
    assert schools_in_amazon > 10_000


@pytest.mark.network
def test_network_to_geopandas_round_trip(duckdb_conn):
    query("SELECT 1 FROM states_2020 LIMIT 1", connection=duckdb_conn)
    gdf = to_geopandas("states_2020", connection=duckdb_conn)
    assert len(gdf) == 27
    assert gdf.crs.to_epsg() == 4674
    assert gdf.geometry.geom_type.isin(["Polygon", "MultiPolygon"]).all()


@pytest.mark.network
def test_network_schools_metadata_matches_hybrid_load():
    row = select_metadata_v2("schools", 2020, simplified=False)
    assert row["file_name"] == "schools_2020.parquet"

    rel = read_geobr_hybrid(
        "schools",
        "schools",
        2020,
        simplified=True,
        output="duckdb",
        show_progress=False,
    )
    assert rel.aggregate("count(*)").fetchone()[0] > 100_000
