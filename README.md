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

## Validation explanation 
Books information is crawled using ID field from validation.csv.<br>
3 types of assertions are performed:
- assertions to check equality(or contains) between values from validation.csv and web API for fields Title, Subject, Revision, Author_in_Description
- assertions to check the type of the fields ID and Revision, and maximum length for fields Title and Subject
- assertions to check if mandatory fields have value for Title, Subject and Revision


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
