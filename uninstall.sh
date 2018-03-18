#!/usr/bin/env bash

source $HOME/.wenv/default_conf.sh
source $HOME/.wenv/user_conf.sh

PURGE=$1

if [[ "$PURGE" == "--purge" ]]; then
    rm -rf "$BASE_DIR_LOCATION"
fi

rm -rf "$HOME/$HIDDEN_DIR_NAME"

# remove from bash aliases if something there


# remove from .bashrc if something was written there - remove all
# this program have written to it

