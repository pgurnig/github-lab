#!/bin/bash

# ----- SECTION: Function Definitions -----
# Function to display usage information
show_usage() {
    echo "Usage: $0 <subdirectory> [optional_git_db_tracker_directory]"
    echo
    echo "Parameters:"
    echo "  <subdirectory>                       The name of the subdirectory to create."
    echo "  [optional_git_db_tracker_directory]  Optional replacement for the default 'snapshots' directory."
    exit 1
}

# Get the line items from commands.gtd
assemble_commands() {
    commands=()

    runner_file="commands.gtd"
    if [[ -f "$runner_file" ]]; then
        while IFS= read -r line; do
            # Skip blank lines and lines starting with '--' or '#'
            [[ -z "$line" || "$line" =~ ^-- || "$line" =~ ^# ]] && continue
            
            # Add the valid command to the COMMANDS array
            commands+=("$line")
        done < "$runner_file"
    else
        echo "Error: $runner_file not found!"
        exit 1
    fi
}

# Create a snapshot in snapshots or the user-specified snapshot directory
create_snapshot() {
    # Get the current date and time in the format yyyymmddHHMMSS
    timestamp=$(date +"%Y%m%d%H%M%S")

    # Create the target directory with the timestamp
    dest_dir="${tracker_dir}${dir_name}/${timestamp}"
    mkdir -p "$dest_dir"

    # Copy all files, including hidden files and folders, to the target directory
    # cp -r "$SOURCE_DIR"/* "$SOURCE_DIR"/.* "$DEST_DIR" 2>/dev/null
    cp -r "$dir_name/." "$dest_dir"

    # Notify the user that the files have been copied
    log "Files from $source_dir have been copied to $dest_dir"
}

create_target_directory() {
    mkdir -p "$dir_name"
}

# Ensure the directory ends with a "/"
ensure_trailing_slash() {
    local dir="$1"
    [[ "${dir}" != */ ]] && dir="${dir}/"  # Add trailing slash if not present
    echo "$dir"
}

# Run the commands in commands.gtd / log the output
execute_commands() {
    # Loop through the array
    for command in "${commands[@]}"; do
        echo "Running $command"
        log "$dir_name: $command"

        # don't log here
        cd $dir_name > /dev/null 2>&1 || echo "cd $dir_name failed"
        local output=$(eval "$command" 2>&1)
        cd -  > /dev/null 2>&1 || echo "cd - failed"
        log $output
        # end don't log here

        create_snapshot
        sleep 1

    done
}

log() {
    local message="$1"
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $message" >> "$log_file"
}

log_footer() {
    # Repeat '-' n (log_separator_length) times using printf
    printf '%*s' "$log_separator_length" '' | tr ' ' '-' >> "$log_file"
    echo "" >> "$log_file"  # Add two newlines to the log file
    echo "" >> "$log_file"
}


log_header() {
    # Repeat '-' n (log_separator_length) times using printf
    printf '%*s' "$log_separator_length" '' | tr ' ' '-' >> "$log_file"
    echo "" >> "$log_file"  # Add a newline to the log file
    echo "$(date +"%A %Y-%m-%d %H:%M:%S")" >> "$log_file"
    echo "" >> "$log_file"  # Add a newline to the log file
}

# Check if the sourcedirectory parameter is provided
perform_checks() {
    # Check if the user provided a parameter (directory name)
    if [ -z "$1" ]; then
        echo "Error: Missing required parameter."
        show_usage
    fi

    # Check if the directory already exists
    if [ -d "$dir_name" ]; then
        # Prompt the user for Y/N input, with Y as the default
        read -p "Directory '$dir_name' already exists. Do you want to delete and re-create it? (Y/n): " choice
        
        # If the user presses Enter (no input), default to Y
        choice=${choice:-Y}
        
        case "$choice" in
            [Yy]* ) 
                # If user confirms, delete the directory
                rm -rf "$dir_name"
                echo "Directory '$dir_name' deleted."
                ;;
            [Nn]* ) 
                # If user declines, exit or handle as needed
                echo "Exiting without making changes."
                exit
                ;;
            * ) 
                # Handle invalid input
                echo "Invalid input. Please enter Y or N."
                exit 1
                ;;
        esac
    fi
}
# ----- SECTION: End Function Definitions -----

# ----- SECTION: Variables -----
commands=""
dir_name=$1
tracker_dir=$(ensure_trailing_slash "${2:-snapshots}")  # Ensure the second parameter has a trailing slash, default to 'snapshots/'
log_file="script.log"
log_separator_length=120
# ----- SECTION: End Variables -----

# ----- SECTION: Main Section -----
log_header
perform_checks "$1"
create_target_directory
assemble_commands
execute_commands
log_footer

