#!/bin/bash

# Prompt user for log group and stream
read -p "Enter Log Group Name: " LOG_GROUP_NAME
read -p "Enter Log Stream Name: " LOG_STREAM_NAME

# Output filename
OUTPUT_FILE="logs_${LOG_STREAM_NAME//\//_}.txt"

echo "Downloading all logs from:"
echo "  Log Group : $LOG_GROUP_NAME"
echo "  Log Stream: $LOG_STREAM_NAME"
echo "  Output    : $OUTPUT_FILE"
echo

# Initialize
>"$OUTPUT_FILE"
NEXT_TOKEN=""
PREV_TOKEN="init"

# Loop until nextForwardToken stops changing
while [ "$NEXT_TOKEN" != "$PREV_TOKEN" ]; do
  if [ -z "$NEXT_TOKEN" ]; then
    RESPONSE=$(aws logs get-log-events \
      --log-group-name "$LOG_GROUP_NAME" \
      --log-stream-name "$LOG_STREAM_NAME" \
      --limit 10000 \
      --start-from-head \
      --output json)
  else
    RESPONSE=$(aws logs get-log-events \
      --log-group-name "$LOG_GROUP_NAME" \
      --log-stream-name "$LOG_STREAM_NAME" \
      --limit 10000 \
      --start-from-head \
      --next-token "$NEXT_TOKEN" \
      --output json)
  fi

  # Append messages to file
  echo "$RESPONSE" | jq -r '.events[].message' >>"$OUTPUT_FILE"w

  PREV_TOKEN="$NEXT_TOKEN"
  NEXT_TOKEN=$(echo "$RESPONSE" | jq -r '.nextForwardToken')
done

echo "✅ Completed. Logs saved to: $OUTPUT_FILE"
