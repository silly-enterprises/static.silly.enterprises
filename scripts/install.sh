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
DRY_RUN=false

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="/tmp/silly-install-$TIMESTAMP.log"

# === Color output ===
bold="\033[1m"
green="\033[1;32m"
yellow="\033[1;33m"
red="\033[1;31m"
reset="\033[0m"

log() {
  echo -e "$bold$green[+] $*$reset"
  echo "[+] $*" >> "$LOG_FILE"
}
warn() {
  echo -e "$bold$yellow[!] $*$reset"
  echo "[!] $*" >> "$LOG_FILE"
}
fail() {
  echo -e "$bold$red[✖] $*$reset" >&2
  echo "[✖] $*" >> "$LOG_FILE"
  exit 1
}
debug() {
  if [ "$DEBUG" = true ]; then
    echo -e "$bold[debug] $*$reset"
    echo "[debug] $*" >> "$LOG_FILE"
  fi
}
dryrun() {
  echo -e "$bold[dry-run] $*$reset"
  echo "[dry-run] $*" >> "$LOG_FILE"
}
run() {
  if [ "$DRY_RUN" = true ]; then
    dryrun "$*"
  else
    log "$*"
    eval "$@" 2>&1 | tee -a "$LOG_FILE"
  fi
}

# === Bail if run inside Windows/PowerShell (basic safety net) ===
if [ "${OS:-}" = "Windows_NT" ]; then
  echo -e "$red❌ This script must be run in a Bash or Linux shell.$reset"
  echo -e "$boldTry using WSL, Ubuntu, or a Linux VM.$reset"
  echo "[✖] Detected Windows environment. Exiting." >> "$LOG_FILE"
  exit 1
fi

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
    --dry-run)
      DRY_RUN=true
      log "Dry-run mode enabled. No changes will be made."
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
    run "sudo mkdir -p $APT_KEYRING_PATH"
    run "curl -fsSL $REPO_URL/public.gpg | sudo tee $APT_KEYRING_PATH/silly-archive-keyring.gpg > /dev/null"
    run "sudo chmod go+r $APT_KEYRING_PATH/silly-archive-keyring.gpg"
    run "echo 'deb [arch=$(dpkg --print-architecture) signed-by=$APT_KEYRING_PATH/silly-archive-keyring.gpg] $REPO_URL stable main' | sudo tee $APT_SOURCE_PATH > /dev/null"
  else
    run "echo 'deb [trusted=yes] $REPO_URL stable main' | sudo tee $APT_SOURCE_PATH > /dev/null"
  fi

  log "Repository configured. You can now install packages like this:"
  echo -e "$bold  sudo apt update && sudo apt install silly-full$reset"
  echo "[+] Hint: sudo apt update && sudo apt install silly-full" >> "$LOG_FILE"
}

# === Arch Placeholder ===
install_on_arch() {
  warn "Arch Linux support is coming soon™."
  echo "Please stand by for a pacman-powered future."
  echo "[!] Arch Linux detected. Placeholder only." >> "$LOG_FILE"
}

# === Main Logic ===
main() {
  log "Logging to $LOG_FILE"
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
      echo "[✖] Unsupported distro: $DISTRO" >> "$LOG_FILE"
      exit 2
      ;;
  esac

  log "Done! Thank your for participating in Silly Enterprises™'s Botnet 🛰️"
  echo "[+] Install completed successfully" >> "$LOG_FILE"
}

main "$@"