#!/bin/bash
#
# Script Name: download_logs_between.sh
#
# Description:
#   Download all log events from a given CloudWatch log group + log stream
#   between two timestamps, and save them into a JSON file.
#
# Usage:
#   ./download_logs_between.sh
#
#   Prompts for:
#     - Log Group Name
#     - Log Stream Name
#     - Start Time (e.g. "2025-09-29 11:40:00")
#     - End Time   (e.g. "2025-09-29 12:00:00")
#     - Timezone (default = Asia/Tokyo)
#

# Prompt user
read -p "Enter Log Group Name: " LOG_GROUP_NAME
read -p "Enter Log Stream Name: " LOG_STREAM_NAME
read -p "Enter Start Time (e.g., 2025-09-29 11:40:00): " START_TIME
read -p "Enter End Time   (e.g., 2025-09-29 12:00:00): " END_TIME
read -p "Enter timezone (default: Asia/Tokyo): " TIMEZONE

# Default timezone
if [ -z "$TIMEZONE" ]; then
  TIMEZONE="Asia/Tokyo"
fi

# Convert to epoch ms
START_EPOCH=$(TZ="$TIMEZONE" date -d "$START_TIME" +%s)000
END_EPOCH=$(TZ="$TIMEZONE" date -d "$END_TIME" +%s)000

# Output file
OUTPUT_FILE="logs_${LOG_STREAM_NAME//\//_}_$(date +%Y%m%d%H%M%S).json"

echo "Downloading logs..."
echo "  Log Group : $LOG_GROUP_NAME"
echo "  Log Stream: $LOG_STREAM_NAME"
echo "  Start Time: $START_TIME ($TIMEZONE)"
echo "  End Time  : $END_TIME ($TIMEZONE)"
echo "  Output    : $OUTPUT_FILE"
echo

# Run query
aws logs get-log-events \
  --log-group-name "$LOG_GROUP_NAME" \
  --log-stream-name "$LOG_STREAM_NAME" \
  --start-time "$START_EPOCH" \
  --end-time "$END_EPOCH" \
  --output json > "$OUTPUT_FILE"

echo "✅ Completed. Logs saved to: $OUTPUT_FILE"
