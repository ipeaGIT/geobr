from geobr.utils import select_metadata, download_gpkg


def read_health_region(year=2013, macro=False, simplified=True, verbose=False):
    """Download official data of Brazilian health regions as an sf object.

        @param year Year of the data (defaults to 2013, latest available)
    @param simplified Logic FALSE or TRUE, indicating whether the function returns the
     data set with 'original' resolution or a data set with 'simplified' borders (Defaults to TRUE).
     For spatial analysis and statistics users should set simplified = FALSE. Borders have been
     simplified by removing vertices of borders using st_simplify{sf} preserving topology with a dTolerance of 100.
    @param showProgress Logical. Defaults to (TRUE) display progress bar
    @param tp Argument deprecated. Please use argument 'simplified

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
