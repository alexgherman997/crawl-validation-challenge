# Crawl data and validation 
Crawling data from a web API with books information and validating it using bash scripting and validation.csv.<br>
Books API docs: https://openlibrary.org/dev/docs/api/books

## Installation steps  
- clone repository 
- chmod +x crawl-validate.sh - give execution rights for script run
- brew install jq - install jq command to parse JSON for macOS 

## Execution 
- ./crawl-validate.sh
- execution can be checked or triggered from Github CI: click on Actions tab, on the left side click on 'Crawl and validate', and click on 'Run workflow' button. 

## Test cases explanation 
Books information is crawled using ID field from validation.csv.<br>
3 types of test cases are performed:
- assertions to check equality(or contains) between values from validation.csv and web API for fields Title, Subject, Revision, Author_in_Description
- assertions to check the type of the fields ID and Revision, and maximum length for fields Title and Subject
- assertions to check if mandatory fields have value for Title, Subject and Revision

## Tests structure
Tests for Book ID: OL796465W
- Test passed: Title match csv value!
- Test passed: Subject match csv value!
- Test passed: Revision match csv value!
- Test passed: Author in Description match csv value!
- Test passed: ID 'OL796465W' is valid.
- Test passed: Title length is within limit.
- Test passed: Subject length is within limit.
- Test passed: Revision is numeric.
- Test passed: Title is not empty.
- Test passed: Subject is not empty.
- Test passed: Revision is not empty.

## Test Results 
110 tests passed (11 test executed for each of 10 Books)