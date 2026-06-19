import pytest

from geobr import list_geobr
from geobr.list_geobr import _parse_available_datasets


@pytest.mark.network
def test_list_geobr(capsys):
    list_geobr()
    captured = capsys.readouterr()
    assert len(captured.out) > 200


def test_parse_available_datasets_from_markdown_table():
    readme = """
# geobr

| Function | Geographies available | Source | Years available |
|:---|:---|:---|:---|
| read_country | Country | IBGE | 2020, 2025 |
| read_state | States | IBGE | 2022, 2025 |

point_right: All datasets use SIRGAS2000.
"""

    datasets = _parse_available_datasets(readme)

    assert list(datasets.columns) == [
        "Function",
        "Geographies available",
        "Source",
        "Years available",
    ]
    assert datasets.loc[0, "Function"] == "read_country"
    assert datasets.loc[1, "Years available"] == "2022, 2025"
