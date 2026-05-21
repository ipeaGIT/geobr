"""Optional DuckDB backend for lazy parquet reads."""

from __future__ import annotations

from pathlib import Path
from typing import Any, Optional, Union

_CONN: Optional[Any] = None


def _require_duckdb():
    try:
        import duckdb
    except ImportError as e:
        raise ImportError(
            "Optional dependency 'duckdb' is required for output='duckdb'. "
            "Install with: pip install geobr[duckdb]"
        ) from e
    return duckdb


def _setup_connection(conn) -> None:
    for stmt in ("INSTALL spatial", "LOAD spatial", "INSTALL httpfs", "LOAD httpfs"):
        try:
            conn.execute(stmt)
        except Exception:
            pass


def duckdb_connection():
    """Return the shared DuckDB connection."""
    global _CONN
    if _CONN is None:
        duckdb = _require_duckdb()
        _CONN = duckdb.connect()
        _setup_connection(_CONN)
    return _CONN


def register_dataset(
    name: str,
    parquet_path: Union[str, Path],
    *,
    connection: Optional[Any] = None,
) -> Any:
    """Register a parquet file as a DuckDB view."""
    conn = connection or duckdb_connection()
    path_str = str(Path(parquet_path).resolve()).replace("'", "''")
    safe_name = name.replace('"', '""')
    conn.execute(
        f'CREATE OR REPLACE VIEW "{safe_name}" AS '
        f"SELECT * FROM read_parquet('{path_str}')"
    )
    return conn.sql(f'SELECT * FROM "{safe_name}"')


def read_parquet_relation(
    path: Union[str, Path],
    filter_code: Any = "all",
    *,
    connection: Optional[Any] = None,
    view_name: Optional[str] = None,
) -> Any:
    """Return a DuckDB relation over a parquet file."""
    conn = connection or duckdb_connection()
    if view_name:
        register_dataset(view_name, path, connection=conn)
        source = f'"{view_name.replace(chr(34), chr(34) * 2)}"'
    else:
        path_str = str(Path(path).resolve()).replace("'", "''")
        source = f"read_parquet('{path_str}')"

    if filter_code == "all" or filter_code is None:
        return conn.sql(f"SELECT * FROM {source}")

    codes = filter_code if isinstance(filter_code, (list, tuple)) else [filter_code]
    code = codes[0] if len(codes) == 1 else filter_code

    if isinstance(code, str) and len(code) == 2 and code.isalpha():
        return conn.sql(f"SELECT * FROM {source} WHERE abbrev_state = '{code}'")
    if str(code).isdigit() and len(str(code)) == 7:
        return conn.sql(
            f"SELECT * FROM {source} WHERE CAST(code_muni AS BIGINT) = {int(code)}"
        )
    if str(code).isdigit() and len(str(code)) <= 2:
        return conn.sql(
            f"SELECT * FROM {source} WHERE CAST(code_state AS INTEGER) = {int(code)}"
        )

    return conn.sql(f"SELECT * FROM {source}")
