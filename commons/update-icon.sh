#!/bin/sh

source $HOME/.config/awesome/venv/bin/activate
python $HOME/.config/awesome/commons/update-icon $@
deactivate
