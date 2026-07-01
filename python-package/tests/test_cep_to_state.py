import pytest

from geobr.cep_to_state import cep_to_state


def test_cep_with_hyphen():
    assert cep_to_state("69900-000") == "AC"


def test_cep_without_hyphen():
    assert cep_to_state("20040002") == "RJ"


def test_cep_not_str():
    assert cep_to_state(20040002) == "RJ"


def test_cep_invalid_length():
    with pytest.raises(ValueError, match="8 digits"):
        cep_to_state("123")


def test_cep_not_found():
    with pytest.raises(ValueError, match="CEP not found"):
        cep_to_state("00000000")

def test_cep_none():
    with pytest.raises(ValueError, match="cannot be None"):
        cep_to_state(None)


def test_cep_non_numeric():
    with pytest.raises(ValueError, match="input must have numerical digits"):
        cep_to_state("ab45ft")
