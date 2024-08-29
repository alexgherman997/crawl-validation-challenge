#!/bin/bash

csv_file="validation.csv"

# Read the CSV file line by line
while IFS=',' read -r id title year rating runtime genres
do
    #Print each raw line
    echo "Raw line: $id, $title, $year, $rating, $runtime, $genres"
    
    # Skip the header line
    if [[ "$id" == "id" ]]; then
        continue
    fi

    # Remove leading and trailing spaces and quotes from each variable
    id=$(echo "$id" | xargs)
    title=$(echo "$title" | sed "s/^'//;s/'$//" | xargs)
    year=$(echo "$year" | xargs)
    rating=$(echo "$rating" | xargs)
    runtime=$(echo "$runtime" | xargs)
    genres=$(echo "$genres" | sed 's/^"//;s/"$//' | xargs)
    
    # Print the parsed data
    echo "ID: $id"
    echo "Title: $title"
    echo "Year: $year"
    echo "Rating: $rating"
    echo "Runtime: $runtime minutes"
    echo "Genres: $genres"
    echo "----------------------"

done < "$csv_file"

# Get API response with movies information 
response=$(curl -s -X GET https://yts.mx/api/v2/list_movies.json?genre=action)

# Extract and print all movie titles
job_titles=$(echo "$response" | jq -r '.data.movies[].title')
echo "movies titles:"
echo "$job_titles"

