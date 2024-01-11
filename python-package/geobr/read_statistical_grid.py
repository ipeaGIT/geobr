import sys
from geobr.utils import select_metadata, download_gpkg
from numpy import unique
from pandas import read_csv


def read_statistical_grid(code_grid="all", year=2010, simplified=False, verbose=False):
    r"""Download spatial data of IBGE's statistical grid

        @description
    Data at scale 1:250,000, using Geodetic reference system "SIRGAS2000" and CRS(4674)

       Parameters
       ----------
       code_grid:
           If two-letter abbreviation or two-digit code of a state is
           passed, the function will load all grid quadrants that
           intersect with that state. If `code_grid="all"`, the grid of
           the whole country will be loaded. Users may also pass a
           grid quadrant id to load an specific quadrant. Quadrant ids
           can be consulted at `grid_state_correspondence_table.csv`.
       year : int, optional
           Year of the data, by default 2010
       simplified: boolean, by default False
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
       >>> from geobr import read_statistical_grid

       # Read specific state at a given year
       >>> df = read_statistical_grid(year=2010)
    """

    temp_meta = select_metadata(
        geo="statistical_grid", year=year, simplified=simplified
    )

    if temp_meta is None:
        return None

    grid_state_correspondence_table = None

    with open("./geobr/data/grid_state_correspondence_table.csv", "rb") as file:
        dtypes = {"name_state": str, "abbrev_state": str, "code_grid": str}
        grid_state_correspondence_table = read_csv(
            file, encoding="latin-1", dtype=dtypes
        )

    # Test if code_grid input is null
    if code_grid == None:
        sys.exit("Value to argument 'code_grid' cannot be NULL")

    # if code_grid=="all", read the entire country
    if code_grid == "all":
        if verbose:
            print("Loading data for the whole country. This might take a few minutes.")

        file_url = temp_meta["download_path"]
        temp_gpd = download_gpkg(file_url)

        return temp_gpd

    # Select abbrev_state column
    grid_abbrev_state = grid_state_correspondence_table["abbrev_state"]

    # Error if the input does not match any state abbreviation
    if isinstance(code_grid, str) and not (code_grid in grid_abbrev_state.to_list()):
        sys.exit(
            "Error: Invalid Value to argument 'code_grid'. It must be one of the following: "
            + str(unique(grid_abbrev_state.to_numpy().tolist()))
        )

    # Valid state abbreviation
    elif isinstance(code_grid, str) and code_grid in grid_abbrev_state.to_list():
        # Find grid quadrants that intersect with the passed state abbreviation
        grid_state_correspondence_table_tmp = grid_state_correspondence_table[
            grid_state_correspondence_table["abbrev_state"] == code_grid
        ]

        # Strips 'ID_' from code_grid string and gets only the int code value
        grid_ids = [
            substr[substr.index("_") + 1 :]
            for substr in grid_state_correspondence_table_tmp["code_grid"].to_list()
        ]

        file_url = temp_meta[temp_meta["code"].isin(grid_ids)]
        temp_gpd = download_gpkg(file_url)

        return temp_gpd

    # If code_grid is int
    if isinstance(code_grid, int):
        # Converts to str to match the following queries
        code_grid = str(code_grid)

        # Single digit case: adds a leading 0 (ex: 4 -> 04)
        if len(code_grid) == 1:
            code_grid = "0" + code_grid

    if not (code_grid in temp_meta["code"].to_list()):
        sys.exit("Error: Invalid Value to argument code_grid.")

    else:
        # Filters by code then download a list of gpkg filtered paths
        file_url = temp_meta[temp_meta["code"].isin([code_grid])]
        temp_gpd = download_gpkg(file_url)

        return temp_gpd
