import pandas as pd
import pytest
from geobr import lookup_muni


def test_lookup_muni():
    # Check it is DataFrame object

    assert isinstance(lookup_muni.lookup_muni(name_muni="fortaleza"), pd.DataFrame)
    assert isinstance(lookup_muni.lookup_muni(code_muni=2304400), pd.DataFrame)
    assert isinstance(lookup_muni.lookup_muni(name_muni="all"), pd.DataFrame)
    assert isinstance(lookup_muni.lookup_muni(code_muni="all"), pd.DataFrame)
    assert isinstance(lookup_muni.lookup_muni(), pd.DataFrame)

    # Check number of columns
    df = lookup_muni.lookup_muni(name_muni="rio de janeiro")
    assert len(df.columns) == 13

    assert len(lookup_muni.lookup_muni()) > len(
        lookup_muni.lookup_muni(code_muni=2304400)
    )

    # When using two arguments (supposed to give a warning)
    with pytest.raises(Exception):
        lookup_muni.lookup_muni(code_muni=9999999)
        lookup_muni.lookup_muni(name_muni="alem paraiba do longinquo caminho curto")
