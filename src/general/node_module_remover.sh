#!/bin/bash

# Define the directory to search (change this if needed)
SEARCH_DIR=~/Projects

# Find all node_modules directories and prompt for deletion
find "$SEARCH_DIR" -type d -name "node_modules" -prune -exec sh -c '
  for dir; do
    echo "Found: $dir"
    read -p "Do you want to delete this? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
      rm -rf "$dir"
      echo "Deleted: $dir"
    else
      echo "Skipped: $dir"
    fi
    echo "--------------------------------------"
  done
' sh {} +

echo "Done!"
