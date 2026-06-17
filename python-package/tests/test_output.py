import geopandas as gpd
from geopandas.array import GeometryDtype
import pyarrow as pa
import pyarrow.types as pat
import duckdb

import pytest
from geobr._output import convert_output


@pytest.fixture
def duckdb_relation(duckdb_conn, parquet_path):
    query = f"SELECT * FROM read_parquet('{parquet_path}')"
    return duckdb_conn.sql(query)


def test_convert_output_gpd(duckdb_relation, duckdb_conn):
    out = convert_output(duckdb_relation, output="gpd", connection=duckdb_conn)

    assert isinstance(out, gpd.GeoDataFrame)
    assert len(out) == 4
    assert "geometry" in out.columns
    assert isinstance(out["geometry"].dtype, GeometryDtype)
    assert out.crs.to_string() == "EPSG:4674"


def test_convert_output_arrow(duckdb_relation, duckdb_conn):
    out = convert_output(duckdb_relation, output="arrow", connection=duckdb_conn)

    assert isinstance(out, pa.Table)
    assert out.num_rows == 4
    assert "geometry" in out.column_names
    assert pat.is_binary(out.column("geometry").type)


def test_convert_output_duckdb(duckdb_relation, duckdb_conn):
    out = convert_output(duckdb_relation, output="duckdb", connection=duckdb_conn)
    column_types = dict(zip(out.columns, out.types))

    assert isinstance(out, duckdb.DuckDBPyRelation)
    assert len(out) == 4
    assert "geometry" in column_types
    assert column_types["geometry"] == "GEOMETRY('EPSG:4674')"

