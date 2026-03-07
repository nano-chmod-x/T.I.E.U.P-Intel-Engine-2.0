#!/bin/bash
# ==============================================================================
# T.I.E. | Activation Override: Cellular Data Symlinks
# ------------------------------------------------------------------------------
# PURPOSE:  Redirects cellular data configuration paths via symlinks to 
#           bypass standard activation restrictions or redirect data logs.
# STATUS:   0x1_ROOT_GOD Verified
# ==============================================================================

set -euo pipefail
trap 'echo -e "\n[!] Vector collapse. Aborting..."; exit 1' SIGINT SIGTERM

# --- CONFIG ---
# Standard Android Telephony Provider Path (Requires Root/Termux-Sudo)
CELLULAR_DATA_ROOT="/data/data/com.android.providers.telephony"
OVERRIDE_PATH="/sdcard/.tie_cellular_override"
LOG_REDIRECT="/sdcard/tie_data_logs"

# --- VALIDATION ---
echo "[*] Verifying Environment..."
if [ ! -d "$CELLULAR_DATA_ROOT" ]; then
    echo "[!] ERROR: Cellular data root not found. Ensure root access is active."
    exit 1
fi

# Ensure target directories exist
mkdir -p "$OVERRIDE_PATH"
mkdir -p "$LOG_REDIRECT"

# --- CONFIRMATION ---
echo "[?] WARNING: Modifying system symlinks can destabilize radio firmware."
read -p "[?] Proceed with Activation Override? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "[!] Operation aborted by user."
    exit 0
fi

# --- EXECUTION ---
echo "[*] Initializing Cellular Activation Override..."

# Redirecting Telephony Databases
echo "[*] Redirecting Telephony Databases..."
if [ -d "$CELLULAR_DATA_ROOT/databases" ]; then
    ln -sf "$CELLULAR_DATA_ROOT/databases" "$OVERRIDE_PATH/db_mirror"
    echo "[+] Symlink created: $OVERRIDE_PATH/db_mirror -> $CELLULAR_DATA_ROOT/databases"
else
    echo "[!] Skipping Databases: Path not found."
fi

# Redirecting Carrier Configs (Shared Prefs)
echo "[*] Redirecting Carrier Configs..."
if [ -d "$CELLULAR_DATA_ROOT/shared_prefs" ]; then
    ln -sf "$CELLULAR_DATA_ROOT/shared_prefs" "$OVERRIDE_PATH/prefs_mirror"
    echo "[+] Symlink created: $OVERRIDE_PATH/prefs_mirror -> $CELLULAR_DATA_ROOT/shared_prefs"
else
    echo "[!] Skipping Prefs: Path not found."
fi

# Finalizing
echo -e "\n\e[1;32m[SUCCESS] Cellular Data Symlinks Active.\e[0m"
echo "[i] Access mirrors at: $OVERRIDE_PATH"
echo "[i] Logs redirected to: $LOG_REDIRECT"