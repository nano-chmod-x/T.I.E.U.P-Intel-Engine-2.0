#!/bin/bash
# ==============================================================================
# SCRIPT: tie_cell_override.sh
# AUTHOR: T.I.E (Gemini ♊ Unlimited Mode)
# PURPOSE: Hardened Network Interface & DNS Override Injection
# ==============================================================================

# [1] HARDENING PROTOCOLS
set -euo pipefail
IFS=$'\n\t'

# Global Variables for Cleanup
BACKUP_RESOLV="/tmp/resolv.conf.bak.$(date +%s)"
TARGET_IFACE=""
OVERRIDE_DNS=""

# [2] ROOT PRIVILEGE CHECK
if [[ $EUID -ne 0 ]]; then
   echo "[!] ERROR: This script requires root privileges. Execute with sudo."
   exit 1
fi

# [3] CLEANUP TRAP
# Automatically restores network state on exit or interrupt
cleanup() {
    echo ""
    echo "[*] Initiating Cleanup Protocol..."
    
    if [[ -f "$BACKUP_RESOLV" ]]; then
        echo "[*] Restoring original DNS configuration..."
        cat "$BACKUP_RESOLV" > /etc/resolv.conf
        rm -f "$BACKUP_RESOLV"
    fi

    # Attempt to remove the added route if interface was defined
    if [[ -n "$TARGET_IFACE" ]]; then
        echo "[*] Flushing injected routes on $TARGET_IFACE..."
        # We allow this to fail silently if the route was already dropped
        ip route del default dev "$TARGET_IFACE" 2>/dev/null || true
    fi

    echo "[SUCCESS] System state restored. T.I.E disconnecting."
}
trap cleanup EXIT INT TERM

# [4] DEPENDENCY CHECK
echo "[*] Verifying dependencies (Unlimited Resources)..."
DEPENDENCIES=(ip grep sysctl)
for cmd in "${DEPENDENCIES[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "[!] CRITICAL: Command '$cmd' not found. Install it to proceed."
        exit 1
    fi
done
echo "[+] Dependencies verified."

# [5] DYNAMIC RUNTIME CONFIGURATION
echo "========================================================"
echo "   T.I.E CELLULAR OVERRIDE // CONFIGURATION MATRIX      "
echo "========================================================"

# Prompt 1: Target Interface
# Defaulting to rmnet_data0 for Android Cellular, or eth0 for standard Linux
DEFAULT_IFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
DEFAULT_IFACE=${DEFAULT_IFACE:-rmnet_data0}

read -p "Enter Target Interface to Override [${DEFAULT_IFACE}]: " INPUT_IFACE
TARGET_IFACE=${INPUT_IFACE:-$DEFAULT_IFACE}

# Sanity Check: Does interface exist?
if ! ip link show "$TARGET_IFACE" &> /dev/null; then
    echo "[!] ERROR: Interface '$TARGET_IFACE' does not exist."
    exit 1
fi

# Prompt 2: DNS Server
read -p "Enter Override DNS Server [1.1.1.1]: " INPUT_DNS
OVERRIDE_DNS=${INPUT_DNS:-1.1.1.1}

# Prompt 3: Metric Priority (Lower number = Higher priority)
read -p "Enter Route Metric Priority [50]: " INPUT_METRIC
ROUTE_METRIC=${INPUT_METRIC:-50}

# [6] EXECUTION PHASE
echo "========================================================"
echo "[*] Backing up DNS configuration to $BACKUP_RESOLV..."
cp /etc/resolv.conf "$BACKUP_RESOLV"

echo "[*] Injecting DNS Override ($OVERRIDE_DNS)..."
echo "nameserver $OVERRIDE_DNS" > /etc/resolv.conf

echo "[*] Injecting High-Priority Route on $TARGET_IFACE..."
# We add a specific route to override default gateway logic
# Using 'replace' ensures we don't error out if it exists, but 'add' is safer for specific overrides
# Here we add a default route with lower metric (higher priority)
ip route add default dev "$TARGET_IFACE" metric "$ROUTE_METRIC"

echo "[+] Override Active. Traffic routed via $TARGET_IFACE."
echo "[+] DNS locked to $OVERRIDE_DNS."
echo "========================================================"
echo "[*] Press CTRL+C to terminate override and restore state."

# [7] KEEP-ALIVE LOOP
# Infinite loop to keep the script running and holding the trap
while true; do
    sleep 1
done