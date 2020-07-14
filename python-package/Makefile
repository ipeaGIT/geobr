build-env-dev:
	python3 -m venv .venv;
	. .venv/bin/activate; pip install -r requirements-dev.txt; 

update-env:
	. .venv/bin/activate; pip install -r requirements-dev.txt;

prepare-push:
	black .

publish:
	@rm -rf dist
	@rm -rf geobr.egg-info
	@cp ../README.md master-README.md
	@python setup.py sdist
	@twine upload dist/*