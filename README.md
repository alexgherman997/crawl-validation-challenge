# Crawl data and validation 
Crawling data from web API with books information and validating it using bash scripting and csv file.

## Installation steps  
- clone repository 
- chmod +x crawl-script.sh - give execution rights for script run
- brew install jq - install jq command to parse JSON for macOS 

## Execution 
- ./crawl-script.sh

# Validation explanation 
App is doing 3 types of assertions:
- performing assertions to check equality between each value from the web API and validation csv file 
- performing assertions to check the type of the fields ID and Revision, and maximum length for fields Title and Subject
- performing assertions to check if mandatory fields have value for Title, Subject and Revision

## Assertion structure
Assertion for Book ID: OL796465W
- Assertion passed: Title match csv value!
- Assertion passed: Subject match csv value!
- Assertion passed: Revision match csv value!
- Assertion passed: Author in Description match csv value!
- Assertion passed: ID 'OL796465W' is valid.
- Assertion passed: Title length is within limit.
- Assertion passed: Subject length is within limit.
- Assertion passed: Revision is numeric.
- Assertion passed: Title is not empty.
- Assertion passed: Subject is not empty.
- Assertion passed: Revision is not empty.
