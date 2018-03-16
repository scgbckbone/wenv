#!/usr/bin/env bash

# Using the VIRTUAL_ENV environment variable is not reliable.
# It is set by the virtualenv activate shell script, but a virtualenv
# can be used without activation by directly
# running an executable from the virtualenv's bin/ (or Scripts) directory,
# in which case $VIRTUAL_ENV will not be set.

source "$HOME/.wenw/helpers.sh"
source "$HOME/.wenw/default_conf.sh"
source "$HOME/.wenw/user_conf.sh"


wenv_active_environment () {
    if [ -z "$VIRTUAL_ENV" ]; then
        return 1
    else
        return 0
    fi
}


wenv_install () {
    to_install=($@)
    if ! wenv_active_environment; then
        echo "Not in virtualenv. quiting"
        exit 1
    else
        for i in "${to_install[@]}"; do
            "$VIRTUAL_ENV/bin/pip" install "$i" &&
            echo "$i" >> "$VIRTUAL_ENV/requirements.txt"
        done
    fi
}


wenv_active_sys_real_prefix () {
    python "$HOME/$HIDDEN_DIR_NAME/venv_active.py"
    return $?
}


wenv_versioned_requirements () {
    option="$(trim $1)"

    [[ "$option" == "write" ]] &&
    rm -f "$VIRTUAL_ENV/versioned_requirements.txt"

    if ! wenv_active_environment; then
        echo "Not in virtualenv. quiting"
        exit 1
    fi
    pip_freeze=$("$VIRTUAL_ENV/bin/pip" freeze)
    while read -u 10 p; do
        res=$(echo "$pip_freeze" | grep "$p")
        if [ -z "$res" ]; then
            continue
        fi
        [[ "$option" == "write" ]] &&
        echo "$res" >> "$VIRTUAL_ENV/versioned_requirements.txt"

        [ "$option" -ne "write" ] &&
        echo "$res"

    done 10<"$VIRTUAL_ENV/requirements.txt"

    [[ "$option" == "write" ]] &&
    echo "Created versioned requirements file "$VIRTUAL_ENV/versioned_requirements.txt""
}


wenv_requirements_echo () {
    cat "$VIRTUAL_ENV/requirements.txt"
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


wenv_activate () {
    name=$1
    . "$BASE_DIR_LOCATION/$name/bin/activate"
}


wenv_log () {
    message=$1
	now=$(date +'%Y-%m-%d %H:%M:%S')
	log=`echo -e "$now\t$message"`
	echo "$log" >> "$HOME/$HIDDEN_DIR_NAME/$LOG_FILE_NAME"
}


wenv_help () {
    echo "Usage: wenw [exec option] [args]"
    echo "wenw $WENW_VERSION"
    echo
    echo "wenw is a simple virtualenv wrapper, that reliefs one from unnecessary"
    echo "actions as:"
    echo "   - holds all venv in one location"
    echo "   - activation just by name"
    echo "   - activates virtual env after it is created"
    echo "   - writes clean requirements file with only those dependencies"
    echo "     that you actually installed (like pip freeze but lists only "
    echo "     the packages that are not dependencies of installed packages)"
    echo "   - logs creation and deletion of virtual envs created with wenv"
    echo
    echo "Exec options:"
    echo "   -a, --activate, activate   Activates venv just by its name."
    echo "   -m, --make, make           Creates venv and activate it."
    echo "   -i, --install, install     Uses pip in activated venv and installs."
    echo "   -l, --log, log             Log whatever to '~/.wenv/wenv.log."
    echo "   -p, --purge, purge         Deletes and deactivated currently active venv."
    echo
    echo "README: www.github.com/"
    return 0
}


wenw () {
    all_args=("$@")

    exec_arg="${all_args[0]}"
    rest_args="${all_args[@]:1}"

    case "$exec_arg" in
        -a|--activate|activate)
        wenv_activate "$rest_args"
        ;;
        -i|--install|install)
        wenv_install "$rest_args"
        ;;
        -m|--make|make)
        wenv_make "$rest_args"
        ;;
        -l|--log|log)
        wenv_log "$rest_args"
        ;;
        -p|--purge|purge)
        wenv_purge
        ;;
        -h|--help|help)
        wenv_help
        ;;
        -v|--version|version)
        echo "wenw $WENW_VERSION"
        ;;
        -r|req)
        wenv_requirements_echo
        ;;
        -vr|vreq)
        wenv_versioned_requirements "$rest_args"
        ;;
        *)
        echo "unknown option '$exec_arg'" 1>&2
        echo
        wenv_help
        ;;
    esac
}