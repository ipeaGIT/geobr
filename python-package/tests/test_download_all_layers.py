import os
import shutil
import geopandas as gpd
import pytest
from geobr.download_all_layers import download_all_layers

def test_download_all_layers():
    # Create a temporary test directory
    test_dir = "test_geobr_layers"
    
    try:
        # Test with default parameters (GeoJSON driver)
        download_all_layers(output_folder=test_dir)
        
        # Check if directory was created
        assert os.path.exists(test_dir)
        
        # Check if at least some key files were created with correct format
        key_layers = ['country', 'state', 'municipality']
        for layer in key_layers:
            file_path = os.path.join(test_dir, f"{layer}.geojson")
            assert os.path.exists(file_path)
            
            # Try reading the file to ensure it's valid
            gdf = gpd.read_file(file_path)
            assert isinstance(gdf, gpd.GeoDataFrame)
            assert not gdf.empty
        
        # Test with GPKG driver
        gpkg_dir = "test_geobr_layers_gpkg"
        download_all_layers(output_folder=gpkg_dir, driver="GPKG")
        
        # Check if directory was created
        assert os.path.exists(gpkg_dir)
        
        # Check if files were created with correct format
        for layer in key_layers:
            file_path = os.path.join(gpkg_dir, f"{layer}.gpkg")
            assert os.path.exists(file_path)
            
            # Try reading the file to ensure it's valid
            gdf = gpd.read_file(file_path)
            assert isinstance(gdf, gpd.GeoDataFrame)
            assert not gdf.empty
            
    finally:
        # Clean up test directories
        if os.path.exists(test_dir):
            shutil.rmtree(test_dir)
        if os.path.exists(gpkg_dir):
            shutil.rmtree(gpkg_dir)

def test_download_all_layers_invalid_driver():
    with pytest.raises(ValueError, match="Invalid driver"):
        download_all_layers(driver="INVALID_DRIVER")
