#!/bin/sh

self="$0"
install_prefix="$HOME"
temp_dir="$(mktemp -d -t rice-XXXXX)"
# Default settings
variant="base"
repo="."

print_help ()
{
    self_cmd="$(basename "$self")"
    echo "Usage: $self_cmd [-v] [-c VARIANT] [FILE1] [FILE2] ..."
    echo "   OR: $self_cmd -a [-v] [-c VARIANT] [-p PARENT] [FILE1] [FILE2] ..."
    echo "   OR: $self_cmd -h"
    echo "   OR: $self_cmd git GIT COMMANDS"
    echo ""
    echo "  -h          Print this message"
    echo "  -c VARIANT  Specify configuration variant (default is 'base',"
    echo "              however it can be overridden by configuration"
    echo "              stored in ~/.config/ricerc)"
    echo "  -a          Add the file into the rice"
    echo "  -p PARENT   In combination with -a adds a difference of the"
    echo "              file to the file in the configuration variant PARENT"
    echo "  -l DEST     In combination with -c link all undefined files in"
    echo "              DEST to files in VARIANT"
    echo "  -d          Show diff of the files in the system to the specified"
    echo "              configuration variant to the"
    echo "  -r          Update all patches in all configuration variants"
    echo "  -v          Verbose mode"
    echo ""
    echo "If no files are listed after the last switch, the command will try"
    echo "to do the operation on all files in specified configuration variant."
    echo ""
    echo "If -a switch is not specified, the files are installed from rice"
    echo "collection into the system."
    echo ""
    echo "This command will also allow to manipulate the repository with"
    echo "the rice files through '$self_cmd git ...' that will pass the"
    echo "'...' to the git as if it were executed inside the rice repository."
}

## Make the specified file variant
# $1 Target location to make the file into
# $2 Variant to make
# $3 File to make
make_file ()
{
    if [ -f "$repo/variants/$2/$3" ]
    then
        mkdir -p "$(dirname "$1/$3")"
        cp -p "$repo/variants/$2/$3" "$1/$3"
    elif ls "$repo/variants/$2/$3."*.diff >/dev/null 2>&1
    then
        make_file "$1" "$(parent_of_diff "$2" "$3")" "$3"
        patch -s "$1/$3" < "$(ls "$repo/variants/$2/$3."*.diff)"
        if [ $? -ne 0 ]
        then
            echo "Failed to patch $3 from  variant $2"
            exit 1
        fi
    else
        echo "Configuration $3 not found in variant $2"
        exit 1
    fi
}

## Add file from the system into specified variant
# $1 Source location to add the file from
# $2 Variant to store the file into
# $3 File to add
add_file ()
{
    mkdir -p "$(dirname "$repo/variants/$2/$3")"
    cp -p "$1/$3" "$repo/variants/$2/$3"
}

## Add file from the system into specified variant
# $1 Source location to add the file from
# $2 Variant to store the file into
# $3 File to add
# $4 Parent configuration variant
add_diff ()
{
    mkdir -p "$(dirname "$repo/variants/$2/$3")"
    make_file "$temp_dir/$4" "$4" "$3"
    rm -f "$repo/variants/$2/$3."*.diff
    store_diff "$temp_dir/$4/$3" "$1/$3" \
        "$3" "$4" "$2"
}

## If provided file is a diff, update it
# $1 Configuration variant of the file to be updated
# $2 File to be updated
# $3 (internal) Parent of the diff file
rediff ()
{
    if [ -n "$3" ]
    then
        if [ ! -f "$repo/variants/$3/$2" ]
        then
            rediff "$3" "$2"
        fi

        # Make the two files which need to be diffed
        make_file "$temp_dir/$1" "$1" "$2"
        make_file "$temp_dir/$3" "$3" "$2"

        # Store the diff
        store_diff "$temp_dir/$3/$2" "$temp_dir/$1/$2" "$2" \
            "$3" "$1"
    elif [ ! -f "$repo/variants/$1/$2" ]
    then
        rediff "$1" "$2" "$(parent_of_diff "$1" "$2")"
    fi
}

## Store the file diff
# $1 Original file
# $2 Modified file
# $3 File name
# $4 Parent variant
# $5 Destination variant
store_diff ()
{
    diff -au --label "$4" --label "$5" \
        "$1" "$2" > "$repo/variants/$5/$3.$4.diff"
    true # Discard the exit status of 'diff' command
}

## Fil the list of the files using files passed as arguments
# $@ List of files passed to the script
populate_file_list ()
{
    file_list=""
    if [ -n "$1" ]
    then
        for file in "$@"
        do
            file="$(realpath "$file" | \
                awk -F "$install_prefix/" '{print $2}')"
            [ -n "$file" ] && file_list="${file_list:+${file_list}:}$file"
        done
    else
    IFS='
'
        for file in $(find "$repo/variants/$variant" -type f | \
            awk -F "$repo/variants/$variant/" '{print $2}' | \
            sed "s/\.[^\.]*\.diff$//")
        do
            file_list="${file_list:+${file_list}:}$file"
        done
    fi
    IFS=":"
}

## Ensure given configuration variant exists
# $1 Name of the configuration variant
ensure_variant_exists ()
{
    if [ ! -d "$repo/variants/$1" ]
    then
        echo "Variant '$1' does not exist"
        exit 1
    fi
}

## Output the parent of the diff file
# $1 Configuration variant of the file to be updated
# $2 File to be updated
parent_of_diff ()
{
    ls "$repo/variants/$1/$2."*.diff | awk -F . '{print $(NF-1)}'
}

## Clear the temporary directory
clear_temp ()
{
    rm -rf "$temp_dir"
}

# Default values
[ -f "$install_prefix/.config/ricerc" ] &&
    . "$install_prefix/.config/ricerc"
parent=""
link=""
action="get"
file_list=""
verbose=""

# First check whether rice repositary is to be modified
if [ "$1" = "git" ]
then
    shift 1
    git -C "$repo" $@
    exit $?
fi

# Handle option arguments
while getopts ":a :c: :d :h :l: :p: :r :v" OPT
do
    case $OPT in
        a) action="add" ;;
        c) variant="$OPTARG" ;;
        d) action="diff" ;;
        r) action="rediff" ;;
        h) action="help" ;;
        l) link="$OPTARG" ; action="link" ;;
        p) parent="$OPTARG" ;;
        v) verbose="yes" ;;
       \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
    esac
done
shift $(($OPTIND-1))

# Perform specified action
case $action in
    help)
        print_help
        exit 0
    ;;

    get)
        ensure_variant_exists "$variant"
        populate_file_list "$@"
        for file in $file_list
        do
            [ -z "$verbose" ] || echo "$file"
            make_file "$install_prefix" "$variant" "$file"
        done
    ;;

    add)
        if [ -z "$parent" ]
        then
            populate_file_list "$@"
            for file in $file_list
            do
                [ -z "$verbose" ] || echo "Adding file $file"
                add_file "$install_prefix" "$variant" "$file"
            done
        else
            ensure_variant_exists "$parent"
            populate_file_list "$@"
            for file in $file_list
            do
                [ -z "$verbose" ] || echo "Adding diff $file"
                add_diff "$install_prefix" "$variant" "$file" "$parent"
            done
        fi
    ;;

    link)
        ensure_variant_exists "$variant"
        populate_file_list "$@"
        for file in $file_list
        do
            if [ ! -f "$repo/variants/$link/$file" ]
            then
                if ls "$repo/variants/$link/$file."*.diff >/dev/null 2>&1
                then
                    true
                else
                    [ -z "$verbose" ] || echo "Adding diff $file"
                    touch "$repo/variants/$link/$file.$variant.diff"
                fi
            fi
        done
    ;;

    diff)
        ensure_variant_exists "$variant"
        populate_file_list "$@"
        for file in $file_list
        do
            make_file "$temp_dir/$variant" "$variant" "$file"
            if [ -f "$install_prefix/$file" ]
            then
                git --no-pager -c color.ui=always diff --no-index \
                    "$temp_dir/$variant/$file" "$install_prefix/$file"
            else
                git --no-pager -c color.ui=always diff --no-index \
                    "$temp_dir/$variant/$file" /dev/null
            fi
        done | less -RFX
    ;;

    rediff)
        for variant in $(ls "$repo/variants/")
        do
            populate_file_list
            for file in $file_list
            do
                [ -z "$verbose" ] || echo "Trying to update $file from $variant"
                rediff "$variant" "$file"
            done
        done
    ;;
esac

rm -rf "$temp_dir"
