import requests
import geopandas as gpd
import pandas as pd
import os
import tempfile
import sys
import fiona


def read_state(code_state, year=None, mode="simplified"):

    # Get metadata with data addresses
    metadata = download_metadata()

    # Select geo
    temp_meta = metadata.query('geo=="uf"')

    # Select mode
    if mode == "simplified":
        temp_meta = temp_meta[temp_meta["download_path"].str.contains("simplified")]
    elif mode == "normal":
        temp_meta = temp_meta[~temp_meta["download_path"].str.contains("simplified")]
    else:
        print("not a valid argument for mode")

    # Verify year input
    if year is None:
        print("Using data from year 2010\n")
        year = 2010
        temp_meta = temp_meta[temp_meta.year == 2010]
    elif year in temp_meta.year.unique():
        temp_meta = temp_meta[temp_meta.year == year]
    else:
        print(
            "Error: Invalid Value to argument 'year'. It must be one of the following: ",
            temp_meta["year"].unique(),
        )
        sys.exit()

    # BLOCK 2.1 From 1872 to 1991  ----------------------------
    if year < 1992:
        if code_mun is None:
            sys.exit("Value to argument 'code_state' cannot be NULL")
        print("Loading data for the whole country\n")

        # list paths of files to download
        filesD = temp_meta.download_path.astype(str)

        temp_sf = gpd.read_file(filesD.iloc[0])

        return temp_sf

    else:
        # BLOCK 2.2 From 2000 onwards  ----------------------------

        # Verify code_state input

        # Test if code_state input is null
        if code_state is None:
            sys.exit("Value to argument 'code_state' cannot be NULL")

        if code_state == "all":
            print("Loading data for the whole country\n")

            # read files and pile them up

            filesD = list(temp_meta.download_path.astype(str))

            temp_sf = list()

            for fp in filesD:

                gdf = gpd.read_file(fp)

                temp_sf.append(gdf)

            temp_sf = gpd.GeoDataFrame(pd.concat(temp_sf, ignore_index=True))

            return temp_sf

        if (str(code_state)[0:2] not in temp_meta.code.unique()) and (
            str(code_state)[0:2] not in temp_meta.code_abrev.unique()
        ):

            sys.exit("Error: Invalid Value to argument code_state.")
        else:

            # list paths of files to download

            if isinstance(code_state, int):

                filesD = temp_meta[
                    temp_meta.code == str(code_state)[0:2]
                ].download_path.iloc[0]

            if isinstance(code_state, str):

                filesD = temp_meta[
                    temp_meta.code_abrev == str(code_state)[0:2]
                ].download_path.iloc[0]

            # download files

            temp_sf = gpd.read_file(filesD)

            if len(str(code_state)) == 2:

                return temp_sf

            else:

                sys.exit("Error: Invalid Value to argument code_state.")
