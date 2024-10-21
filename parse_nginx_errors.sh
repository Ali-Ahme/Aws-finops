#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <log_file> <hours>"
    exit 1
fi

LOG_FILE=$1
HOURS=$2

# Calculate end and start time
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
START_TIME=$(date -u -d "$HOURS hours ago" +"%Y-%m-%dT%H:%M:%SZ")

# Convert to Unix timestamps for comparison
start_timestamp=$(date -u -d "$START_TIME" +%s)
end_timestamp=$(date -u -d "$END_TIME" +%s)

echo "Generating report for the last $HOURS hours (from $START_TIME to $END_TIME)..."

# Initialize counters
declare -A status_counts
total_requests=0

# Read the log file
while IFS= read -r line; do
    # Extract the timestamp
    timestamp=$(echo "$line" | grep -o '\[.*\]' | tr -d '[]')

    # Convert the timestamp format
    if [[ $timestamp =~ ([0-9]{1,2})/([A-Za-z]{3})/([0-9]{4}):([0-9]{2}):([0-9]{2}):([0-9]{2}) ]]; then
        day=${BASH_REMATCH[1]}
        month=${BASH_REMATCH[2]}
        year=${BASH_REMATCH[3]}
        hour=${BASH_REMATCH[4]}
        minute=${BASH_REMATCH[5]}
        second=${BASH_REMATCH[6]}

        # Convert month from name to number
        case $month in
            Jan) month_num=01 ;;
            Feb) month_num=02 ;;
            Mar) month_num=03 ;;
            Apr) month_num=04 ;;
            May) month_num=05 ;;
            Jun) month_num=06 ;;
            Jul) month_num=07 ;;
            Aug) month_num=08 ;;
            Sep) month_num=09 ;;
            Oct) month_num=10 ;;
            Nov) month_num=11 ;;
            Dec) month_num=12 ;;
        esac
        
        # Create a new timestamp format in ISO 8601
        formatted_timestamp="$year-$month_num-$day $hour:$minute:$second"

        # Convert to Unix timestamp
        log_timestamp=$(date -u -d "$formatted_timestamp" +%s 2>/dev/null)

        # Check if log_timestamp is empty (meaning conversion failed)
        if [ -z "$log_timestamp" ]; then
            echo "Invalid timestamp: $formatted_timestamp"
            continue
        fi

        # Debugging: Print the log timestamp and the range
        echo "Log Timestamp: $log_timestamp"
        echo "Comparing with START_TIMESTAMP: $start_timestamp and END_TIMESTAMP: $end_timestamp"

        # Check if the log timestamp is within the specified range
        if (( log_timestamp > start_timestamp && log_timestamp < end_timestamp )); then
            status_code=$(echo "$line" | awk '{print $9}')
            ((total_requests++))
            ((status_counts[$status_code]++))
        fi
    else
        echo "Failed to extract timestamp from line: $line"
    fi
done < "$LOG_FILE"

# Print the results
echo "Total requests: $total_requests"
echo "Status code breakdown:"
for status in "${!status_counts[@]}"; do
    echo "$status: ${status_counts[$status]}"
done
