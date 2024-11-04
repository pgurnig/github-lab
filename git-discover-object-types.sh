#!/bin/bash

# Check if a parameter is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <relative-path-to-folder>"
    exit 1
fi

# Set the folder variable to the first argument (relative path)
folder="$1"

# Ensure the .git/objects directory exists
if [ ! -d "$folder/.git/objects" ]; then
    echo "Error: $folder/.git/objects directory not found."
    exit 1
fi

# Extract the list of object files from .git/objects to an array
object_files=($(find "$folder/.git/objects" -type f))

# Iterate over the array of object files
for file in "${object_files[@]}"; do
    # Extract the hash from the file path
    # Example: .git/objects/ab/cdef12345 -> ab/cdef12345 -> abcdef12345
    hash=$(basename "$(dirname "$file")")$(basename "$file")
    
    # Use git cat-file to determine the type of the object
    object_type=$(git -C "$folder" cat-file -t "$hash")
    
    # Print the hash and the object type
    echo "Object hash: $hash - Type: $object_type"
done