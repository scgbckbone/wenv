#!/usr/bin/env bash

# $1 is defining directory name where all virtualenv folders will reside
# together with wenv log file (wenv.log).
# You only need to specify the name of the directory.
# It will be created in your HOME location. If not specified, 'wenvs' directory
# will be created in user home directory or whatever the HOME environment
# variable is set.

# $2 is whether you want to create an alias in bash_aliases from virtualenv
# to wenv or any other name orvided as other parameter

DEFAULT_BASE_DIR_NAME="wenvs"
DEFAULT_ALIAS_NAME="wenv"
LOG_FILE_NAME="wenv.log"
NO_ALIASES="false"

CUSTOM_ALIAS_NAME=""
CUSTOM_BASE_DIR_NAME=""

while [[ $# -gt 0 ]]
do
key="$1"

case "$key" in
    -b|--base_dir)
    CUSTOM_BASE_DIR_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -l|--alias_name)
    CUSTOM_ALIAS_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    --no_aliases)
    NO_ALIASES="true"
    shift
    ;;
    *)
    shift
    shift
    ;;
esac
done

BASE_DIR=""
ALIAS_NAME=""


make_log_file () {
    base_dir=$1
    cd "$base_dir" &&
    touch "$LOG_FILE_NAME" &&
    echo "Log file created: $base_dir/$LOG_FILE_NAME"
}


make_base_dir () {
    base_dir=$1
    mkdir "$base_dir" &&
    echo "Base directory created: $base_dir" &&
    make_log_file "$base_dir"
}


file_exists () {
    FILE=$1
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}


touch_file () {
    FILE=$1
    touch "$FILE" &&
    echo "File '$FILE created."
}


append_bash_aliases () {
    alias_name=$1
    echo "alias $alias_name='virtualenv'" >> "$HOME/.bash_aliases"
}


is_bash_aliases_sourced_in_bashrc () {
    if grep -q '^[[:space:]]*\. ~/.bash_aliases' "$HOME/.bashrc"; then
        return 0
    else
        return 1
    fi
}


append_lines_to_bashrc () {
    lines=$1
    IFS="," read -r -a result <<< "$lines" && unset IFS
    for line in "${result[@]}"; do
        echo "$line" >> "$HOME/.bashrc"
    done
}


append_files_to_source_in_bashrc () {
    # file_abs_path has to be comma separated string of paths
    file_abs_path=$1
    conditional_f_name=$2

    echo '' >> "$HOME/.bashrc"

    [ -n "$conditional_f_name" ] &&
    echo "if [ -f $conditional_f_name ]; then" >> "$HOME/.bashrc" &&
    echo "Adding conditional - based on existence of file $conditional_f_name"

    append_lines_to_bashrc "$file_abs_path"

    [ -n "$conditional_f_name" ] &&
    echo "fi" >> "$HOME/.bashrc" &&
    echo "Conditional closed."
}




if [ -z "$(which virtualenv)" ]; then
    echo "Seems like you do not have 'virtualenv' installed." 1>&2
    echo "use 'sudo apt-get install virtualenv'"
    exit 1
fi

if [ ! -f "$HOME/.bashrc" ]; then
    echo "Cannot find '.bashrc' file in your HOME directory." 1>&2
    exit 1
fi

if [ -z "$HOME" ]; then
    echo "Your HOME variable is not defined." 1>&2
    exit 1
fi

if [ -n "$CUSTOM_BASE_DIR_NAME" ]; then
    if [ -d "$HOME/$CUSTOM_BASE_DIR_NAME" ]; then
        echo "Directory $HOME/$CUSTOM_BASE_DIR_NAME already exists." 1>&2
        exit 1
    else
        BASE_DIR="$HOME/$CUSTOM_BASE_DIR_NAME"
    fi
else
    if [ -d "$HOME/wenvs" ]; then
        echo "Directory $HOME/wenvs already exists." 1>&2
        exit 1
    else
        BASE_DIR="$HOME/$DEFAULT_BASE_DIR_NAME"
    fi

    make_base_dir "$BASE_DIR"
fi

#echo
#echo "no aliases $NO_ALIASES"
#echo "alias name $CUSTOM_ALIAS_NAME"
#echo "base dir $CUSTOM_BASE_DIR_NAME"
#echo

if [[ "$NO_ALIASES" == "true" ]]; then
    echo "Skipped creation of aliases."
else

    if file_exists "$HOME/.bash_aliases"; then
        :
    else
        echo "Cannot find '.bash_aliases' file in your HOME directory."
        touch_file "$HOME/.bash_aliases"
    fi

    if [ -z "$CUSTOM_ALIAS_NAME" ]; then
        append_bash_aliases "$DEFAULT_ALIAS_NAME"
        echo "Aliased 'virtualenv' with '$DEFAULT_ALIAS_NAME'"
    else
        ALIAS_NAME="$DEFAULT_ALIAS_NAME"
        append_bash_aliases "$ALIAS_NAME"
        echo "Aliased 'virtualenv' with $ALIAS_NAME"
    fi

    if is_bash_aliases_sourced_in_bashrc; then
        :
    else
        append_files_to_source_in_bashrc ". $HOME/.bash_aliases" ".bash_aliases"
    fi
fi


