#!/bin/bash

# Check if a directory is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

DIRECTORY="$1"

# Verify that the provided argument is a valid directory
if [ ! -d "$DIRECTORY" ]; then
    echo "Error: '$DIRECTORY' is not a directory."
    exit 1
fi

# Iterate over each file in the directory
for FILE in "$DIRECTORY"/*
do
    # Check if it's a regular file (not a directory or special file)
    if [ -f "$FILE" ]; then
        #echo "Processing file: $FILE"
        python parse_total_ipc.py "$FILE"
    fi
done
