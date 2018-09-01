agent.pex: agent/requirements.txt agent/agent/__init__.py agent/bin/agent agent/setup.py
	cd agent && pipenv run pex -D . -o ../$@ -r requirements.txt -v --entry-point agent:main

agent/requirements.txt: agent/Pipfile.lock
	cd agent && pipenv lock -r > requirements.txt
