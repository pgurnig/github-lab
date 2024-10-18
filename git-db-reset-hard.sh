#!/bin/bash

# ----- SECTION: Variables -----
COMMANDS=""
DIR_NAME=$1
log_file="script.log"
# ----- SECTION: End Variables -----

# ----- SECTION: Function Definitions -----
assemble_commands() {
    # COMMANDS=('git init' 'echo "README" > "$DIR_NAME/README.md"' 'git add README.md' 'git commit -m "Initial commit"' 'git add example.txt' 'git commit -m "Add example.txt"' 'git reset --hard HEAD~1')
    COMMANDS=('git init' 'echo "README" > "README.md"' 'git add README.md')
}

create_target_directory() {
    mkdir -p "$DIR_NAME"
}

execute_commands() {
    # Loop through the array
    for command in "${COMMANDS[@]}"; do
        log "$DIR_NAME: $command"

        # don't log here
        cd $DIR_NAME
        eval "$command"
        cd -
        # end don't log here

        SCRIPT_DIR=$(dirname "$0")
        "$SCRIPT_DIR/cp-git.sh" "$DIR_NAME"
        
        if [ $? -ne 0 ]; then
            log "Failed to execute 'cp-git.sh'."
        fi
        sleep 1

    done
}

log() {
    local message="$1"
    # echo "[$(date +"%Y-%m-%d %H:%M:%S")] $message" #| tee -a "$log_file"
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $message" >> "$log_file"
}

log_footer() {
    # Number of times to repeat
    local n=120

    # Repeat '-' n times using printf
    printf '%*s' "$n" '' | tr ' ' '-' >> "$log_file"
    echo "" >> "$log_file"  # Add a newline to the log file
    echo "" >> "$log_file"  # Add a newline to the log file
}

log_header() {
    # Number of times to repeat
    local n=120

    # Repeat '-' n times using printf
    printf '%*s' "$n" '' | tr ' ' '-' >> "$log_file"
    echo "" >> "$log_file"  # Add a newline to the log file
    echo "$(date +"%A %Y-%m-%d %H:%M:%S")" >> "$log_file"
    echo "" >> "$log_file"  # Add a newline to the log file
}

perform_checks() {
    # Check if the user provided a parameter (directory name)
    if [ -z "$1" ]; then
        echo "A directory name is required. Usage: $0 <directory_name>"
        exit 1
    fi

    # Check if the directory already exists
    if [ -d "$DIR_NAME" ]; then
        # Prompt the user for Y/N input, with Y as the default
        read -p "Directory '$DIR_NAME' already exists. Do you want to delete and re-create it? (Y/n): " choice
        
        # If the user presses Enter (no input), default to Y
        choice=${choice:-Y}
        
        case "$choice" in
            [Yy]* ) 
                # If user confirms, delete the directory
                rm -rf "$DIR_NAME"
                echo "Directory '$DIR_NAME' deleted."
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

# ----- SECTION: Main Section -----
log_header
perform_checks "$1"
create_target_directory
assemble_commands
execute_commands
log_footer

