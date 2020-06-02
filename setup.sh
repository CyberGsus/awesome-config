#!/bin/sh

# check for python

setup_env() {
    set +x
    source venv/bin/activate

    echo "Installing requirements..."
    python -m pip install -U pip setuptools wheel
    pip install -U pycairo pysvg
    deactivate
}
if ! [ -d venv ]; then
    command -v python3 > /dev/null 2>&1 || (echo 'Python not installed!';  exit 1 )
    # check for installation path
    sc_PYTHON=`find /usr/bin | grep 'python3$' | cut -d$'\n' -f1`

    echo "Python installed at $sc_PYTHON"

    echo "Installing necessary tools..."
    $sc_PYTHON -m pip install -U --user virtualenv

    echo "Producing virtualenv..."
    $sc_PYTHON -m virtualenv venv


    echo "Cleaning up..."
    rm -rf ${XDG_CACHE_HOME:-$HOME/.cache}/pip
fi
setup_env
