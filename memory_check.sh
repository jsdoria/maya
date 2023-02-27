#!/bin/bash

CRITICAL_THRESHOLD=90
WARNING_THRESHOLD=60
EMAIL_ADDRESS="jasminedoria2895@yahoo.com"

while getopts ":c:w:e:" opt; do
  case $opt in
    c) CRITICAL_THRESHOLD=$OPTARG ;;
    w) WARNING_THRESHOLD=$OPTARG ;;
    e) EMAIL_ADDRESS=$OPTARG ;;
    \?) echo "Invalid option -$OPTARG" >&2 ;;
  esac
done


if [ $CRITICAL_THRESHOLD -le $WARNING_THRESHOLD ]; then
  echo "Critical threshold must be greater than warning threshold"
  echo "Usage: $0 -c critical_threshold -w warning_threshold -e email_address"
  exit 1
fi

MEMORY_USAGE=$(free | awk '/Mem/{printf("%.2f"), $3/$2*100}')


if (( $(echo "$MEMORY_USAGE >= $CRITICAL_THRESHOLD" | bc -l) )); then
  echo "CRITICAL - Memory usage is ${MEMORY_USAGE}%"
  if [ ! -z "$EMAIL_ADDRESS" ]; then
    echo "Sending email to $EMAIL_ADDRESS"
    echo "Memory usage is ${MEMORY_USAGE}%" | mail -s "Memory Usage Alert" $EMAIL_ADDRESS
  fi
  exit 2
fi


if (( $(echo "$MEMORY_USAGE >= $WARNING_THRESHOLD" | bc -l) )); then
  echo "WARNING - Memory usage is ${MEMORY_USAGE}%"
  exit 1
fi

echo "OK - Memory usage is ${MEMORY_USAGE}%"
exit 0
