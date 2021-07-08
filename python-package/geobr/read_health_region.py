from geobr.utils import select_metadata, download_gpkg


def read_health_region(year=2013, macro=False, simplified=True, verbose=False):
    """Download official data of Brazilian health regions as an sf object.

    Health regions are used to guide the the regional and state planning of health services.
    Macro health regions, in particular, are used to guide the planning of high complexity
    health services. These services involve larger economics of scale and are concentrated in
    few municipalities because they are generally more technology intensive, costly and face
    shortages of specialized professionals. A macro region comprises one or more health regions.

     Parameters
     ----------
     year : int, optional
         Year of the data, by default 2013
     macro: If `False` (default), the function downloads health regions data.
            If `True`, the function downloads macro regions data.
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
     >>> from geobr import read_health_region

     # Read specific state at a given year
     >>> df = read_health_region(year=2013)
    """

    if macro:
        metadata = select_metadata(
            "health_region_macro", year=year, simplified=simplified
        )
    else:
        metadata = select_metadata("health_region", year=year, simplified=simplified)

    gdf = download_gpkg(metadata)

    return gdf
