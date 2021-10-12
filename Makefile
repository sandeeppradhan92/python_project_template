#
# Configuration variables
#

PY?=python3
WORKDIR?=.
VENVDIR?=$(WORKDIR)/.venv
REQUIREMENTS_TXT?=requirements.txt
MARKER=.initialized-with-Makefile.venvx
# PACKAGE = Source code directory or leave empty
PACKAGE =
# TESTDIR = Test directory or '.' for current directory
TESTDIR = tests
REPORTDIR = $(WORKDIR)/.test_report

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
	@echo "--------------------------------HELP---------------------------------"
	@echo ""
	@echo "================================Setup================================"
	@echo ""
	@echo "make bootstrap       :- To setup the project type"
	@echo "make show-venv       :- To show virtual environment details"
	@echo ""
	@echo "===============================Formating============================="
	@echo ""
	@echo "make lint-check      :- To check linting [Default -> flake8]"
	@echo "                        workes same as make flake8"
	@echo "make lint            :- To check linting [Default -> black]"
	@echo "                        workes same as make black"
	@echo "make docstring       :- To check docstring format"
	@echo ""
	@echo "==========================Static analysis============================"
	@echo ""
	@echo "make test            :- To run unit test cases [Default -> pytest]"
	@echo "make pytest-basic    :- To run	unit test cases using pytest basic "
	@echo "                        report"
	@echo "make pytest          :- To run	unit test cases using pytest"
	@echo ""
	@echo "==============================Cleaning==============================="
	@echo ""
	@echo "make clean-env       :- To cleanup / clear full project folder"
	@echo "make clean-build     :- To cleanup / clear / delete build folder"
	@echo "make clean-test      :- To cleanup / clear / delete test folder"
	@echo "make clean-dist      :- To cleanup / clear / delete distribution "
	@echo "                        folder"
	@echo "---------------------------------------------------------------------"

##############################################################################
### Setup ####################################################################
##############################################################################
.PHONY: bootstrap venv-activate venv show-venv

bootstrap:
	$(PY) -m venv $(VENVDIR)
	$(VENV)/python -m pip install --upgrade pip
	$(VENV)/python -m pip install --upgrade setuptools wheel
	$(VENV)/python -m pip install -r requirements.txt
	$(VENV)/python -m pip install -r requirements-dev.txt
	$(VENV)/pre-commit install
	touch $(VENV)/$(MARKER)
	mkdir -p $(REPORTDIR)

venv-activate:
	$(VENVCMD)

venv: $(VENV)/$(MARKER)

show-venv: venv
	@$(VENV)/python -c "import sys; print('Python ' + sys.version.replace('\n',''))"
	$(VENV)/pip --version
	echo venv: $(VENVDIR)


##############################################################################
### Static Analysis & Travis CI ##############################################
##############################################################################
.PHONY: pylint flake8 docstring

lint: black

black:
	$(VENV)/black $(WORKDIR)

lint-check: flake8

flake8:
	$(VENV)/flake8 $(WORKDIR)

docstring:
	$(VENV)/python -m pydocstyle $(SOURCES)

##############################################################################
### Testing ##################################################################
##############################################################################
.PHONY: test pytest

test: pytest

pytest-basic:
	$(VENV)/py.test $(WORKDIR) --junitxml=$(REPORTDIR)/report-pytest.xml --html=$(REPORTDIR)/report-pytest.html --self-contained-html --cov-report=html:$(REPORTDIR)/coverage-pytest.html
pytest:
	$(VENV)/py.test $(WORKDIR) --junitxml=$(REPORTDIR)/report-pytest.xml --html-report=$(REPORTDIR)/report-pytest.html --cov-report=html:$(REPORTDIR)/coverage-pytest.html


##############################################################################
### Cleanup ##################################################################
##############################################################################
.PHONY: clean clean-env clean-all clean-build clean-test clean-dist

clean: clean-dist clean-test clean-build

clean-env: clean
	-@rm -rf $(VENVDIR)
	-@rm -rf .tox

clean-all: clean-env

clean-build:
	@find $(WORKDIR) -name '*.pyc' -delete
	@find $(WORKDIR) -name '__pycache__' -delete
	-@rm -rf $(WORKDIR)/build
	-@rm -rf $(WORKDIR)/*.pyc
	-@rm -rf $(WORKDIR)/*.tgz
	-@rm -rf $(WORKDIR)/*.egg-info
	-@rm -rf __pycache__

clean-test:
	-@rm -rf .cache
	-@rm -rf .coverage
	-@rm -rf .pytest_cache
	-@rm -rf .pytest_report
	-@rm -rf $(REPORTDIR)

clean-dist:
	-@rm -rf dist build
