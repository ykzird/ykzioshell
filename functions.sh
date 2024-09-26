#!/bin/bash
function determine_os() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "$ID $VERSION_ID"
  elif type lsb_release >/dev/null 2>&1; then
    lsb_release -s -i
    lsb_release -s -r
  elif [[ -f /etc/lsb-release ]]; then
    . /etc/lsb-release
    echo "$DISTRIB_ID $DISTRIB_RELEASE"
  elif [[ -f /etc/debian_version ]]; then
    echo "Debian $(cat /etc/debian_version)"
  else
    echo "Other"
  fi
}

function determine_arch() {
    if [[ "$(uname -m)" == "x86_64" ]]; then
        echo "x86_64"
    elif [[ "$(uname -m)" == "aarch64" ]]; then
        echo "aarch64"
    else
        echo "unknown"
    fi
}

function install_if_not_installed() {
    if ! command -v $1 >/dev/null 2>&1; then
        echo "Installing $1..."
        sudo apt-get update
        sudo apt-get install -y $1
    fi
}

function declare_pkgs_array() {
  packages=()

  while IFS= read -r line; do
    packages+=("$line")
    done < packages
}













# function check_package_existence() {
#   for package in "${packages[@]}"; do
#     echo "$package"
# done
# }



# for package in "${required_packages[@]}"; do
#     install_if_not_installed $package
# done;

