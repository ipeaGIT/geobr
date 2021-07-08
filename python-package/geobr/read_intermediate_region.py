from geobr.utils import select_metadata, download_gpkg


def read_intermediate_region(
    code_intermadiate="all", year=2019, simplified=True, verbose=False
):
    r"""Download spatial data of Brazil's Intermediate Geographic Areas

    The intermediate Geographic Areas are part of the geographic division of
    Brazil created in 2017 by IBGE. These regions were created to replace the
    "Meso Regions" division. Data at scale 1:250,000, using Geodetic reference
    system "SIRGAS2000" and CRS(4674)

       Parameters
       ----------
       code_intermadiate: str or int, by default "all"
            4-digit code of an intermediate region. If the two-digit code or a
            two-letter uppercase abbreviation of a state is passed,
            (e.g. 33 or "RJ") the function will load all intermediate regions of that
            state. If `code_intermediate="all"` (Default), all intermediate regions of
            the country are loaded.
       year : int, optional
           Year of the data, by default 2019
       simplified: boolean, by default True
           Data 'type', indicating whether the function returns the 'original' dataset
           with high resolution or a dataset with 'simplified' borders (Default)
       verbose : bool, optional
           by default False

       Returns
       -------
       gpd.GeoDataFrame
           Metadata and geopackage of selected states

       Raises
       ------
       Exception
           If parameters are not found or not well defined

       Example
       -------
       >>> from geobr import read_intermediate_region

       # Read specific state at a given year
       >>> df = read_intermediate_region(year=2019)
    """

    metadata = select_metadata("intermediate_regions", year=year, simplified=simplified)

    gdf = download_gpkg(metadata)

    if code_intermadiate == "all":
        return gdf

    for col in ["abbrev_state", "code_state", "code_intermediate"]:
        if code_intermadiate in gdf[col].unique():
            return gdf[gdf[col] == code_intermadiate]
    else:
        raise ValueError(
            f"Invalid value to argumet `code_intermadiate`: {code_intermadiate}"
        )
