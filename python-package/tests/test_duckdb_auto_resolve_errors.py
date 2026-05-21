import pytest

pytest.importorskip("duckdb")

from geobr._duckdb_backend import _reset_shared_connection, _resolve_table_name, query


@pytest.fixture(autouse=True)
def reset_duckdb():
    _reset_shared_connection()
    yield
    _reset_shared_connection()


def test_unknown_geo_raises(monkeypatch, duckdb_conn):
    monkeypatch.setattr("geobr._duckdb_backend._known_geos", lambda: {"schools", "states"})

    with pytest.raises(ValueError, match="Unknown geobr table 'foo_2020'"):
        _resolve_table_name("foo_2020")

    with pytest.raises(ValueError, match="Unknown geobr table 'foo'"):
        _resolve_table_name("foo")


def test_bad_year_raises(monkeypatch, duckdb_conn):
    monkeypatch.setattr("geobr._duckdb_backend._known_geos", lambda: {"schools"})
    monkeypatch.setattr("geobr._duckdb_backend._available_years", lambda geo: [2019, 2020])

    with pytest.raises(ValueError, match="Year 1999 not available for schools"):
        query("SELECT count(*) FROM schools_1999", connection=duckdb_conn)
