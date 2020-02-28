build-env-dev:
	python3 -m venv .env;
	. .env/bin/activate; pip install -r requirements.txt; pip install pytest;

update-env:
	@. .env/bin/activate; pip freeze > requirements.txt