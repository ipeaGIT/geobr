import pytest

pytest.importorskip("duckdb")

from geobr._duckdb_backend import _reset_shared_connection, query
from tests.conftest import patch_module_attr, register_geom_view, write_geom_parquet


@pytest.fixture(autouse=True)
def reset_duckdb():
    _reset_shared_connection()
    yield
    _reset_shared_connection()


def test_auto_resolve_suffixed_view(monkeypatch, duckdb_conn, tmp_path):
    from shapely.geometry import box

    path = write_geom_parquet(
        tmp_path / "states.parquet",
        {"name_state": ["RJ"], "code_state": [33]},
        geometry=[box(0, 0, 1, 1)],
    )

    def fake_read_geobr_hybrid(v2, gpkg, year, **kwargs):
        register_geom_view(kwargs["connection"], kwargs["view_name"], path)
        return kwargs["connection"].sql(f'SELECT * FROM "{kwargs["view_name"]}"')

    patch_module_attr(monkeypatch, "geobr.utils", "read_geobr_hybrid", fake_read_geobr_hybrid)
    monkeypatch.setattr("geobr._duckdb_backend._known_geos", lambda: {"states"})
    monkeypatch.setattr("geobr._duckdb_backend._available_years", lambda geo: [2010, 2020])

    count = query(
        "SELECT count(*) FROM states_2020",
        connection=duckdb_conn,
    ).fetchone()[0]
    assert count == 1
    tables = {row[0] for row in duckdb_conn.execute("SHOW TABLES").fetchall()}
    assert "states_2020" in tables


def test_auto_resolve_bare_registered_no_warning(monkeypatch, duckdb_conn, tmp_path):
    from shapely.geometry import box

    path = write_geom_parquet(
        tmp_path / "schools.parquet",
        {"code_school": [1]},
        geometry=[box(0, 0, 1, 1)],
    )
    register_geom_view(duckdb_conn, "schools_2020", path)

    monkeypatch.setattr("geobr._duckdb_backend._known_geos", lambda: {"schools"})
    monkeypatch.setattr("geobr._duckdb_backend._available_years", lambda geo: [2020])

    with pytest.warns(None) as record:
        count = query("SELECT count(*) FROM schools", connection=duckdb_conn).fetchone()[0]
    assert count == 1
    assert not record.list


def test_auto_resolve_bare_cached_warns(monkeypatch, duckdb_conn, tmp_path):
    from shapely.geometry import box

    cache_file = tmp_path / "schools_2019_simplified.parquet"
    write_geom_parquet(
        cache_file,
        {"code_school": [1]},
        geometry=[box(0, 0, 1, 1)],
    )

    calls = []

    def fake_read_geobr_hybrid(v2, gpkg, year, **kwargs):
        calls.append(year)
        register_geom_view(kwargs["connection"], kwargs["view_name"], cache_file)
        return kwargs["connection"].sql(f'SELECT * FROM "{kwargs["view_name"]}"')

    patch_module_attr(monkeypatch, "geobr.utils", "read_geobr_hybrid", fake_read_geobr_hybrid)
    monkeypatch.setattr("geobr._duckdb_backend._known_geos", lambda: {"schools"})
    monkeypatch.setattr("geobr._duckdb_backend._available_years", lambda geo: [2019, 2020])
    monkeypatch.setattr("geobr._duckdb_backend._cached_years", lambda geo: [2019])

    with pytest.warns(UserWarning, match="FROM schools: no year specified, using cached year 2019"):
        count = query("SELECT count(*) FROM schools", connection=duckdb_conn).fetchone()[0]
    assert count == 1
    assert calls == [2019]


def test_auto_resolve_bare_download_warns(monkeypatch, duckdb_conn, tmp_path):
    from shapely.geometry import box

    path = write_geom_parquet(
        tmp_path / "schools_2020.parquet",
        {"code_school": [1]},
        geometry=[box(0, 0, 1, 1)],
    )
    calls = []

    def fake_read_geobr_hybrid(v2, gpkg, year, **kwargs):
        calls.append(year)
        register_geom_view(kwargs["connection"], kwargs["view_name"], path)
        return kwargs["connection"].sql(f'SELECT * FROM "{kwargs["view_name"]}"')

    patch_module_attr(monkeypatch, "geobr.utils", "read_geobr_hybrid", fake_read_geobr_hybrid)
    monkeypatch.setattr("geobr._duckdb_backend._known_geos", lambda: {"schools"})
    monkeypatch.setattr("geobr._duckdb_backend._available_years", lambda geo: [2019, 2020])
    monkeypatch.setattr("geobr._duckdb_backend._cached_years", lambda geo: [])

    with pytest.warns(
        UserWarning,
        match=(
            "FROM schools: no year specified, using year 2020 \\(most recent available\\). "
            "To choose a year, use FROM schools_2020 in SQL or call "
            "read_schools\\(year=2020, output='duckdb'\\) first. "
            "Available years: 2019, 2020."
        ),
    ):
        count = query("SELECT count(*) FROM schools", connection=duckdb_conn).fetchone()[0]
    assert count == 1
    assert calls == [2020]
