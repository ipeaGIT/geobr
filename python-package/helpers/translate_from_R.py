from jinja2 import Template
from itertools import takewhile
from pathlib import Path
import sys
import re

def get_R_parameters(config, path=Path('../r-package/R/')):
    
    r_code = open(path / f'{config["name"]}.R', 'r').read()
    
    config['first_liner'] = r_code.split('\n')[0].strip('#\'')
    
    config['documentation'] = '\n'.join([s.strip('#\'') for s in (takewhile(lambda x: x != '#\'', r_code.split('\n')[2:]))])
    
    config['default_year'] = [re.search(r'\d+', s).group(0) for s in r_code.split('\n') if '@param year' in s][0]
    
    config['metadata_key'] = [re.search(r'"([A-Za-z0-9_\./\\-]*)"', s).group(0).strip('"') 
                              for s in r_code.split('\n') if 'download_metadata(geography=' in s][0]
    
    return config

def create_file_from_template(kind, config, path=Path('helpers/template')):
    
    temp = open(path / (kind + '.py'), 'r').read()
    
    temp = Template(temp).render(**config)
    
    if kind == 'function':
        open(f'geobr/{config["name"]}.py', 'w').write(temp)
    
    elif kind == 'test':
        open(f'tests/test_{config["name"]}.py', 'w').write(temp)

def main(name):
    
    config = {'name': name}
    
    try: 
        config = get_R_parameters(config)
    
    except FileNotFoundError:
        raise Exception(f'Function {name} was not implemented in R')
    
    create_file_from_template('function', config)
    create_file_from_template('test', config)
    
    open('geobr/__init__.py', 'a').write(f'\npythonfrom .{name} import {name}')
    
    return config

if __name__ == '__main__':

    main(sys.argv[1])