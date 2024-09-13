#!/bin/bash

books_array=()
csv_file="validation.csv"
dangerous_commands=("rm -rf" "sudo" "mv /" "cp /" "dd if=" "shutdown" "reboot" "curl" "wget" "chmod 777" "chown root" "mkfs" "nc -e" "perl -e" "python -c" "ruby -e" "php -r")

#Function to assert equality and print success or error message
assert_equal() {
    local csv_value="$1"
    local api_value="$2"
    local field_name="$3"

    if [[ "$csv_value" == "$api_value" ]]; then
        echo "   Test passed: $field_name match csv value!"
    else
        echo "   Test failed: $field_name do not match csv value!"
        echo "   CSV $field_name: $csv_value"
        echo "   API $field_name: $api_value"
    fi
}

# Function to check if a value is contained within an array (or string)
assert_contains() {
    local csv_value="$1"
    local api_array="$2"
    local field_name="$3"

    if [[ "$api_array" == *"$csv_value"* ]]; then
        echo "   Test passed: $field_name match csv value!"
    else
        echo "   Test failed: $field_name '$csv_value' not found in API $field_name!"
        echo "   CSV $field_name: $csv_value"
        echo "   API $field_name: $api_array"
    fi
}

# Function to check if a key field exists and meets specific format criteria
assert_id_format() {
    local id="$1"

    # Check if ID is not empty
    if [[ -z "$id" ]]; then
        echo "   Test failed: ID is missing."
        return
    fi

    # Check if ID starts with 'OL' and ends with 'W'
    if [[ "$id" =~ ^OL.*W$ ]]; then
        echo "   Test passed: ID '$id' is valid."
    else
        echo "   Test failed: ID '$id' does not start with 'OL' or end with 'W'."
    fi
}

# Function to check if a value is numeric
assert_numeric() {
    local value="$1"
    local field_name="$2"
    if [[ "$value" =~ ^[0-9]+$ ]]; then
        echo "   Test passed: $field_name is numeric."
    else
        echo "   Test failed: $field_name is not numeric."
        echo "   $field_name: $value"
    fi
}

# Function to check if a field exceeds a maximum length
assert_max_length() {
    local value="$1"
    local max_length="$2"
    local field_name="$3"

    if [[ "${#value}" -le "$max_length" ]]; then
        echo "   Test passed: $field_name length is within limit."
    else
        echo "   Test failed: $field_name length exceeds $max_length characters!"
        echo "   $field_name: $value"
    fi
}

# Function to check if a mandatory field is empty
assert_not_empty() {
    local value="$1"
    local field_name="$2"

    if [[ -n "$value" ]]; then
        echo "   Test passed: $field_name is not empty."
    else
        echo "   Test failed: $field_name is empty!"
        echo "   $field_name: $value"
    fi
}

assert_equal_case_sensitive() {
    local csv_value="$1"
    local api_value="$2"
    local field_name="$3"

    if [[ "$csv_value" == "$api_value" ]]; then
        echo "   Test passed: $field_name matches (case-sensitive)!"
    else
        echo "   Test failed: $field_name does not match (case-sensitive)!"
        echo "   CSV $field_name: $csv_value"
        echo "   API $field_name: $api_value"
    fi
}

assert_no_trailing_whitespace() {
    local value="$1"
    local field_name="$2"

    if [[ "$value" =~ ^[[:space:]]*$ ]]; then
        echo "   Test failed: $field_name contains only whitespace."
    elif [[ "$value" =~ [[:space:]]$ ]]; then
        echo "   Test failed: $field_name has trailing whitespace."
        echo "   $field_name: '$value'"
    else
        echo "   Test passed: $field_name has no trailing whitespace."
    fi
}

contains_dangerous_command() {
    local input="$1"
    for cmd in "${dangerous_commands[@]}"; do
        if [[ "$input" == *"$cmd"* ]]; then
            echo "   Security warning: Input $input dangerous command: '$cmd'"
            return 1  # Return with an error status
        fi
    done
    return 0  # Return with a success status if no dangerous commands are found
}


# Function to filter by author
filter_by_author() {
    local author="$1"
    echo "Books with author \"$author\":"
    for entry in "${books_array[@]}"; do
        author_book=$(echo "$entry" | awk -F':::' '{print $5}' | sed "s/['\"]//g" | xargs)

        if [[ "$author_book" == *"$author"* ]]; then
            id=$(echo "$entry" | awk -F':::' '{print $1}')
            echo "ID: $id"

            title=$(echo "$entry" | awk -F':::' '{print $2}')
            echo "Title: $title"
        fi
    done
}


# Function to filter by subject
filter_by_subject() {
    local subject="$1"
    echo "Books with subject \"$subject\":"
    for entry in "${books_array[@]}"; do
        subject_book=$(echo "$entry" | awk -F':::' '{print $3}' | xargs)

        if [[ "$subject_book" == *"$subject"* ]]; then
            id=$(echo "$entry" | awk -F':::' '{print $1}')
            echo "ID: $id"

            title=$(echo "$entry" | awk -F':::' '{print $2}')
            echo "Title: $title"
        fi
    done
}

sort_by_revision() {
    echo "Books sorted by revision number:"

    # Replace the ':::' with a single character (like '|') for sorting
    sorted_books=$(for element in "${books_array[@]}"; do
        echo "$element"
    done | sed 's/:::/|/g' | sort -t'|' -k4,4n)

    # After sorting, replace the delimiter back to ':::'
    sorted_books=$(echo "$sorted_books" | sed 's/|/:::/g')

    # Then, we iterate over the sorted output and print the fields
    while IFS=::: read -r id title subject revision author; do
        echo "ID: $id"
    done <<< "$sorted_books"
}


# Function to check HTTP Status code 
api_response_check(){
    local url="$1"
    response_http=$(curl -s -w "%{http_code}" -X GET "$url")
    http_code=$(echo "$response_http" | tail -c 4)

    if [[ "$http_code" -ne 200 ]]; then
        echo "Error: API request failed with status code $http_code"
    fi
}

# Function to check response required fields 
api_required_fields_check(){
    local response="$1"
    required_fields=("title" "subjects" "revision")
    for field in "${required_fields[@]}"; do
        if [[ "$(echo "$response" | jq -r ".$field")" == "null" ]]; then
            echo "Error: Missing required field '$field' in API response"
        fi
    done
}

# Function to check valida JSON structure
api_valid_json_check(){
    local response="$1"
    if ! echo "$response" | jq . > /dev/null 2>&1; then
        echo "Error: API response is not valid JSON"
    fi
}

#Test cases set read write csv file permissions
chmod 700 $csv_file
if [[ $? -ne 0 ]]; then
    echo "Failed to set permissions on validation.csv"
    exit 1
else
    echo "Permissions set to 700 on validation.csv"
fi

# Read the CSV file line by line
while IFS=',' read -r id title subject revision author_in_description; do

    # Skip the header line
    if [[ "$id" == "id" ]]; then
        continue
    fi

    # Clean up CSV values
    id=$(echo "$id" | xargs)
    title_csv=$(echo "$title" | sed "s/^'//;s/'$//" | xargs)
    subject_csv=$(echo "$subject" | xargs)
    revision_csv=$(echo "$revision" | xargs)
    author_in_description_csv=$(echo "$author_in_description" | xargs)


    #Security checks
    #Test cases for dangerous commands in the title
    if ! contains_dangerous_command "$id"; then
        echo "   Error: Dangerous command found in the input. Exiting."
        exit 1
    fi

    if ! contains_dangerous_command "$title_csv"; then
        echo "   Error: Dangerous command found in the input. Exiting."
        exit 1
    fi

    if ! contains_dangerous_command "$csv_file"; then
        echo "   Error: Dangerous command found in the input. Exiting."
        exit 1
    fi


    # Get API response with book information
    url="https://openlibrary.org/works/${id}.json"
    api_response_check "$url"
    response=$(curl -s -X GET --max-time 15 "$url")

    api_required_fields_check "$response"
    api_valid_json_check "$response"
    

    # Extract relevant fields from the API response
    title_book=$(echo "$response" | jq -r '.title')
    subject_book=$(echo "$response" | jq -r '.subjects | join(", ")')  # Join array subjects into a single string

    revision_book=$(echo "$response" | jq -r '.revision')
    author_in_description_book=$(echo "$response" | jq -r '.description'| tr '\n' ' ')
    #echo $author_in_description_book

    books_array+=("$id:::$title_book:::$subject_book:::$revision_book")

    # Test cases equality between api and csv
    echo "Tests for Book ID: $id"
    assert_equal "$title_csv" "$title_book" "Title"
    subject_match=$(echo "$response" | jq --arg subject "$subject_csv" '.subjects | index($subject)')
    assert_contains "$subject_csv" "$subject_book" "Subject"
    assert_equal "$revision_csv" "$revision_book" "Revision"
    assert_contains "$author_in_description_csv" "$author_in_description_book" "Author in Description"

    # Test cases field type   
    assert_id_format "$id"
    assert_max_length "$title_book" 100 "Title"
    assert_max_length "$subject_csv" 50 "Subject"
    assert_numeric "$revision_book" "Revision"
    
    # Test cases mandatory field  
    assert_not_empty "$title_book" "Title"
    assert_not_empty "$subject_book" "Subject"
    assert_not_empty "$revision_book" "Revision"

    # Test cases for case-sensitive match
    assert_equal_case_sensitive "$title_csv" "$title_book" "Title (case-sensitive)"

done < "$csv_file"