#!/bin/bash
file_name=$1
query=$2
if [[ "$file_name" == '--help' || -z "$file_name" ]]; then

	echo "Filter selected log types from log files"
	echo "Usage: $0 [file_name] [query]"
	exit 0;
fi

if [[ $EUID -ne 0 ]]; then
   echo "ERROR: This script must run with root permissions (sudo)." 
   echo "Please try again: sudo $0"
   exit 1
fi

if [[ ! -f "$file_name" ]]; then
	echo "Error: File '$file_name' not found!"
	exit 1
fi

grep "$query:" -i "$file_name" 2>log_error | cut -d "]" -f 2| sort | uniq -c > temp_results

if [[ -s temp_results ]]; then
    echo "$file_name/$query ANALYSIS REPORT - $(date)" > log_reports
    echo '_______________________________________________' >> log_reports
    cat temp_results >> log_reports
    echo "Analysis completed."
    echo "Filtered result saved to \"log_reports\" file."
    rm -f temp_results log_error
    exit 0
else
	if [[ -s log_error ]]; then
	echo "Operation Failed."
        cat log_error
   else
        echo "No matching records found."
    	rm -f temp_results log_error
    	fi
   exit 1
fi

