"""DuckDB backend for lazy parquet reads."""

from __future__ import annotations

from pathlib import Path
from typing import Any, Optional, Union
import duckdb

_CONN: Optional[Any] = None


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
        _CONN = duckdb.connect()
        _setup_connection(_CONN)
    return _CONN


def _reset_shared_connection():
    global _CONN
    if _CONN is not None:
        try:
            _CONN.close()
        except Exception:
            pass
    _CONN = None


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


def read_filter_parquet_relation(
    path: Union[str, Path],
    filter_code: Any = "all",
    *,
    connection: Optional[Any] = None,
    view_name: Optional[str] = None,
):
    """Return a DuckDB relation over a parquet file."""
    if view_name:
        register_dataset(view_name, path, connection=connection)
        source = f'"{view_name.replace(chr(34), chr(34) * 2)}"'
    else:
        path_str = str(Path(path).resolve()).replace("'", "''")
        source = f"read_parquet('{path_str}')"

    if filter_code == "all" or filter_code is None:
        return connection.sql(f"SELECT * FROM {source}")

    codes = filter_code if isinstance(filter_code, (list, tuple)) else [filter_code]
    code = codes[0]

    if isinstance(code, str) and len(code) == 2 and code.isalpha():
        codes_sql = ", ".join([f"'{c}'" for c in codes])
        return connection.sql(f"SELECT * FROM {source} WHERE abbrev_state IN ({codes_sql})")
    if str(code).isdigit() and len(str(code)) == 7:
        codes_sql = ", ".join(map(str, codes))
        return connection.sql(
            f"SELECT * FROM {source} WHERE CAST(code_muni AS BIGINT) IN ({codes_sql})"
        )
    if str(code).isdigit() and len(str(code)) <= 2:
        codes_sql = ", ".join(map(str, codes))
        return connection.sql(
            f"SELECT * FROM {source} WHERE CAST(code_state AS INTEGER) IN ({codes_sql})"
        )

    rel = connection.sql(f"SELECT * FROM {source}")

    if str(code).isdigit() and len(str(code)) > 3:
        code_cols = [c for c in rel.columns if c.startswith("code_") and c not in ["code_state", "code_muni"]]
        for code_col in code_cols:
            len_alvo = rel.aggregate(f"max(length(CAST(CAST({code_col} as BIGINT) as VARCHAR)))").fetchone()[0]
            if len_alvo == len(str(code)):
                filter_col = code_col
                codes_sql = ", ".join(map(str, codes))
                return connection.sql(f"SELECT * FROM {source} WHERE CAST({filter_col} AS INTEGER) IN ({codes_sql})")

    return rel
