#!/bin/bash
set -euo pipefail

# === Silly Enterprises™ Installer ===
# curl -fsSL https://install.silly.enterprises | bash
# ----------------------------------------------

# Globals
REPO_URL="https://deb.silly.enterprises"
APT_SOURCE_PATH="/etc/apt/sources.list.d/silly.list"
APT_KEYRING_PATH="/etc/apt/keyrings"
USE_KEYRING=true
DEBUG=false

# === Color output ===
bold="\033[1m"
green="\033[1;32m"
yellow="\033[1;33m"
red="\033[1;31m"
reset="\033[0m"

log() { echo -e "$bold$green[+] $*$reset"; }
warn() { echo -e "$bold$yellow[!] $*$reset"; }
fail() { echo -e "$bold$red[✖] $*$reset" >&2; exit 1; }
debug() { $DEBUG && echo -e "$bold[debug] $*$reset"; }

# === Argument parser ===
for arg in "$@"; do
  case $arg in
    --debug)
      DEBUG=true
      debug "Debug mode enabled"
      ;;
    --no-keyring)
      USE_KEYRING=false
      debug "Keyring will NOT be used"
      ;;
    *)
      warn "Unknown option: $arg"
      ;;
  esac
done

# === OS Detection ===
get_os_info() {
  if [ -e /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    VERSION=$VERSION_ID
  else
    fail "Cannot detect OS — /etc/os-release missing."
  fi
  debug "Detected distro=$DISTRO, version=$VERSION"
}

# === Ubuntu Install ===
install_on_ubuntu() {
  log "Setting up Silly APT repo for Ubuntu $VERSION..."

  if [ "$USE_KEYRING" = true ]; then
    sudo mkdir -p "$APT_KEYRING_PATH"
    curl -fsSL "$REPO_URL/public.gpg" | sudo tee "$APT_KEYRING_PATH/silly-archive-keyring.gpg" > /dev/null
    sudo chmod go+r "$APT_KEYRING_PATH/silly-archive-keyring.gpg"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=$APT_KEYRING_PATH/silly-archive-keyring.gpg] $REPO_URL stable main" \
      | sudo tee "$APT_SOURCE_PATH" > /dev/null
  else
    echo "deb [trusted=yes] $REPO_URL stable main" | sudo tee "$APT_SOURCE_PATH" > /dev/null
  fi

  log "Repository configured. You can now install packages like this:"
  echo -e "$bold  sudo apt update && sudo apt install silly-full$reset"
}

# === Arch Placeholder ===
install_on_arch() {
  warn "Arch Linux support is coming soon™."
  echo "Please stand by for a pacman-powered future."
}

# === Main Logic ===
main() {
  get_os_info

  case "$DISTRO" in
    ubuntu|debian)
      install_on_ubuntu
      ;;
    arch)
      install_on_arch
      ;;
    *)
      warn "Unsupported distro: $DISTRO"
      echo "Please manually configure your package manager."
      exit 2
      ;;
  esac

  log "Done. Silly Enterprises™ is now partially operational 🛰️"
}

main "$@"