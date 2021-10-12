"""Setup.py for the project."""

import os
import shutil

from setuptools import Command, find_packages, setup

my_dir = os.path.dirname(os.path.realpath(__file__))

try:
    with open(os.path.join(my_dir, "README.md"), encoding="utf-8") as f:
        long_description = f.read()
except FileNotFoundError:
    long_description = ""

try:
    with open("requirements.txt") as f:
        required_packages = f.read().splitlines()
except FileNotFoundError:
    required_packages = []


class CleanCommand(Command):
    """
    Command to tidy up the project root.
    Registered as cmdclass in setup() so it can be called with ``python setup.py extra_clean``.
    """

    def initialize_options(self):
        """Set default values for options."""

    def finalize_options(self):
        """Set final values for options."""

    def run(self):  # noqa
        """Run command to remove temporary files and directories."""
        os.chdir(my_dir)
        for path in ["./build", "./*.pyc", "./*.tgz", "./*.egg-info"]:
            shutil.rmtree(path, ignore_errors=True)
        # os.system('rm -vrf ./build ./*.pyc ./*.tgz ./*.egg-info')


class RenameCommand(Command):
    """
    Command to tidy up the project root.
    Registered as cmdclass in setup() so it can be called with ``python setup.py rename``.
    """

    def initialize_options(self):
        """Set default values for options."""

    def finalize_options(self):
        """Set final values for options."""

    def run(self):  # noqa
        """Run command to remove temporary files and directories."""
        os.chdir(os.path.join(my_dir, "dist"))
        os.system(
            "mv app_deployment_manager-1.0.0.dev1-py38-none-any.whl app_deployment_manager.whl"
        )


def do_setup():
    setup(
        name="app",
        description="Provide the description",
        long_description=long_description,
        long_description_content_type="text/markdown",
        version="1.0.0.dev1",
        include_package_data=True,
        zip_safe=False,
        packages=find_packages(
            include=["app", "app.*", "app.blueprint1", "app.blueprint1.*"]
        ),
        scripts=["bin/adm", "bin/start_dev"],
        install_requires=required_packages,
        setup_requires=[
            "setuptools",
            "wheel",
        ],
        python_requires=">=3.6",
        cmdclass={"extra_clean": CleanCommand, "rename": RenameCommand},
    )


if __name__ == "__main__":
    do_setup()
