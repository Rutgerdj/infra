OUTPUT_DIR=$1

if [ -z "$OUTPUT_DIR" ]; then
    echo "Error: Output directory not specified"
    echo "Usage: $0 /path/to/backup/directory"
    exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Error: Directory '$OUTPUT_DIR' does not exist"
    exit 1
fi

BW_SESSION="$(bw unlock --raw)"

bw export \
    --format encrypted_json \
    --output "$OUTPUT_DIR/bitwarden_backup.json" \
    --session $BW_SESSION
