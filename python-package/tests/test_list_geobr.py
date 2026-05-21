import pytest

from geobr import list_geobr


@pytest.mark.network
def test_list_geobr(capsys):
    list_geobr()
    captured = capsys.readouterr()
    assert len(captured.out) > 200
