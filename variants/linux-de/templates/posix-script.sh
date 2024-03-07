#!/bin/sh
set -e

print_help ()
{
  echo "Usage: $0 "
  echo "   OR: $0 -h"
  echo ""
  echo "  -h          Print this message"
}

# Handle option arguments
while getopts ":h" OPT
do
  case $OPT in
    h) print_help; exit 0 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

# Handle positional arguments
shift $((OPTIND-1))

if [ "$1" = "clean" ]; then
    echo "Cleaning up..."
fi

