#!/bin/bash

# stripmarkcode: Extract only raw code from selected Markdown sections.

INPUT_CONTENT=""
PROCESSED_CONTENT=""

cleanup() {
    : # No action needed
}
trap cleanup EXIT

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

process_markdown() {
    local source_path="$1"

    if [[ "$source_path" =~ ^https?:// ]]; then
        echo "Fetching content from URL: $source_path"
        check_dependency "curl" "sudo apt-get install curl"
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

    check_dependency "dialog" "sudo apt-get install dialog"

    local current_selection_title=""
    local selection_content=""
    declare -A sections_map
    declare -a section_titles_in_order
    declare -A section_levels

    readarray -t lines <<< "$INPUT_CONTENT"

    for line in "${lines[@]}"; do
        if [[ "$line" =~ ^(#+)[[:space:]]+(.*)$ ]]; then
            if [[ -n "$current_selection_title" ]]; then
                sections_map["$current_selection_title"]+="$selection_content"
            fi
            local hashes="${BASH_REMATCH[1]}"
            local title_text="${BASH_REMATCH[2]}"
            current_selection_title=$(echo "$title_text" | xargs)
            section_levels["$current_selection_title"]="${#hashes}"
            section_titles_in_order+=( "$current_selection_title" )
            selection_content=""
        elif [[ -n "$current_selection_title" ]]; then
            selection_content+="$line"$'\n'
        fi
    done

    if [[ -n "$current_selection_title" ]]; then
        sections_map["$current_selection_title"]+="$selection_content"$'\n'
    fi

    local dialog_options=()
    local i=0
    for title in "${section_titles_in_order[@]}"; do
        local summary=$(echo "${sections_map[$title]}" | awk '
            BEGIN { in_code = 0 }
            /^```/ { in_code = !in_code; next }
            in_code == 0 && NF > 0 { print; exit }
        ')
        dialog_options+=( "$i" "$title - $summary" "off" )
        i=$((i + 1))
    done

    local chosen_indices_str
    chosen_indices_str=$(dialog --checklist "Select sections to extract (raw code only):" 20 70 "${#dialog_options[@]}" "${dialog_options[@]}" 3>&1 1>&2 2>&3)

    local selected_content_raw=""
    IFS=' ' read -r -a chosen_indices_array <<< "$chosen_indices_str"

    for index_str in "${chosen_indices_array[@]}"; do
        local title_to_extract="${section_titles_in_order[$index_str]}"
        if [[ -n "${sections_map[$title_to_extract]}" ]]; then
            local content_to_add="${sections_map[$title_to_extract]}"
            local in_code_block=0
            local current_code_block=""

            readarray -t section_lines <<< "$content_to_add"
            for line in "${section_lines[@]}"; do
                if [[ "$line" =~ ^\`\`\` ]]; then
                    if [[ $in_code_block -eq 0 ]]; then
                        in_code_block=1
                        current_code_block=""
                    else
                        in_code_block=0
                        selected_content_raw+="$current_code_block"$'\n\n'
                        current_code_block=""
                    fi
                    continue
                fi

                if [[ $in_code_block -eq 1 ]]; then
                    current_code_block+="$line"$'\n'
                fi
            done
        fi
    done

    PROCESSED_CONTENT="$selected_content_raw"
}

if [[ -z "$1" ]]; then
    echo "Usage: stripmarkcode <file_path_or_url>" >&2
    exit 1
fi

process_markdown "$1"
echo "$PROCESSED_CONTENT"
