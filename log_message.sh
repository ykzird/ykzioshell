#!/bin/bash

# Simple logging function to log messages with log levels
log_message() {
    local LOG_FILE="${1:-command_output.log}"   # Log file is the first argument (optional), default 'command_output.log'
    local LOG_LEVEL="${2:-INFO}"                # Log level is the second argument (optional), default 'INFO'
    shift 2                                     # Remove log file and log level from arguments

    # Log the message with timestamp, log level, and the message content
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$LOG_LEVEL] $*" | tee -a "$LOG_FILE"
}

# Example usage:
# log_message my_log_file.log INFO "This is an info message"
# log_message my_log_file.log DEBUG "Debugging details here"
# log_message my_log_file.log ERR "An error occurred"

LOG_FILE="local.log"
log_message $LOG_FILE INFO "yuh"
log_message $LOG_FILE DEBUG "yuh"
log_message $LOG_FILE WARN "yuh"
log_message $LOG_FILE ERRRRRROR "yuh"

