"""Map Brazilian postal codes (CEP) to state abbreviations."""

from __future__ import annotations

import re

_CEP_RANGES = [
    ("AC", (69900000, 69999999)),
    ("AL", (57000000, 57999999)),
    ("AM", (69000000, 69299999)),
    ("AM", (69400000, 69899999)),
    ("AP", (68900000, 68999999)),
    ("BA", (40000000, 48999999)),
    ("CE", (60000000, 63999999)),
    ("DF", (70000000, 72799999)),
    ("DF", (73000000, 73699999)),
    ("ES", (29000000, 29999999)),
    ("GO", (72800000, 72999999)),
    ("GO", (73700000, 76799999)),
    ("MA", (65000000, 65999999)),
    ("MG", (30000000, 39999999)),
    ("MS", (79000000, 79999999)),
    ("MT", (78000000, 78899999)),
    ("PA", (66000000, 68899999)),
    ("PB", (58000000, 58999999)),
    ("PE", (50000000, 56999999)),
    ("PI", (64000000, 64999999)),
    ("PR", (80000000, 87999999)),
    ("RJ", (20000000, 28999999)),
    ("RN", (59000000, 59999999)),
    ("RO", (76800000, 76999999)),
    ("RR", (69300000, 69399999)),
    ("RS", (90000000, 99999999)),
    ("SC", (88000000, 89999999)),
    ("SE", (49000000, 49999999)),
    ("SP", (1000000, 19999999)),
    ("TO", (77000000, 77999999)),
]


def cep_to_state(cep: str) -> str:
    """Return the two-letter state abbreviation for a Brazilian CEP.

    Parameters
    ----------
    cep : str
        Eight digits, with or without hyphen (e.g. ``'69900-000'`` or ``'69900000'``).
    """
    if cep is None:
        raise ValueError("Error: 'cep' cannot be None.")

    cep = re.sub(r"[-.]", "", str(cep))
    if not cep.isdigit():
        raise ValueError("'cep' input must have numerical digits.")
    if len(cep) != 8:
        raise ValueError("'cep' must have 8 digits.")

    cep_num = int(cep)
    for state, (lo, hi) in _CEP_RANGES:
        if lo <= cep_num <= hi:
            return state
    raise ValueError("CEP not found")
