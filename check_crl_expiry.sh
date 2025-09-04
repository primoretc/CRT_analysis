#!/bin/bash

# Configuration
CRL_URL="https://example.com/path/to/your.crl"  # URL для скачивания CRL
TEMP_DIR="/tmp/zabbix_crl_check"                # Временная директория
ALERT_DAYS=14                                   # Количество дней для алерта

# Create temp directory if not exists
mkdir -p "$TEMP_DIR"

# Generate temp filename
TEMP_FILE="$TEMP_DIR/$(basename "$CRL_URL").$$.tmp"

# Cleanup function
cleanup() {
    rm -f "$TEMP_FILE"
}

# Register cleanup on exit
trap cleanup EXIT

# Download CRL file
if ! wget -q "$CRL_URL" -O "$TEMP_FILE"; then
    echo "ERROR: Failed to download CRL from $CRL_URL" >&2
    exit 2
fi

# Try to read as DER first, then as PEM
NEXT_UPDATE=$(openssl crl -inform DER -in "$TEMP_FILE" -noout -nextupdate 2>/dev/null | cut -d'=' -f2)
if [ $? -ne 0 ]; then
    NEXT_UPDATE=$(openssl crl -inform PEM -in "$TEMP_FILE" -noout -nextupdate 2>/dev/null | cut -d'=' -f2)
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to parse CRL file (not DER or PEM format)" >&2
        exit 2
    fi
fi

# Convert dates to timestamps
NEXT_UPDATE_TIMESTAMP=$(date -d "$NEXT_UPDATE" +%s 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to parse date: $NEXT_UPDATE" >&2
    exit 2
fi

CURRENT_TIMESTAMP=$(date +%s)

# Calculate days remaining
SECONDS_LEFT=$((NEXT_UPDATE_TIMESTAMP - CURRENT_TIMESTAMP))
DAYS_LEFT=$((SECONDS_LEFT / 86400))

# Check if we need to alert
if [ "$DAYS_LEFT" -le "$ALERT_DAYS" ] && [ "$DAYS_LEFT" -ge 0 ]; then
    echo "1"  # Alert: CRL expires soon
    exit 0
elif [ "$DAYS_LEFT" -lt 0 ]; then
    echo "2"  # Critical: CRL already expired
    exit 0
else
    echo "0"  # OK: CRL is valid
    exit 0
fi
