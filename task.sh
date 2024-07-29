#!/bin/bash
#
# Bash script that automates log file management
# by copying the contents of the /var/log/messages file
# to a new file named /var/log/messages.old with a timestamp.

# Define the log and backup files
LOG_FILE="/var/log/messages"
BACKUP_DIR="/var/log"
BACKUP_FILE="$BACKUP_DIR/messages.old"
REPORT_FILE="$BACKUP_DIR/log_analysis_report.txt"
MAX_BACKUPS=5

# Prompt the user for their name, age, and country
read -p "Please enter your name: " NAME
read -p "Please enter your age: " AGE
read -p "Please enter your country: " COUNTRY

# Validate age input
while ! [[ "$AGE" =~ ^[0-9]+$ ]] || [ "$AGE" -lt 1 ] || [ "$AGE" -gt 80 ]; do
    echo "Invalid age. Please enter a numeric value between 1 and 80."
    read -p "Please enter your age: " AGE
done

# Create a timestamp
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Check if the log file exists
if [ -f "$LOG_FILE" ]; then
    

    # Copy the log file to the backup file with a timestamp
    cp "$LOG_FILE" "${BACKUP_FILE}_$TIMESTAMP"

    # Append user information to the log file
    echo "The user is $NAME, he is $AGE years old, from $COUNTRY at $TIMESTAMP" >> $LOG_FILE


    # Rotate backups: keep only the latest $MAX_BACKUPS backups
    BACKUP_COUNT=$(ls -1 ${BACKUP_FILE}_* 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
        # Delete the oldest backups
        ls -1 ${BACKUP_FILE}_* | sort | head -n -"$MAX_BACKUPS" | xargs rm -f
    fi
    echo "Log file copied to ${BACKUP_FILE}_$TIMESTAMP"

    # Analyze the copied log file for errors, warnings, and critical events
    ERROR_COUNT=$(grep -i "error" "${BACKUP_FILE}_$TIMESTAMP" | wc -l)
    WARNING_COUNT=$(grep -i "warning" "${BACKUP_FILE}_$TIMESTAMP" | wc -l)
    CRITICAL_COUNT=$(grep -i "critical" "${BACKUP_FILE}_$TIMESTAMP" | wc -l)

    # Generate a detailed report
    echo "Log Analysis Report - $TIMESTAMP" > "$REPORT_FILE"
    echo "=================================" >> "$REPORT_FILE"
    echo "User: $NAME, Age: $AGE, Country: $COUNTRY" >> "$REPORT_FILE"
    echo "---------------------------------" >> "$REPORT_FILE"
    echo "Total Errors: $ERROR_COUNT" >> "$REPORT_FILE"
    echo "Total Warnings: $WARNING_COUNT" >> "$REPORT_FILE"
    echo "Total Critical Events: $CRITICAL_COUNT" >> "$REPORT_FILE"
    echo "---------------------------------" >> "$REPORT_FILE"
    echo "Top 5 Errors:" >> "$REPORT_FILE"
    grep -i "error" "${BACKUP_FILE}_$TIMESTAMP" | head -n 5 >> "$REPORT_FILE"
    echo "---------------------------------" >> "$REPORT_FILE"
    echo "Top 5 Warnings:" >> "$REPORT_FILE"
    grep -i "warning" "${BACKUP_FILE}_$TIMESTAMP" | head -n 5 >> "$REPORT_FILE"
    echo "---------------------------------" >> "$REPORT_FILE"
    echo "Top 5 Critical Events:" >> "$REPORT_FILE"
    grep -i "critical" "${BACKUP_FILE}_$TIMESTAMP" | head -n 5 >> "$REPORT_FILE"

    echo "Log analysis report saved to $REPORT_FILE"
else
    echo "Log file does not exist: $LOG_FILE."
    exit 1
fi

# Optionally clear original file content (uncomment if needed)
#truncate -s 0 "$LOG_FILE"
#if [ $? -ne 0 ]; then
#    echo "Failed to clear content of $LOG_FILE."
#    exit 1
#fi

#echo "Log file cleared successfully!"

# Log the user information to the backup file
echo "The user is $NAME, he is $AGE years old, from $COUNTRY at $(date)" >> "${BACKUP_FILE}_$TIMESTAMP"

exit 0

