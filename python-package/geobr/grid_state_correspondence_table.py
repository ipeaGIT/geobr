"""Correspondence table indicating what quadrants of IBGE's statistical grid intersect with each Brazilian state"""

from pathlib import Path

import pandas as pd

def _grid_state_correspondence_path() -> Path:
    return Path(__file__).parent / "data" / "grid_state_correspondence_table.csv"

def grid_state_correspondence_table() -> pd.DataFrame:
    """
    A correspondence table indicating what quadrants of IBGE's statistical grid intersect with each Brazilian state
    """

    return pd.read_csv(_grid_state_correspondence_path(), encoding='latin1')
