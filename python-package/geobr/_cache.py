"""Disk-backed cache helpers for geobr parquet downloads."""

from __future__ import annotations

import os
from pathlib import Path


def cache_dir() -> Path:
    """Return the geobr cache directory (~/.cache/geobr or temp fallback)."""
    base = os.environ.get("XDG_CACHE_HOME")
    if base:
        path = Path(base) / "geobr"
    else:
        path = Path.home() / ".cache" / "geobr"
    try:
        path.mkdir(parents=True, exist_ok=True)
    except OSError:
        import tempfile

        path = Path(tempfile.gettempdir()) / "geobr"
        path.mkdir(parents=True, exist_ok=True)
    return path


def cached_path(filename: str) -> Path:
    """Full path for a cached parquet file."""
    return cache_dir() / filename


def is_cached(filename: str) -> bool:
    path = cached_path(filename)
    return path.exists() and path.stat().st_size > 0
