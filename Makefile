#
# Configuration variables
#

PY?=python3
APPLICATION_NAME?=test_app
TAG?=0.1
HOST_PORT?=8000
WORKDIR?=.
VENVDIR?=$(WORKDIR)/.venv
REQUIREMENTS_TXT?=requirements.txt
MARKER=.initialized-with-Makefile.venvx
# PACKAGE = Source code directory or leave empty
PACKAGE =
# TESTDIR = Test directory or '.' for current directory
TESTDIR = tests
REPORTDIR = $(WORKDIR)/.test_report
K8S_BUILD_DIR?=dev
#
# Internal variable resolution
#

VENV=$(VENVDIR)/bin
EXE=
# Detect windows
ifeq (win32,$(shell $(PY) -c "import __future__, sys; print(sys.platform)"))
VENV=$(VENVDIR)/Scripts
EXE=.exe
endif

#
# Virtual env activate command
#
VENVCMD=cd $(VENVDIR)/bin && source activate
# Detect windows
ifeq (win32,$(shell $(PY) -c "import __future__, sys; print(sys.platform)"))
VENVCMD=$(VENVDIR)/Scripts/activate.bat
endif

#
# virtualenv executables
#
COVERAGE := $(VENV)/coverage


##############################################################################
### Helper ###################################################################
##############################################################################
# The @ makes sure that the command itself isn't echoed in the terminal
help:
	@echo "----------------------------------------------------HELP------------------------------------------------------------"
	@echo ""
	@awk '/^#/{c=substr($$0,3);next}c&&/^[[:alpha:]][[:alnum:]_-]+:/{print "make " substr($$1,1,index($$1,":")),c}1{c=0}' $(MAKEFILE_LIST) | column -s: -t
	@echo ""
	@echo "----------------------------------------------------HELP------------------------------------------------------------"


##############################################################################
### Setup ####################################################################
##############################################################################
.PHONY: bootstrap venv-activate venv show-venv

# To setup the projec from scratch
bootstrap:
	$(PY) -m venv $(VENVDIR)
	$(VENV)/python -m pip install --upgrade pip
	$(VENV)/python -m pip install --upgrade setuptools wheel
	$(VENV)/python -m pip install -r requirements.txt
	$(VENV)/python -m pip install -r requirements-dev.txt
	$(VENV)/pre-commit install
	touch $(VENV)/$(MARKER)
	mkdir -p $(REPORTDIR)

# To activate  virtual environment
venv-activate:
	$(VENVCMD)

venv: $(VENV)/$(MARKER)

# To show virtual environment details
show-venv: venv
	@$(VENV)/python -c "import sys; print('Python ' + sys.version.replace('\n',''))"
	$(VENV)/pip --version
	echo venv: $(VENVDIR)


##############################################################################
### Static Analysis & Travis CI ######################################################
##############################################################################
.PHONY: pylint flake8 docstring

# To fix  linting [Default -> black]  --> works same as make black
lint: black

# To fix lintig using black
black:
	$(VENV)/black $(WORKDIR)

# To check linting [Default -> flake8] -->  workes same as make flake8
lint-check: flake8

# To check linting using flake8
flake8:
	$(VENV)/flake8 $(WORKDIR)

# To check docstring forma
docstring:
	$(VENV)/python -m pydocstyle $(SOURCES)

##############################################################################
### Testing ####################################################################
##############################################################################
.PHONY: test pytest

# To run unit test cases [Default -> pytest]
test: pytest

# To run	unit test cases using pytest basic report
pytest-basic:
	$(VENV)/py.test $(WORKDIR) --junitxml=$(REPORTDIR)/report-pytest.xml --html=$(REPORTDIR)/report-pytest.html --self-contained-html --cov-report=html:$(REPORTDIR)/coverage-pytest.html

# To run	unit test cases using pytest
pytest:
	$(VENV)/py.test $(WORKDIR) --junitxml=$(REPORTDIR)/report-pytest.xml --html-report=$(REPORTDIR)/report-pytest.html --cov-report=html:$(REPORTDIR)/coverage-pytest.html


##############################################################################
### Build And Deployment #########################################################
##############################################################################
.PHONY: docker-build docker-run k8s-deploy k8s-delete k8s-build-dev k8s-build-stage k8s-build-prod

# Build docker image for the application
docker-build:
	docker rmi -f $(APPLICATION_NAME):$(TAG)
	docker build -t $(APPLICATION_NAME):$(TAG) .

# Run the built docker image as container
docker-run:
	docker rm -f $(APPLICATION_NAME)
	docker run -it --name $(APPLICATION_NAME) -p $(HOST_PORT):8000 $(APPLICATION_NAME):$(TAG)

# deploy all the yaml file present in k8s/manifests folder
k8s-deploy:
	kubectl apply -f k8s/manifests/

k8s-deploy-dev:
	K8S_BUILD_DIR=dev
	kubectl apply -f k8s/manifests/auto_generate_$(K8S_BUILD_DIR)_deployment.yaml

k8s-deploy-stage:
	K8S_BUILD_DIR=staging
	kubectl apply -f k8s/manifests/auto_generate_$(K8S_BUILD_DIR)_deployment.yaml

k8s-deploy-prod:
	K8S_BUILD_DIR=production
	kubectl apply -f k8s/manifests/auto_generate_$(K8S_BUILD_DIR)_deployment.yaml

k8s-build-dev:
	K8S_BUILD_DIR=dev
	cd k8s && mkdir -p manifests && kubectl kustomize $(K8S_BUILD_DIR) >> manifests/auto_generate_$(K8S_BUILD_DIR)_deployment.yaml

k8s-build-stage:
	K8S_BUILD_DIR=staging
	cd k8s && mkdir -p manifests && kubectl kustomize $(K8S_BUILD_DIR) >> manifests/auto_generate_$(K8S_BUILD_DIR)_deployment.yaml

k8s-build-prod:
	K8S_BUILD_DIR=production
	cd k8s && mkdir -p manifests && kubectl kustomize $(K8S_BUILD_DIR) >> manifests/auto_generate_$(K8S_BUILD_DIR)_deployment.yaml

k8s-delete-dev:
	K8S_BUILD_DIR=dev
	kubectl delete -f k8s/manifests/auto_generate_$(K8S_BUILD_DIR)_deployment.yaml
	rm -f k8s/manifests/auto_generate_$(K8S_BUILD_DIR)_deployment.yaml

k8s-delete-stage:
	K8S_BUILD_DIR=staging
	kubectl delete -f  k8s/manifests/auto_generate_$(K8S_BUILD_DIR)_deployment.yaml
	rm -f k8s/manifests/auto_generate_$(K8S_BUILD_DIR)_deployment.yaml

k8s-delete-prod:
	K8S_BUILD_DIR=production
	kubectl delete -f k8s/manifests/auto_generate_$(K8S_BUILD_DIR)_deployment.yaml
	rm -f k8s/manifests/auto_generate_$(K8S_BUILD_DIR)_deployment.yaml

k8s-delete-all:
	kubectl delete -f k8s/manifests/
	rm -rf k8s/manifests

k8s-clean:
	rm -rf k8s/manifests

##############################################################################
### Cleanup ####################################################################
##############################################################################
.PHONY: clean clean-env clean-all clean-build clean-test clean-dist

clean: clean-dist clean-test clean-build

# To cleanup / clear full project folde
clean-env: clean
	-@rm -rf $(VENVDIR)
	-@rm -rf .tox

# same as clean-env
clean-all: clean-env

# To cleanup / clear / delete build folder
clean-build:
	@find $(WORKDIR) -name '*.pyc' -delete
	@find $(WORKDIR) -name '__pycache__' -delete
	-@rm -rf $(WORKDIR)/build
	-@rm -rf $(WORKDIR)/*.pyc
	-@rm -rf $(WORKDIR)/*.tgz
	-@rm -rf $(WORKDIR)/*.egg-info
	-@rm -rf __pycache__

# To cleanup / clear / delete test folder
clean-test:
	-@rm -rf .cache
	-@rm -rf .coverage
	-@rm -rf .pytest_cache
	-@rm -rf .pytest_report
	-@rm -rf $(REPORTDIR)

# To cleanup / clear / delete distribution folder
clean-dist:
	-@rm -rf dist build
