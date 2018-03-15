#!/usr/bin/env bash

source $HOME/.wenv/default_conf.sh
source $HOME/.wenv/user_conf.sh


wenv_install () {
    :
}


wenv_purge () {
    :
}


wenv_make () {
    all_args=($@)
    name="${all_args[0]}"
    rest_args="${all_args[@]:1}"
    if [ -z "$rest_args" ]; then
        virtualenv "$BASE_DIR_LOCATION/$name" &&
        . "$BASE_DIR_LOCATION/$name/bin/activate"
    else
        virtualenv "$rest_args" "$BASE_DIR_LOCATION/$name" &&
        . "$BASE_DIR_LOCATION/$name/bin/activate"
	fi
#	wenv_log "$name    $rest_args    created"
}


wenv_deactivate () {
    echo "deactivate fuck"
    echo "base dir location $BASE_DIR_LOCATION"
    echo $?
}


wenv_log () {
    message=$1
	now=$(date +'%Y-%m-%d %H:%M:%S')
	log=`echo -e "$now\t$message"`
	echo "$log" >> "$HOME/.wenv/$LOG_FILE_NAME"
}


wenv () {
    all_args=("$@")

    exec_arg="${all_args[0]}"
    rest_args="${all_args[@]:1}"

    case "$exec_arg" in
        -i|--install|install)
        echo "install"
        ;;
        -m|--make|make)
        wenv_make "$rest_args"
        ;;
        -d|--deactivate|deactivate)
        wenv_deactivate
        ;;
        -p|--purge|purge)
        echo "purge"
        ;;
        *)
        echo "unknown option '$exec_arg'"
        # define help
        ;;
    esac

#	ENVNAME=$1
#	PYVERSION=$2
#	LOCATION=$3
#	ACTIVATE=$4
#
#	if [ -z "$ENVNAME" ]; then
#	    exit 1
#	fi
#	if [ -z "$PYVERSION" ]; then
#	    PYVERSION="python3.6"
#	fi
#	if [ -z "$LOCATION" ]; then
#	    LOCATION="/virtual_envs"
#	fi
#	if [ -z "$ACTIVATE" ]; then
#	    ACTIVATE=true
#	fi
#
#	echo "env name: $ENVNAME"
#	echo "py version: $PYVERSION"
#	echo "env location: $LOCATION"
#	echo "activate: $ACTIVATE"
#	echo
#
#	# basic logging
#	now=$(date + '%Y-%m-%d %H:%M:%S')
#	log=`echo -e "$now\t$ENVNAME\t$PYVERSION\t$LOCATION\taoi: $ACTIVATE"`
#	echo "$log" >> ~/virtual_envs/myenv.log
#
#	if [[ "$ACTIVATE" == true ]]; then
#		virtualenv "$HOME/$LOCATION/$ENVNAME" --python="$PYVERSION" &&
#		. "$HOME/$LOCATION/$ENVNAME/bin/activate"
#	else
#	    virtualenv "$HOME/$LOCATION/$ENVNAME" --python="$PYVERSION"
#	fi
}