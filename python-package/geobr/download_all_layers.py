import os
from geobr import (
    read_country, read_region, read_state, read_meso_region,
    read_micro_region, read_intermediate_region, read_immediate_region,
    read_municipality, read_municipal_seat, read_weighting_area,
    read_census_tract, read_statistical_grid, read_metro_area,
    read_urban_area, read_amazon, read_biomes, read_conservation_units,
    read_disaster_risk_area, read_indigenous_land, read_semiarid,
    read_health_facilities, read_health_region, read_neighborhood,
    read_schools, read_comparable_areas, read_urban_concentrations,
    read_pop_arrangements
)

def download_all_layers(output_folder="geobr_layers", driver="GeoJSON"):
    """
    Downloads all available geographic layers from geobr using their most recent year
    and saves them to the specified output folder.
    
    Parameters
    ----------
    output_folder : str, optional
        Folder where the layers will be saved, by default "geobr_layers"
    driver : str, optional
        The OGR format driver to use for saving the files. Options are:
        - 'GeoJSON' (default)
        - 'GPKG' (GeoPackage)
        
    Raises
    ------
    ValueError
        If the specified driver is not supported
    """
    # Validate driver
    valid_drivers = ["GEOJSON", "GPKG"]
    if driver.upper() not in valid_drivers:
        raise ValueError(f"Invalid driver: {driver}. Must be one of: {', '.join(valid_drivers)}")
    # Create output folder if it doesn't exist
    os.makedirs(output_folder, exist_ok=True)
    
    # Dictionary with function names
    layers = {
        'country': read_country,
        'region': read_region,
        'state': read_state,
        'meso_region': read_meso_region,
        'micro_region': read_micro_region,
        'intermediate_region': read_intermediate_region,
        'immediate_region': read_immediate_region,
        'municipality': read_municipality,
        'municipal_seat': read_municipal_seat,
        'weighting_area': read_weighting_area,
        'census_tract': read_census_tract,
        'statistical_grid': read_statistical_grid,
        'metro_area': read_metro_area,
        'urban_area': read_urban_area,
        'amazon': read_amazon,
        'biomes': read_biomes,
        'conservation_units': read_conservation_units,
        'disaster_risk_area': read_disaster_risk_area,
        'indigenous_land': read_indigenous_land,
        'semiarid': read_semiarid,
        'health_facilities': read_health_facilities,
        'health_region': read_health_region,
        'neighborhood': read_neighborhood,
        'schools': read_schools,
        'comparable_areas': read_comparable_areas,
        'urban_concentrations': read_urban_concentrations,
        'pop_arrangements': read_pop_arrangements
    }
    
    # Download each layer
    for name, func in layers.items():
        print(f"Downloading {name}...")
        try:
            # Download the layer using default year
            gdf = func()
            
            # Set file extension based on driver
            if driver.upper() == "GEOJSON":
                ext = ".geojson"
            elif driver.upper() == "GPKG":
                ext = ".gpkg"
            else:
                ext = ".geojson"  # default to geojson
                
            # Save to file
            output_file = os.path.join(output_folder, f"{name}{ext}")
            gdf.to_file(output_file, driver=driver)
            print(f"✓ Successfully saved {name} to {output_file}")
            
        except Exception as e:
            print(f"✗ Error downloading {name}: {str(e)}")
            continue

if __name__ == "__main__":
    # Download all layers to a folder called 'geobr_layers'
    download_all_layers()
