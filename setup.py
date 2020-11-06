"""Setup.py for the project."""

from app_deployment_manager import services
import os, shutil
from setuptools import find_packages, setup, Command

my_dir = os.path.dirname(os.path.realpath(__file__))

try:
    with open(os.path.join(my_dir, 'README.md'), encoding='utf-8') as f:
        long_description = f.read()
except FileNotFoundError:
    long_description = ''


class CleanCommand(Command):
    """
    Command to tidy up the project root.
    Registered as cmdclass in setup() so it can be called with ``python setup.py extra_clean``.
    """

    description = "Tidy up the project root"
    user_options = []  # type: List[str]

    def initialize_options(self):
        """Set default values for options."""

    def finalize_options(self):
        """Set final values for options."""

    def run(self):  # noqa
        """Run command to remove temporary files and directories."""
        os.chdir(my_dir)
        for path in ['./build', './*.pyc', './*.tgz', './*.egg-info']:
            shutil.rmtree(path, ignore_errors=True)
        # os.system('rm -vrf ./build ./*.pyc ./*.tgz ./*.egg-info')


class RenameCommand(Command):
    """
    Command to tidy up the project root.
    Registered as cmdclass in setup() so it can be called with ``python setup.py extra_clean``.
    """

    description = "Tidy up the project root"
    user_options = []  # type: List[str]

    def initialize_options(self):
        """Set default values for options."""

    def finalize_options(self):
        """Set final values for options."""

    def run(self):  # noqa
        """Run command to remove temporary files and directories."""
        os.chdir(os.path.join(my_dir, 'dist'))
        os.system('mv app_deployment_manager-1.0.0.dev1-py38-none-any.whl app_deployment_manager.whl')


def do_setup():
    setup(
        name='app_deployment_manager',
        description='Manages python web app deployments in containers',
        long_description=long_description,
        long_description_content_type='text/markdown',
        version='1.0.0.dev1',
        include_package_data=True,
        zip_safe=False,
        packages=find_packages(include=[
            'app_deployment_manager', 
            'app_deployment_manager.*', 
            'app_deployment_manager.services',
            'app_deployment_manager.services.*',
            'app_deployment_manager.services.streamlit_deployment_service'
            ]),
        scripts=['bin/adm', 'bin/start_dev'],
        install_requires=[
            'click==7.1.2',
            'Flask==1.1.2',
            'Flask-WTF==0.14.3',
            'gitdb==4.0.5',
            'GitPython==3.1.11',
            'gunicorn==20.0.4',
            'itsdangerous==1.1.0',
            'Jinja2==2.11.2',
            'MarkupSafe==1.1.1',
            'python-dotenv==0.14.0',
            'Send2Trash==1.5.0',
            'smmap==3.0.4',
            'Werkzeug==1.0.1',
            'WTForms==2.3.3',
        ],
        setup_requires=[
            'setuptools',
            'wheel',
        ],
        python_requires='>=3.6',
        cmdclass={
            'extra_clean': CleanCommand,
            'rename': RenameCommand
        },
    )


if __name__ == "__main__":
    do_setup()
