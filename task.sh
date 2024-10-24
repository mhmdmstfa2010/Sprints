#!/bin/bash

# Bash script that automates log file management
# by copying the contents of the /var/log/messages file
# to a new file named /var/log/messages.old with a timestamp.
# Now includes advanced debugging, performance optimization, and CPU utilization monitoring.

# Default configurations
LOG_FILE="/var/log/messages"
BACKUP_DIR="/var/log"
BACKUP_FILE="$BACKUP_DIR/messages.old"
REPORT_FILE="$BACKUP_DIR/log_analysis_report.txt"
MAX_BACKUPS=5
ANALYSIS_CRITERIA="error,warning,critical"
REPORT_FORMAT="txt"
DEBUG=false
CPU_MONITOR_INTERVAL=5

# Function to display help message
function show_help {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -l, --log-file       Path to the log file (default: /var/log/messages)"
    echo "  -b, --backup-dir     Directory to store backup files (default: /var/log)"
    echo "  -m, --max-backups    Maximum number of backups to keep (default: 5)"
    echo "  -a, --analysis       Comma-separated list of analysis criteria (default: error,warning,critical)"
    echo "  -f, --format         Report format (txt or json) (default: txt)"
    echo "  -c, --config         Path to configuration file"
    echo "  -d, --debug          Enable debugging"
    echo "  -h, --help           Display this help message"
}

# Function to load configurations from a file
function load_config {
    if [ -f "$1" ]; then
        source "$1"
    else
        echo "Configuration file not found: $1"
        exit 1
    fi
}

# Function to log debug messages
function debug_log {
    if [ "$DEBUG" = true ]; then
        echo "[DEBUG] $1"
    fi
}

# Function to monitor CPU utilization
function monitor_cpu {
    while :; do
        mpstat 1 1 | awk '/Average/ {print "CPU Usage: " 100 - $NF "%"}'
        sleep "$CPU_MONITOR_INTERVAL"
    done
 mlkkdikeoikjwje
 }

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -l|--log-file) LOG_FILE="$2"; shift ;;
        -b|--backup-dir) BACKUP_DIR="$2"; shift ;;
        -m|--max-backups) MAX_BACKUPS="$2"; shift ;;
        -a|--analysis) ANALYSIS_CRITERIA="$2"; shift ;;
        -f|--format) REPORT_FORMAT="$2"; shift ;;
        -c|--config) load_config "$2"; shift ;;
        -d|--debug) DEBUG=true ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
    shift
done

BACKUP_FILE="$BACKUP_DIR/messages.old"
REPORT_FILE="$BACKUP_DIR/log_analysis_report.$REPORT_FORMAT"

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

# Start CPU monitoring in the background
monitor_cpu & CPU_MONITOR_PID=$!

# Check if the log file exists
if [ -f "$LOG_FILE" ]; then
    # Append user information to the log file
    echo "The user is $NAME, they are $AGE years old, they are from $COUNTRY at $TIMESTAMP" >> "$LOG_FILE"

    debug_log "Copying log file to backup with timestamp."
    # Copy the log file to the backup file with a timestamp
    cp "$LOG_FILE" "${BACKUP_FILE}_$TIMESTAMP"

    # Rotate backups: keep only the latest $MAX_BACKUPS backups
    debug_log "Rotating backups, keeping only the latest $MAX_BACKUPS backups."
    BACKUP_COUNT=$(ls -1 ${BACKUP_FILE}_* 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
        # Delete the oldest backups
        ls -1 ${BACKUP_FILE}_* | sort | head -n -"$MAX_BACKUPS" | xargs rm -f
    fi

    echo "Log file copied to ${BACKUP_FILE}_$TIMESTAMP"

    # Analyze the copied log file based on criteria
    IFS=',' read -ra CRITERIA <<< "$ANALYSIS_CRITERIA"
    declare -A ANALYSIS_RESULTS
    for criterion in "${CRITERIA[@]}"; do
        ANALYSIS_RESULTS[$criterion]=$(grep -i "$criterion" "${BACKUP_FILE}_$TIMESTAMP" | wc -l)
    done

    # Generate a detailed report
    if [ "$REPORT_FORMAT" == "txt" ]; then
        echo "Log Analysis Report - $TIMESTAMP" > "$REPORT_FILE"
        echo "=================================" >> "$REPORT_FILE"
        echo "User: $NAME, Age: $AGE, Country: $COUNTRY" >> "$REPORT_FILE"
        echo "---------------------------------" >> "$REPORT_FILE"
        for criterion in "${CRITERIA[@]}"; do
            echo "Total ${criterion^}s: ${ANALYSIS_RESULTS[$criterion]}" >> "$REPORT_FILE"
            echo "---------------------------------" >> "$REPORT_FILE"
            echo "Top 5 ${criterion^}s:" >> "$REPORT_FILE"
            grep -i "$criterion" "${BACKUP_FILE}_$TIMESTAMP" | head -n 5 >> "$REPORT_FILE"
            echo "---------------------------------" >> "$REPORT_FILE"
        done
        echo "Log analysis report saved to $REPORT_FILE"
    elif [ "$REPORT_FORMAT" == "json" ]; then
        echo "{" > "$REPORT_FILE"
        echo "  \"timestamp\": \"$TIMESTAMP\"," >> "$REPORT_FILE"
        echo "  \"user\": \"$NAME\"," >> "$REPORT_FILE"
        echo "  \"age\": \"$AGE\"," >> "$REPORT_FILE"
        echo "  \"country\": \"$COUNTRY\"," >> "$REPORT_FILE"
        echo "  \"analysis\": {" >> "$REPORT_FILE"
        for criterion in "${!ANALYSIS_RESULTS[@]}"; do
            echo "    \"$criterion\": {" >> "$REPORT_FILE"
            echo "      \"total\": ${ANALYSIS_RESULTS[$criterion]}," >> "$REPORT_FILE"
            echo "      \"top_5\": [" >> "$REPORT_FILE"
            grep -i "$criterion" "${BACKUP_FILE}_$TIMESTAMP" | head -n 5 | sed 's/^/        \"/;s/$/\",/' | sed '$ s/,$//' >> "$REPORT_FILE"
            echo "      ]" >> "$REPORT_FILE"
            echo "    }," >> "$REPORT_FILE"
        done
        sed -i '$ s/,$//' "$REPORT_FILE"  # Remove the last comma
        echo "  }" >> "$REPORT_FILE"
        echo "}" >> "$REPORT_FILE"
        echo "Log analysis report saved to $REPORT_FILE"
    else
        echo "Unknown report format: $REPORT_FORMAT"
        exit 1
    fi
else
    echo "Log file does not exist: $LOG_FILE."
    exit 1
fi

# Clear original file content
truncate -s 0 "$LOG_FILE"
if [ $? -ne 0 ]; then
    echo "Failed to clear content of $LOG_FILE."
    exit 1
fi

echo "Log file cleared successfully!"
echo "The user is $NAME, he is $AGE years old, from $COUNTRY at $TIMESTAMP" > "${BACKUP_FILE}_$TIMESTAMP"

# Stop CPU monitoring
kill $CPU_MONITOR_PID

exit 0

