#!/bin/bash
# T.I.E.U.P Directive: Full System Synchronization
# Target: Kali NetHunter Root Filesystem

set -euo pipefail

echo "[*] Synchronizing package index files..."
apt-get update

echo "[*] Upgrading installed packages..."
apt-get upgrade -y

echo "[*] Performing distribution upgrade for kernel/dependency changes..."
apt-get dist-upgrade -y

echo "[*] Removing obsolete package files..."
apt-get autoclean

echo "[SUCCESS] System is fully patched and operational."