#!/usr/bin/env bash

source $HOME/.wenv/default_conf.sh
source $HOME/.wenv/user_conf.sh


wenv_install () {
    to_install=($@)
    if [ -z "$VIRTUAL_ENV" ]; then
        echo "Not in virtualenv. quiting"
    else
        for i in "${to_install[@]}"; do
            "$VIRTUAL_ENV/bin/pip" install "$i" &&
            echo "$i" >> "$VIRTUAL_ENV/requirements.txt"
        done
    fi
}


wenv_purge () {
    rm -rf "$VIRTUAL_ENV" &&
    wenv_log "$VIRTUAL_ENV    deleted"
    echo "Deleted $VIRTUAL_ENV"
    deactivate
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
	wenv_log "$name    $rest_args    created"

	touch "$BASE_DIR_LOCATION/$name/requirements.txt" &&
	echo "Created empty requirements file $BASE_DIR_LOCATION/$name/requirements.txt"
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
        wenv_install "$rest_args"
        ;;
        -m|--make|make)
        wenv_make "$rest_args"
        ;;
        -d|--deactivate|deactivate)
        wenv_deactivate
        ;;
        -p|--purge|purge)
        wenv_purge
        ;;
        *)
        echo "unknown option '$exec_arg'"
        # define help
        ;;
    esac
}