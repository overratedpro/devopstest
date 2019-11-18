.virtualenv:
	@python3 -m venv $@
	@echo 'Now install python libs with: "make requirements"'

requirements: .virtualenv
	@. .virtualenv/bin/activate && pip3 install -r requirements.txt

ubuntu:
	@vagrant up

clean:
	@-vagrant destroy -f
	@-rm -fr .virtualenv

.PHONY: requirements ubuntu clean
