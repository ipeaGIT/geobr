from geobr import grid_state_correspondence_table

def test_grid_state_correspondence_table():

    df = grid_state_correspondence_table()

    assert len(df) == 139
    len(df.columns) == 3
