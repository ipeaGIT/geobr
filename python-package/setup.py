"""Setup geobr package."""

# coding: utf-8

import os
import pandas
import Shapely
import geopandas
from setuptools import setup


MAJOR = 0
MINOR = 1
MICRO = 0
VERSION = '%d.%d.%d' % (MAJOR, MINOR, MICRO)
ISRELEASED = True

setup_dir = os.path.abspath(os.path.dirname(__file__))


def write_version_py(filename=os.path.join(setup_dir, 'feather/version.py')):
    version = VERSION
    if not ISRELEASED:
        version += '.dev'

    a = open(filename, 'w')
    file_content = "\n".join(["",
                              "# THIS FILE IS GENERATED FROM SETUP.PY",
                              "version = '%(version)s'",
                              "isrelease = '%(isrelease)s'"])

    a.write(file_content % {'version': VERSION,
                            'isrelease': str(ISRELEASED)})
    a.close()

write_version_py()

LONG_DESCRIPTION = "Easy access to official spatial data sets of Brazil in Python. The package includes a wide range of geospatial data available at various geographic scales and for various years with harmonized attributes, projection and topology."
DESCRIPTION = "geobr: Loads Shapefiles of Official Spatial Data Sets of Brazil"

CLASSIFIERS = [
    'Intended Audience :: Science/Research',
    'Intended Audience :: Developers',
    'Intended Audience :: Education',
    'Topic :: Scientific/Engineering :: GIS',
    'Topic :: Scientific/Engineering :: Visualization',
    'Programming Language :: Python',
    'Programming Language :: Python :: 3.6',
    'Programming Language :: Python :: 3.7'
    ]


INSTALL_REQUIRES  = (
    'geopandas >= 0.7.0',
    'Shapely==1.7.0'
    )


setup(
    name="geobr",
    version=VERSION,
    description=DESCRIPTION,
    long_description=LONG_DESCRIPTION,
    license='MIT + file LICENSE.txt',
    classifiers=CLASSIFIERS,
    url='https://github.com/ipeaGIT/geobr'

    author              = 'João Carabetta, Rafael H. M. Pereira, Caio Nogueira Goncalves, Bernardo Furtado',
    author_email        = 'joa.carabetta @.... , rafa.pereira.br@gmail.com, caio.goncalves@ipea.gov.br, bernardo.furtado@ipea.gov.br'
    maintainer          = 'João Carabetta',
    maintainer_email    = 'joa.carabetta @....',

    packages=['geobr'],
    platforms='any',
    # package_data={'geobr': ['*.csv']},
    #include_package_data=True
    python_requires='>3.6',
    install_requires= INSTALL_REQUIRES
    tests_require=['pytest', 'Shapely', 'geopandas'],
    )
    
    
