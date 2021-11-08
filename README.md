# basic python project tempalte
    Folder structure template to structure a python project. Currently the structure mimics a flask project while it can be configured to simple python scripting or automation project with minimal change.

## Install make package
- MAC
    ```shell
    brew install make
    ```

- Windows
    - ```shell
      choco install make
      ```
    - Other recommended option is installing a Windows Subsystem for Linux (WSL/WSL2), so you'll have a Linux distribution of your choice embedded in Windows 10 where you'll be able to install make, gccand all the tools you need to build C programs.

- Ubuntu
    ```shell
    sudo apt-get install build-essential
    sudo apt-get update -y
    sudo apt-get install -y make
    ```

## Setup Environment
    ```shell
    make bootstrap
    ```
    ```shell
    make venv-activate
    ```
    ```shell
    make help
    ```

### Building the app from scratch
```shell
python3 setup.py bdist_wheel --python-tag py36 extra_clean
```
