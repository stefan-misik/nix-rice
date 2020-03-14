#!/bin/sh

self="$0"
install_prefix="$HOME"
temp_dir="_temp"

print_help ()
{
    echo "Usage: $self [-v] [-c VARIANT] [FILE1] [FILE2] ..."
    echo "   OR: $self -a [-v] [-c VARIANT] [-p PARENT] [FILE1] [FILE2] ..."
    echo "   OR: $self -h"
    echo ""
    echo "  -h          Print this message"
    echo "  -c VARIANT  Specify configuration variant (default is 'base')"
    echo "  -a          Add the file into the rice"
    echo "  -p PARENT   In combination with -a adds a difference of the"
    echo "              file to the file in the configuration variant PARENT"
    echo "  -v          Verbose mode"
    echo ""
    echo "If no files are listed after the last switch, the command will try"
    echo "to do the operation on all files in specified configuration variant."
    echo ""
    echo "If -a switch is not specified, the files are installed from rice"
    echo "collection into the system."
}

## Make the specified file variant
# $1 Target location to make the file into
# $2 Variant to make
# $3 File to make
make_file ()
{
    if [ -f "variants/$2/$3" ]
    then
        mkdir -p "`dirname "$1/$3"`"
        cp -p "variants/$2/$3" "$1/$3"
    elif ls "variants/$2/$3."*.diff  >/dev/null 2>&1
    then
        make_file "$1" "`ls "variants/$2/$3."*.diff | \
             awk -F . '{print $(NF-1)}'`" "$3"
        patch -s "$1/$3" < "`ls "variants/$2/$3."*.diff`"
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
    mkdir -p "`dirname "variants/$2/$3"`"
    cp -p "$1/$3" "variants/$2/$3"
}

## Add file from the system into specified variant
# $1 Source location to add the file from
# $2 Variant to store the file into
# $3 File to add
# $4 Parent configuration variant
add_diff ()
{
    mkdir -p "`dirname "variants/$2/$3"`"
    make_file "$temp_dir" "$4" "$3"
    rm -f "variants/$2/$3."*.diff
    diff -a "$temp_dir/$3" "$1/$3" > "variants/$2/$3.$4.diff"
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
            file_list="${file_list:+${file_list}:}$file"
        done
    else
    IFS='
'
        for file in `find variants/$variant -type f | \
            sed "s/variants\/$variant\///;s/\.[^\.]*\.diff$//"`
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
    if [ ! -d "variants/$1" ]
    then
        echo "Variant '$1' does not exist"
        exit 1
    fi
}

## Clear the temporary directory
clear_temp ()
{
    rm -rf "$temp_dir"
}

# Default values
variant="base"
parent=""
action="get"
file_list=""
verbose=""

# Handle option arguments
while getopts ":h :a :c: :p: :v" OPT
do
    case $OPT in
        h) action="help" ;;
        a) action="add" ;;
        c) variant="$OPTARG" ;;
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
esac
