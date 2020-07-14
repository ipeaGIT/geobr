from geobr.utils import select_metadata, download_gpkg


def read_weighting_area(
    code_weighting="all", year=2010, simplified=True, verbose=False
):
    """ Download shape files of Census Weighting Areas (area de ponderacao) of the Brazilian Population Census.
    
     Only 2010 data is currently available.

    Parameters
    ----------
    code_weighting:
        The 7-digit code of a Municipality. If the two-digit code or a two-letter uppercase abbreviation of
        a state is passed, (e.g. 33 or "RJ") the function will load all weighting areas of that state. 
        If code_weighting="all", all weighting areas of the country are loaded.
    year : int, optional
        Year of the data, by default 2010
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
    >>> from geobr import read_weighting_area

    # Read specific state at a given year
    >>> df = read_weighting_area(year=2010)
    """

    metadata = select_metadata("weighting_area", year=year, simplified=simplified)

    if code_weighting == "all":

        if verbose:
            print("Loading data for the whole country. This might take a few minutes.")

        return download_gpkg(metadata)

    metadata = metadata[
        metadata[["code", "code_abrev"]].apply(
            lambda x: str(code_weighting)[:2] in str(x["code"])
            or str(code_weighting)[:2]  # if number e.g. 12
            in str(x["code_abrev"]),  # if UF e.g. RO
            1,
        )
    ]

    if not len(metadata):
        raise Exception("Invalid Value to argument code_weighting.")

    gdf = download_gpkg(metadata)

    if len(str(code_weighting)) == 2:
        return gdf

    elif code_weighting in gdf["code_muni"].tolist():
        return gdf.query(f"code_muni == {code_weighting}")

    elif code_weighting in gdf["code_weighting"].tolist():
        return gdf.query(f"code_weighting == {code_weighting}")
    return gdf
