#
# Configuration variables
#

PY?=python3
WORKDIR?=.
VENVDIR?=$(WORKDIR)/.venv
REQUIREMENTS_TXT?=requirements.txt
MARKER=.initialized-with-Makefile.venv
REQUIREMENTS_LOG := .requirements.log
# PACKAGE = Source code directory or leave empty
PACKAGE =
# TESTDIR = Test directory or '.' for current directory
TESTDIR = tests

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

.PHONY: bootstrap venv
venv: $(VENV)/$(MARKER)

.DEFAULT_GOAL := test

# The @ makes sure that the command itself isn't echoed in the terminal
help:
	@echo "---------------HELP-----------------"
	@echo "To setup the project type make bootstrap"
	@echo "To test the project type make test"
	@echo "To run the project type make run"
  @echo "To clean pyc files from the project type make clean"
	@echo "------------------------------------"

##############################################################################
### Setup ####################################################################
##############################################################################

show-venv: venv
	@$(VENV)/python -c "import sys; print('Python ' + sys.version.replace('\n',''))"
	@$(VENV)/pip --version
	@echo venv: $(VENVDIR)
  
bootstrap:
  $(PY) -m venv $(VENVDIR)
	$(VENV)/python -m pip install --upgrade pip setuptools wheel
	${PIP} install -r requirements.txt
	${PIP} install -r requirements-dev.txt

##############################################################################
### Testing ##################################################################
##############################################################################
#test: $(REQUIREMENTS_LOG) $(TEST_RUNNER)
#	$(TEST_RUNNER) $(args) $(TESTDIR)

##############################################################################
### Cleanup ##################################################################
##############################################################################
.PHONY: clean clean-env clean-all clean-build clean-test clean-dist

clean: clean-dist clean-test clean-build

clean-env: clean
	-@rm -rf $(VENVDIR)
	-@rm -rf $(REQUIREMENTS_LOG)
	-@rm -rf .tox

clean-all: clean clean-env

clean-build:
	@find $(PKGDIR) -name '*.pyc' -delete
	@find $(PKGDIR) -name '__pycache__' -delete
	@find $(TESTDIR) -name '*.pyc' -delete 2>/dev/null || true
	@find $(TESTDIR) -name '__pycache__' -delete 2>/dev/null || true
	-@rm -rf $(EGG_INFO)
	-@rm -rf __pycache__

clean-test:
	-@rm -rf .cache
	-@rm -rf .coverage

clean-dist:
	-@rm -rf dist build


