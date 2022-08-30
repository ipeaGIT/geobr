from time import time
import geopandas as gpd
import pandas as pd
import pytest

import geobr
from geobr.utils import (
    select_year,
    select_simplified,
    download_gpkg,
    load_gpkg,
    select_metadata,
    enforce_types,
)


@pytest.fixture
def metadata_file():
    return geobr.utils.download_metadata()


def test_download_metadata(metadata_file):

    # Check if it fails if it doesn't find a file
    with pytest.raises(Exception):
        geobr.utils.download_metadata(url="http://www.ipea.gov.br/geobr/metadata/met")

    # Check if columns are the same
    assert (
        ["geo", "year", "code", "download_path", "code_abbrev"] == metadata_file.columns
    ).all()

    # Check if it has content
    assert len(metadata_file) > 0


def test_download_metadata_cache():

    # Check if cache works
    start_time = time()
    geobr.utils.download_metadata()
    assert time() - start_time < 1


def test_select_year():

    metadata = pd.DataFrame([2004, 2019], columns=["year"])

    assert select_year(metadata, None)["year"].unique()[0] == 2019

    assert select_year(metadata, 2004)["year"].unique()[0] == 2004

    with pytest.raises(Exception):
        assert select_year(metadata, 2006)
        assert select_year(metadata, "as")
        assert select_year(metadata, 2324.12)


def test_select_simplified():

    metadata = pd.DataFrame(["url_simplified", "url"], columns=["download_path"])

    assert (
        select_simplified(metadata, True)["download_path"].unique()[0]
        == "url_simplified"
    )

    assert select_simplified(metadata, False)["download_path"].unique()[0] == "url"

    with pytest.raises(Exception):
        assert select_simplified(metadata, "slified")
        assert select_simplified(metadata, None)
        assert select_simplified(metadata, 2324.12)


def test_load_gpkg():

    valid_url = (
        "http://www.ipea.gov.br/geobr/data_gpkg/amazonia_legal/2012/amazonia_legal.gpkg"
    )

    assert isinstance(load_gpkg(valid_url), gpd.geodataframe.GeoDataFrame)

    # Test Cache
    start_time = time()
    load_gpkg(valid_url)
    assert time() - start_time < 1

    with pytest.raises(Exception):
        isinstance(load_gpkg("asd"), gpd.geodataframe.GeoDataFrame)
        isinstance(load_gpkg(1234), gpd.geodataframe.GeoDataFrame)
        isinstance(load_gpkg(valid_url + "asdf"), gpd.geodataframe.GeoDataFrame)


def test_enforce_types():

    code_muni_type = geobr.constants.DataTypes.code_muni.value

    df = pd.DataFrame({"code_muni": ["1", "2", "3"]})

    t = df["code_muni"].dtype

    assert enforce_types(df)["code_muni"].dtype == code_muni_type
    assert enforce_types(df)["code_muni"].dtype != t

    df = pd.DataFrame({"code_muni": ["1", "2", 3.4]})

    assert enforce_types(df)["code_muni"].dtype == code_muni_type

    df = pd.DataFrame({"random": ["1", "2", 3.4]})

    assert enforce_types(df)["random"].dtype == df["random"].dtype

    # Deals with None
    df = pd.DataFrame({"code_muni": [None, "2", "3"]})
    assert enforce_types(df)["code_muni"].dtype == code_muni_type


def test_download_gpkg():

    multiple_metadata = pd.DataFrame(
        [
            "http://www.ipea.gov.br/geobr/data_gpkg/amazonia_legal/2012/amazonia_legal.gpkg",
            "http://www.ipea.gov.br/geobr/data_gpkg/meso_regiao/2014/17ME_simplified.gpkg",
        ],
        columns=["download_path"],
    )

    single_metadata = pd.DataFrame(
        [
            "http://www.ipea.gov.br/geobr/data_gpkg/amazonia_legal/2012/amazonia_legal.gpkg"
        ],
        columns=["download_path"],
    )

    # assert isinstance(download_gpkg(multiple_metadata),
    #                   gpd.geodataframe.GeoDataFrame)
    assert isinstance(download_gpkg(single_metadata), gpd.geodataframe.GeoDataFrame)


def test_select_metadata():

    assert isinstance(
        select_metadata("state", "simplified", 2010), pd.core.frame.DataFrame
    )

    assert isinstance(
        select_metadata("state", "simplified", None), pd.core.frame.DataFrame
    )

    assert isinstance(select_metadata("state", "normal", None), pd.core.frame.DataFrame)

    # checks if None conditions are being applied
    assert len(select_metadata("state", "normal", None)) < len(
        select_metadata("state", False, False)
    )

    assert len(select_metadata("state", "simplified", None)) < len(
        select_metadata("state", False, False)
    )

    with pytest.raises(Exception):
        select_metadata(123, 123, 123)
        select_metadata("state", 123, 123)
        select_metadata("state", "simplified", 12334)
