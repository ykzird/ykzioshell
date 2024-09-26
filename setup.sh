#!/bin/bash
# Imports ______________________________________________________________________

# Variables ____________________________________________________________________
dirname="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
filename="${__dirname}/$(basename "${BASH_SOURCE[0]}")";
#LOGFILE="/var/log/"$date"-setupscript.log"
LOG_FILE="logfile.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
LIGHT_PURPLE='\033[1;35m'
BOLD='\033[1m'
RESET='\033[0m'

# Functions ____________________________________________________________________
function print_welcome_text() {
echo -e "${CYAN}         _         _           _          _ _   ${RESET}"
echo -e "${LIGHT_PURPLE}        | |       (_)         | |        | | |  ${RESET}"
echo -e "${CYAN}   _   _| | __ _____  ___  ___| |__   ___| | |  ${RESET}"
echo -e "${LIGHT_PURPLE}  | | | | |/ /|_  / |/ _ \/ __| '_ \ / _ \ | |  ${RESET}"
echo -e "${CYAN}  | |_| |   <  / /| | (_) \__ \ | | |  __/ | |  ${RESET}"
echo -e "${LIGHT_PURPLE}   \__, |_|\_\/___|_|\___/|___/_| |_|\___|_|_|  ${RESET}"
echo -e "${CYAN}    __/ |                                       ${RESET}"
echo -e "${LIGHT_PURPLE}   |___/                                        ${RESET}"
echo -e ""
echo -e "${BOLD}${RED}Welcome to Ykzio Shell!${RESET}"
echo -e "Current version: ${BOLD}${GREEN}v.0.0.1${RESET}"; echo ""
}

# Logging function
# log_message() {
#     local LOG_FILE="${1:-setupscript.log}"
#     local LOG_LEVEL="${2:-INFO}"
#     shift 2

#     echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$LOG_LEVEL] $*" | tee -a "$LOGFILE"
# }
log_message() {
    local log_type="$1"
    shift
    local message="$*"
    local timestamp="[$(date '+%Y-%m-%d %H:%M:%S')]"

    # Log message without color codes for the log file
    case "$log_type" in
        INFO)
            echo -e "${timestamp} [INFO] $message" >> "$LOG_FILE"
            echo -e "${BOLD}${timestamp}${RESET} [${GREEN}INFO${RESET}] $message"
            ;;
        WARN)
            echo -e "${timestamp} [WARN] $message" >> "$LOG_FILE"
            echo -e "${BOLD}${timestamp}${RESET} [${YELLOW}WARN${RESET}] $message"
            ;;
        ERROR)
            echo -e "${timestamp} [ERROR] $message" >> "$LOG_FILE"
            echo -e "${BOLD}${timestamp}${RESET} [${RED}ERROR${RESET}] $message"
            ;;
        *)
            echo -e "${timestamp} [UNKNOWN] $message" >> "$LOG_FILE"
            echo -e "${BOLD}${timestamp}${RESET} [UNKNOWN] $message"
            ;;
    esac
}
# Determine OS name and Architecture dynamically.
get_os_info() {
    # Determine the OS name
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS_NAME="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_NAME="macos"
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
        OS_NAME="windows"
    else
        OS_NAME="unknown"
    fi

    # Determine the system architecture
    ARCHITECTURE=$(uname -m)

    # Normalize architecture names
    case "$ARCHITECTURE" in
        x86_64)
            ARCHITECTURE="amd64"
            ;;
        i386|i686)
            ARCHITECTURE="386"
            ;;
        armv7l)
            ARCHITECTURE="arm"
            ;;
        aarch64)
            ARCHITECTURE="arm64"
            ;;
    esac

    # Export the variables so they can be used later
    export OS_NAME
    export ARCHITECTURE
}

# Helper function to install packages if not installed
function install_if_not_installed() {
    if ! command -v $1 >/dev/null 2>&1; then
        log_message $LOGFILE "INFO" "Installing $1..."
        sudo apt-get update
        sudo apt-get install -y $1
    fi
}
# Helper function to import packages from a file into an array for usage
function declare_pkgs_array() {
  packages=()

  while IFS= read -r line; do
    packages+=("$line")
    done < packages
}
# Options ______________________________________________________________________
set -o errexit;
set -o pipefail;
set -o nounset;
# Initialize ___________________________________________________________________
main () {
    
    # TODO:
    # - Add support for other OSes
    # - Add support for other architectures
    # - Add support for other package managers
    # - Add docker installation if wanted
    # - Disable SSH passwords / ssh auth only

    # log_message $LOGFILE "INFO" "Starting setup..."

    # if [ "$EUID" -ne 0 ]; then
    # log_message $LOGFILE "INFO" "This script requires sudo privileges."
    # sudo -v  # Prompt for sudo password upfront
    # fi

    # log_message $LOGFILE "INFO" "Logs can be found at: $LOGFILE"

    # log_message $LOGFILE "INFO" "Determining OS and Architecture..."
    # get_os_info
    # log_message $LOGFILE "INFO" "Detected OS: "$OS_NAME" and Architecture: "$ARCHITECTURE

    # log_message $LOGFILE "INFO" "Determining packages to install from file..."
    # declare_pkgs_array

    # for package in "${packages[@]}"; do
    #     install_if_not_installed $package
    # done

    # log_message $LOGFILE "INFO" "Setup complete."
    # exit 0
    print_welcome_text

    log_message INFO "informationers"
    log_message WARN "warningioners"
    log_message ERROR "errorioners"
    log_message DEZEKENJENIET "dezekenjenietioners"
}

main "$@"
# EOF - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -