#!/bin/bash

csv_file="validation.csv"

# Function to assert equality and print success or error message
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

    # Get API response with book information
    url="https://openlibrary.org/works/${id}.json"
    response=$(curl -s -X GET "$url")

    # Extract relevant fields from the API response
    title_book=$(echo "$response" | jq -r '.title')
    subject_book=$(echo "$response" | jq -r '.subjects | join(", ")')  # Join array subjects into a single string
    revision_book=$(echo "$response" | jq -r '.revision')
    author_in_description_book=$(echo "$response" | jq -r '.description')

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
done < "$csv_file"