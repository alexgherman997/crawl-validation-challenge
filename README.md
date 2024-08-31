# Crawl data and validation 
Crawling data from web API with books information and validating it using bash scripting and csv file.

## Installation steps  
- clone repository 
- chmod +x crawl-script.sh - give execution rights for script run
- brew install jq - install jq command to parse JSON using 

## Execution 
- ./crawl-script.sh

## Assertion structure
Assertion for Book ID: OL1317211W 
   Assertion passed: Title match!
   Assertion passed: Subject match!
   Assertion passed: Revision match!
   Assertion passed: API Revision is numeric!
   Assertion passed: Author in Description match!
