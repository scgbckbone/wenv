#!/usr/bin/env bash


wenv () {
	ENVNAME=$1
	PYVERSION=$2
	LOCATION=$3
	ACTIVATE=$4

	if [ -z "$ENVNAME" ]; then
	    exit 1
	fi
	if [ -z "$PYVERSION" ]; then
	    PYVERSION="python3.6"
	fi
	if [ -z "$LOCATION" ]; then
	    LOCATION="/virtual_envs"
	fi
	if [ -z "$ACTIVATE" ]; then
	    ACTIVATE=true
	fi

	echo "env name: $ENVNAME"
	echo "py version: $PYVERSION"
	echo "env location: $LOCATION"
	echo "activate: $ACTIVATE"
	echo

	# basic logging
	now=$(date + '%Y-%m-%d %H:%M:%S')
	log=`echo -e "$now\t$ENVNAME\t$PYVERSION\t$LOCATION\taoi: $ACTIVATE"`
	echo "$log" >> ~/virtual_envs/myenv.log

	if [[ "$ACTIVATE" == true ]]; then
		virtualenv "$HOME/$LOCATION/$ENVNAME" --python="$PYVERSION" &&
		. "$HOME/$LOCATION/$ENVNAME/bin/activate"
	else
	    virtualenv "$HOME/$LOCATION/$ENVNAME" --python="$PYVERSION"
	fi
}