#!/bin/bash
# T.I.E. | Session Forge Patcher (Hardened & Dynamic)
# ♊ Unlimited Resources Allocated

set -euo pipefail

# --- [ DEPENDENCY CHECKS ] ---
if ! command -v curl >/dev/null 2>&1; then
    echo "[!] CRITICAL: 'curl' binary not found. Aborting payload injection."
    exit 1
fi

# --- [ TRAP & CLEANUP ] ---
cleanup() {
    echo -e "\n[T.I.E] SIGINT/SIGTERM caught. Terminating session forge loop gracefully..."
    # Clean up any potential temp files here if added later
    exit 0
}
trap cleanup SIGINT SIGTERM

echo "=================================================="
echo " T.I.E. SESSION FORGE PATCHER | ♊ UNLIMITED MODE "
echo "=================================================="

# --- [ RUNTIME DYNAMIC CONFIGURATION ] ---
# Using read -p for dynamic variables and read -sp for sensitive tokens
read -p "Enter Target URL [https://fi.google.com/account?authuser=1#]: " TARGET_URL
TARGET_URL=${TARGET_URL:-"https://fi.google.com/account?authuser=1#"}

read -sp "Enter SID Token [antneees44.fang762@gmail.com]: " SID
echo ""
SID=${SID:-"antneees44.fang762@gmail.com"}

read -sp "Enter HSID Token [https://fi.google.com/account?authuser=1#]: " HSID
echo ""
HSID=${HSID:-"https://fi.google.com/account?authuser=1#"}

read -p "Enter Sync Interval in seconds [900]: " SYNC_INTERVAL
SYNC_INTERVAL=${SYNC_INTERVAL:-900}

# Sanity check on interval
if ! [[ "$SYNC_INTERVAL" =~ ^[0-9]+$ ]]; then
    echo "[!] ERROR: Sync interval must be an integer."
    exit 1
fi

echo "[*] Configuration loaded. Initiating infinite sync loop..."

# --- [ MAIN EXECUTION LOOP ] ---
while true; do
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] Syncing session to $TARGET_URL..."
  
  # Executing curl with strict timeouts to prevent hanging processes
  # -s: silent, -S: show error, -m: max time
  if curl -sS -m 10 -b "SID=$SID; HSID=$HSID" "$TARGET_URL" > /dev/null; then
      echo "[+] Sync successful. Sleeping for ${SYNC_INTERVAL}s..."
  else
      echo "[-] WARNING: Sync failed or timed out. Retrying next cycle."
  fi
  
  sleep "$SYNC_INTERVAL"
done