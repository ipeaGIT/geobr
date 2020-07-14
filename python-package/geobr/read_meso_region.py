from geobr.utils import select_metadata, download_gpkg


def read_meso_region(code_meso="all", year=2010, simplified=True, verbose=False):
    """ Download shape files of meso region as sf objects. Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)
    
     Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)

    Parameters
    ----------
    code_meso: int or string, by default 'all' 
        The 4-digit code of a meso region. If the two-digit code or a two-letter uppercase abbreviation of
        a state is passed, (e.g. 33 or "RJ") the function will load all meso regions of that state. 
        If code_meso="all", all meso regions of the country are loaded.
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
    >>> from geobr import read_meso_region

    # Read specific meso region at a given year
    >>> df = read_meso_region(code_meso=3301, year=2018)

    # Read all meso regions of a state at a given year
    >>> df = read_meso_region(code_meso=12, year=2017)
    >>> df = read_meso_region(code_meso="AM", year=2000)

    # Read all meso regions of the country at a given year
    >>> df = read_meso_region(code_meso="all", year=2010)
    """

    metadata = select_metadata("meso_region", year=year, simplified=simplified)

    if code_meso == "all":

        if verbose:
            print("Loading data for the whole country. This might take a few minutes.")

        return download_gpkg(metadata)

    metadata = metadata[
        metadata[["code", "code_abrev"]].apply(
            lambda x: str(code_meso)[:2] in str(x["code"])
            or str(code_meso)[:2]  # if number e.g. 12
            in str(x["code_abrev"]),  # if UF e.g. RO
            1,
        )
    ]

    if not len(metadata):
        raise Exception("Invalid Value to argument code_meso.")

    gdf = download_gpkg(metadata)

    if len(str(code_meso)) == 2:
        return gdf

    elif code_meso in gdf["code_meso"].tolist():
        return gdf.query(f"code_meso == {code_meso}")

    else:
        raise Exception("Invalid Value to argument code_meso.")
