#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <directory> [extension]"
    exit 1
fi

directory=$1
extension=$2

# Ensure the directory exists
if [ ! -d "$directory" ]; then
    echo "Directory $directory does not exist."
    exit 1
fi

# Handle the case when the extension is provided or not
if [ -n "$extension" ]; then
    # Get the list of files with the specified extension sorted by name
    files=($(ls "$directory"/*."$extension" 2>/dev/null | sort))
else
    # Get the list of all files sorted by name
    files=($(ls "$directory"/* 2>/dev/null | sort))
fi

# Check if there are any files in the directory
if [ ${#files[@]} -eq 0 ]; then
    echo "No files found in the directory."
    exit 1
fi

# Rename the files
counter=1
for file in "${files[@]}"; do
    if [ -n "$extension" ]; then
        mv "$file" "$directory/$counter.$extension"
    else
        # Extract the file extension from the original file
        file_ext="${file##*.}"
        mv "$file" "$directory/$counter.$file_ext"
    fi
    ((counter++))
done

echo "Renamed ${#files[@]} files."
