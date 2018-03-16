#!/usr/bin/env bash

# $1 is defining directory name where all virtualenv folders will reside
# together with wenv log file (wenv.log).
# You only need to specify the name of the directory.
# It will be created in your HOME location. If not specified, 'wenvs' directory
# will be created in user home directory or whatever the HOME environment
# variable is set.

# $2 is whether you want to create an alias in bash_aliases from virtualenv
# to wenv or any other name orvided as other parameter

set -e
source default_conf.sh
source helpers.sh

NO_ALIASES="$NO_ALIASES"

CUSTOM_ALIAS_NAME=""
CUSTOM_BASE_DIR_NAME=""

while [[ $# -gt 0 ]]; do
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
ALIAS=""


make_log_file () {
    touch "$HOME/$HIDDEN_DIR_NAME/$LOG_FILE_NAME" &&
    echo "Log file created: $HOME/$HIDDEN_DIR_NAME/$LOG_FILE_NAME"
}


make_base_dir () {
    base_dir=$1
    mkdir "$base_dir" &&
    echo "Base directory created: $base_dir"
}


append_bash_aliases () {
    alias_name=$1
    echo "alias virtualenv='$alias_name make'" >> "$HOME/.bash_aliases"
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


make_user_config () {
    for i in "$@"; do
        echo "$i" >> "$USER_CONFIG_FILE"
    done
    echo "User config file created."
}


make_hidden_config_dir () {
    mkdir "$HOME/$HIDDEN_DIR_NAME" &&
    echo "Created hidden config directory" "$HOME/$HIDDEN_DIR_NAME"
}


copy_configs_to_hidden_dir () {
    cp -v "$USER_CONFIG_FILE" "$HOME/$HIDDEN_DIR_NAME/$USER_CONFIG_FILE"
    cp -v "$DEFAULT_CONFIG_FILE" "$HOME/$HIDDEN_DIR_NAME/$DEFAULT_CONFIG_FILE"
}


copy_main_to_hidden () {
    cp -v "wenw.sh" "$HOME/$HIDDEN_DIR_NAME/wenw.sh"
    cp -v "venv_active.py" "$HOME/$HIDDEN_DIR_NAME/venv_active.py"
    cp -v "helpers.sh" "$HOME/$HIDDEN_DIR_NAME/helpers.sh"
}


copy_installs_to_hidden () {
    cp -v "install.sh" "$HOME/$HIDDEN_DIR_NAME/install.sh"
    cp -v "uninstall.sh" "$HOME/$HIDDEN_DIR_NAME/uninstall.sh"
}


copy_data_to_hidden () {
    copy_configs_to_hidden_dir
    copy_main_to_hidden
    copy_installs_to_hidden
}


make_hidden_config_dir
make_log_file
touch_file "$USER_CONFIG_FILE"
echo '#!/usr/bin/env bash' >> "$USER_CONFIG_FILE"
declare -a user_conf

if [ -z "$(which virtualenv)" ]; then
    echo "Seems like you do not have 'virtualenv' installed." 1>&2
    echo "use 'sudo apt-get install virtualenv'"
    exit 1
else
    user_conf[0]="USER_VIRTUALENV_LOCATION=$(which virtualenv)"
fi

if [ -z "$HOME" ]; then
    echo "Your HOME variable is not defined." 1>&2
    exit 1
fi

if [ ! -f "$HOME/.bashrc" ]; then
    echo "Cannot find '.bashrc' file in your HOME directory." 1>&2
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
    if [ -d "$HOME/$BASE_DIR_NAME" ]; then
        echo "Directory $HOME/$BASE_DIR_NAME already exists." 1>&2
        exit 1
    else
        BASE_DIR="$HOME/$BASE_DIR_NAME"
    fi

    user_conf[1]="BASE_DIR_LOCATION=$BASE_DIR"
    make_base_dir "$BASE_DIR"
fi


if [[ "$NO_ALIASES" == "true" ]]; then
    echo "Skipped creation of aliases."
    user_conf[2]="NO_ALIASES=true"
else
    if file_exists "$HOME/.bash_aliases"; then
        :
    else
        echo "Cannot find '.bash_aliases' file in your HOME directory."
        touch_file "$HOME/.bash_aliases"
    fi

    if [ -z "$CUSTOM_ALIAS_NAME" ]; then
        append_bash_aliases "$ALIAS_NAME"
        echo "Aliased 'virtualenv' with '$ALIAS_NAME'"
        user_conf[2]="ALIAS_NAME=$ALIAS_NAME"
    else
        ALIAS="$CUSTOM_ALIAS_NAME"
        append_bash_aliases "$ALIAS"
        echo "Aliased 'virtualenv' with $ALIAS"
        user_conf[2]="ALIAS_NAME=$ALIAS"
    fi

    if is_bash_aliases_sourced_in_bashrc; then
        :
    else
        append_files_to_source_in_bashrc ". $HOME/.bash_aliases" ".bash_aliases"
    fi
fi

make_user_config "${user_conf[@]}"
copy_data_to_hidden
append_files_to_source_in_bashrc ".    $HOME/$HIDDEN_DIR_NAME/wenw.sh"
