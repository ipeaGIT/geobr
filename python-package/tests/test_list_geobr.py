import pandas as pd
from unittest.mock import patch

from geobr.list_geobr import list_geobr


def test_list_geobr_returns_dataframe():
    with patch("geobr.utils.download_metadata_v2", side_effect=ConnectionError):
        df = list_geobr(wide=True)
    assert isinstance(df, pd.DataFrame)
    assert "Function" in df.columns
    assert len(df) >= 27


def test_list_geobr_long_format():
    with patch("geobr.utils.download_metadata_v2", side_effect=ConnectionError):
        df = list_geobr(wide=False)
    assert isinstance(df, pd.DataFrame)
