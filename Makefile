.virtualenv:
	@python3 -m venv $@
	@echo 'Now install python libs and galaxy roles with: "make requirements"'

requirements: .virtualenv
	@. .virtualenv/bin/activate \
		&& pip3 install -r requirements.txt \
		&& ansible-galaxy install -r galaxy_requirements.yml

ubuntu:
	@vagrant up --provision

clean:
	@-vagrant destroy -f
	@-rm -fr .virtualenv

.PHONY: requirements ubuntu clean
