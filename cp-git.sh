#!/bin/bash

# Check if the sourcedirectory parameter is provided
if [ -z "$1" ]; then
  echo "Error: You must provide a source directory as a parameter."
  echo "Usage: ./cp-git.sh <sourcedirectory>"
  exit 1
fi

# Set the source directory from the first parameter
SOURCE_DIR="$1"

# Set the target base directory (you can adjust this as needed)
TARGET_DIR="git-db-tracker/"

# Get the current date and time in the format yyyymmddHHMMSS
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Create the target directory with the timestamp
DEST_DIR="${TARGET_DIR}${SOURCE_DIR}/${TIMESTAMP}"
mkdir -p "$DEST_DIR"

# Copy all files, including hidden files and folders, to the target directory
# cp -r "$SOURCE_DIR"/* "$SOURCE_DIR"/.* "$DEST_DIR" 2>/dev/null
cp -r "$SOURCE_DIR/." "$DEST_DIR"

# Notify the user that the files have been copied
echo "Files from $SOURCE_DIR have been copied to $DEST_DIR"
echo $TIMESTAMP
