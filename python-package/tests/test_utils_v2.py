from pathlib import Path
from unittest.mock import MagicMock, patch

import pandas as pd
import pytest

from geobr._cache import cache_dir, is_cached
from geobr.utils import download_metadata_v2, select_metadata_v2


def test_cache_dir_exists():
    d = cache_dir()
    assert d.exists()


def test_select_metadata_v2(sample_metadata_v2):
    with patch("geobr.utils.download_metadata_v2", return_value=sample_metadata_v2):
        row = select_metadata_v2("states", 2010, simplified=True)
    assert row["file_name"] == "states_2010_simplified.parquet"


def test_select_metadata_v2_invalid_year(sample_metadata_v2):
    with patch("geobr.utils.download_metadata_v2", return_value=sample_metadata_v2):
        with pytest.raises(ValueError, match="year"):
            select_metadata_v2("states", 1999, simplified=True)


@pytest.mark.network
def test_download_metadata_v2_live():
    meta = download_metadata_v2()
    assert "file_name" in meta.columns
    assert "geo" in meta.columns
    assert len(meta) > 0


@pytest.mark.network
def test_schools_v2_has_no_simplified_parquet():
    meta = download_metadata_v2()
    schools_2020 = meta[(meta["geo"] == "schools") & (meta["year"] == 2020)]
    assert len(schools_2020) == 1
    assert not schools_2020.iloc[0]["simplified"]
    assert "simplified" not in schools_2020.iloc[0]["file_name"]

    with pytest.raises(ValueError, match="No simplified data for schools"):
        select_metadata_v2("schools", 2020, simplified=True)
