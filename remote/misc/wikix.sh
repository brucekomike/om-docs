#!/bin/bash

# strippeter: A script to strip wikitext to custom selections.
# Supports local files and URLs. Auto-detects dialog and curl.

# --- Configuration ---
# Use variables for content instead of temporary files
INPUT_CONTENT=""
PROCESSED_CONTENT=""

# --- Cleanup Function ---
# No temporary directory to clean up if using variables
cleanup() {
    : # No action needed
}
trap cleanup EXIT # Ensure cleanup on script exit (no-op here)

# --- Dependency Check Function ---
check_dependency() {
    local cmd="$1"
    local install_info="$2"
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: '$cmd' is not installed." >&2
        echo "Please install it to run this script." >&2
        echo "$install_info" >&2
        exit 1
    fi
}

# --- Main Logic Function ---
process_wikitext() {
    local source_path="$1"

    # Determine if source is a URL or a file
    if [[ "$source_path" =~ ^https?:// ]]; then
        echo "Fetching content from URL: $source_path"
        check_dependency "curl" "On Debian/Ubuntu: sudo apt-get install curl
On Fedora: sudo dnf install curl
On macOS (with Homebrew): brew install curl"
        INPUT_CONTENT=$(curl -s "$source_path")
        if [[ $? -ne 0 || -z "$INPUT_CONTENT" ]]; then
            echo "Error: Failed to fetch content from $source_path" >&2
            exit 1
        fi
    elif [[ -f "$source_path" ]]; then
        echo "Reading content from file: $source_path"
        INPUT_CONTENT=$(cat "$source_path")
    else
        echo "Error: '$source_path' is not a valid file or URL." >&2
        exit 1
    fi

    check_dependency "dialog" "On Debian/Ubuntu: sudo apt-get install dialog
On Fedora: sudo dnf install dialog
On macOS (with Homebrew): brew install dialog"

    local current_selection_title=""
    local selection_content=""
    local selection_count=0

    # Store selections and their corresponding content in an associative array
    declare -A sections_map
    declare -a section_titles_in_order # To maintain order for dialog

    # Read the content line by line from the INPUT_CONTENT variable
    # Using 'readarray' with a here-string to process line by line
    readarray -t lines <<< "$INPUT_CONTENT"

    for line in "${lines[@]}"; do
        # Check for any section header (==...== to ======...======)
        if [[ "$line" =~ ^={2,6}([^=]+)={2,6}$ ]]; then
            # Found a new section header
            if [[ -n "$current_selection_title" ]]; then
                # Save the previous section's content
                sections_map["$current_selection_title"]+="$selection_content" # Append in case of nested sections
            fi
            # Extract the content between the leading and trailing equal signs
            # Then remove trailing equals signs from the extracted content
            current_selection_title=$(echo "${BASH_REMATCH[0]}" | sed 's/=+$//' | xargs) # Trim whitespace and remove trailing '='
            section_titles_in_order+=( "$current_selection_title" )
            selection_content=""
            selection_count=$((selection_count + 1))
        elif [[ -n "$current_selection_title" ]]; then
            # Append line to current section's content
            selection_content+="$line"$'\n'
        fi
    done

    # Save the last section's content
    if [[ -n "$current_selection_title" ]]; then
        sections_map["$current_selection_title"]+="$selection_content"$'\n'
    fi

    # Prepare for dialog
    local dialog_options=()
    local i=0
    for title in "${section_titles_in_order[@]}"; do
        local summary=$(echo "${sections_map[$title]}" | awk '
            BEGIN { in_pre = 0 }
            /<pre>/ { in_pre = 1; next }
            /<\/pre>/ { in_pre = 0; next }
            in_pre == 0 && !/^[ ]/ && NF > 0 { print; exit }
            ')
        dialog_options+=( "$i" "$title - $summary" "off" )
        i=$((i + 1))
    done

    # Use dialog to let the user select
    local chosen_indices_str
    chosen_indices_str=$(dialog --checklist "Select sections to extract:" 20 70 "${#dialog_options[@]}" "${dialog_options[@]}" 3>&1 1>&2 2>&3)

    # Process selected indices
    local selected_content=""
    IFS=' ' read -r -a chosen_indices_array <<< "$chosen_indices_str"

    for index_str in "${chosen_indices_array[@]}"; do
        local index="$index_str"
        local title_to_extract="${section_titles_in_order[$index]}"
        if [[ -n "${sections_map[$title_to_extract]}" ]]; then
            local content_to_add="${sections_map[$title_to_extract]}"

            content_to_add=$(echo "$content_to_add" | awk '
                /<pre>/ { in_pre = 1; next }
                /<\/pre>/ { in_pre = 0; next }
                in_pre { print }
                /^ / { sub(/^ /, ""); print }
            ')

            selected_content+="$content_to_add"$'\n'
        fi
    done

    # Store the final selected content in the global variable
    PROCESSED_CONTENT="$selected_content"
}

# --- Script Execution ---

# Check for arguments
if [[ -z "$1" ]]; then
    echo "Usage: strippeter <file_path_or_url>" >&2
    echo "Example: strippeter my_wiki.txt" >&2
    echo "Example: strippeter https://en.wikipedia.org/wiki/Example" >&2
    exit 1
fi

# Call the main processing function
process_wikitext "$1"

# Display the final content from the variable
echo "$PROCESSED_CONTENT"
