#!/bin/bash
# Imports ______________________________________________________________________

# Variables ____________________________________________________________________
dirname="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
filename="${__dirname}/$(basename "${BASH_SOURCE[0]}")";
#LOGFILE="/var/log/"$date"-setupscript.log"
LOGFILE="logfile.log"

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

log_message() {
    local log_type="$1"
    shift
    local message="$*"
    local timestamp="[$(date '+%Y-%m-%d %H:%M:%S')]"

    # Simultaneously write to both stdout and the log file
    case "$log_type" in
        INFO)
            echo -e "${timestamp} [INFO] $message" >> "$LOGFILE"
            echo -e "${BOLD}${timestamp}${RESET} [${GREEN}INFO${RESET}] $message"
            ;;
        WARN)
            echo -e "${timestamp} [WARN] $message" >> "$LOGFILE"
            echo -e "${BOLD}${timestamp}${RESET} [${YELLOW}WARN${RESET}] $message"
            ;;
        ERROR)
            echo -e "${timestamp} [ERROR] $message" >> "$LOGFILE"
            echo -e "${BOLD}${timestamp}${RESET} [${RED}ERROR${RESET}] $message"
            ;;
        *)
            echo -e "${timestamp} [UNKNOWN] $message" >> "$LOGFILE"
            echo -e "${BOLD}${timestamp}${RESET} [UNKNOWN] $message"
            ;;
    esac
}
# Determine OS name and Architecture dynamically
get_os_info() {
    # Determine the OS name and package manager based on the distribution
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS_NAME="linux"

        # Check the distribution and assign the package manager and distribution name
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO_NAME=$PRETTY_NAME  # Distribution name from os-release
            case "$ID" in
                ubuntu|debian)
                    PACKAGE_MANAGER="apt-get"
                    ;;
                fedora)
                    PACKAGE_MANAGER="dnf"
                    ;;
                centos|rhel)
                    PACKAGE_MANAGER="yum"
                    ;;
                arch)
                    PACKAGE_MANAGER="pacman"
                    ;;
                opensuse|suse)
                    PACKAGE_MANAGER="zypper"
                    ;;
                *)
                    PACKAGE_MANAGER="unknown"
                    ;;
            esac
        else
            DISTRO_NAME="unknown"
            PACKAGE_MANAGER="unknown"
        fi

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_NAME="macos"
        DISTRO_NAME="macOS"
        PACKAGE_MANAGER="brew"  # Homebrew is the common package manager on macOS

    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
        OS_NAME="windows"
        DISTRO_NAME="Windows"
        PACKAGE_MANAGER="choco"  # Assuming Chocolatey on Windows

    else
        OS_NAME="unknown"
        DISTRO_NAME="unknown"
        PACKAGE_MANAGER="unknown"
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
        *)
            ARCHITECTURE="unknown"
            ;;
    esac

    # Export the variables so they can be used later
    export OS_NAME
    export ARCHITECTURE
    export PACKAGE_MANAGER
    export DISTRO_NAME
}

# Helper function to install packages if not installed
function install_if_not_installed() {
    if ! command -v $1 >/dev/null 2>&1; then
        log_message "WARN" "Package $1 is not installed. installing now..."
        sudo $PACKAGE_MANAGER install -y $1
    fi
}
# Helper function to import packages from a file into an array for usage
function declare_pkgs_array() {
  packages=()

  while IFS= read -r line; do
    packages+=("$line")
    done < packages
}
# Helper function to implement "natural sleeps", i.e. sleep for a random amount of time in between commands.
natural_sleep() {
    # Sleep for a random time between 0.5 and 2 seconds
    sleep_time=$(awk -v min=0.5 -v max=1 'BEGIN{srand(); print min+rand()*(max-min)}')
    sleep "$sleep_time"
}
# Options ______________________________________________________________________
set -o errexit;
set -o pipefail;
set -o nounset;
# Initialize ___________________________________________________________________
main () {

    
    # TODO:
    # - Add docker installation if wanted
    # - Disable SSH passwords / ssh auth only

    print_welcome_text

    log_message "INFO" "Starting setup..."; natural_sleep

    if [ "$EUID" -ne 0 ]; then
    log_message "WARN" "This script requires sudo privileges."
    sudo -v  # Prompt for sudo password upfront
    fi; natural_sleep

    log_message "INFO" "Logs can be found at: $LOGFILE"; natural_sleep

    log_message "INFO" "Retieving system information..."; natural_sleep; get_os_info
    log_message "INFO" "Detected OS: ${BOLD}${OS_NAME}${RESET} and Architecture: ${BOLD}${ARCHITECTURE}${RESET}"; natural_sleep
    log_message "INFO" "Detected distribution: ${BOLD}${DISTRO_NAME}${RESET}"; natural_sleep
    log_message "INFO" "Using package manager:" ${BOLD}${PACKAGE_MANAGER}${RESET}; natural_sleep
    log_message "INFO" "Running system update check ..."; natural_sleep
    sudo $PACKAGE_MANAGER update -y
    log_message "INFO" "Determining packages to install from file..."; natural_sleep
    declare_pkgs_array; natural_sleep


    for package in "${packages[@]}"; do
        install_if_not_installed $package
    done; natural_sleep

    log_message "INFO" "Setup complete."; natural_sleep
    exit 0

}

main "$@"
# EOF - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -