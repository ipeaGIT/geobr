from geobr import list_geobr

def test_list_geobr(capsys):

    list_geobr()

    # Tests whether the function prints output
    captured = capsys.readouterr()
    assert len(captured.out) > 200
