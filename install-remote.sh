#!/bin/bash
set -e

REPO="https://github.com/yudonglin/claude-usage-kde-tracker.git"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading Claude Usage Tracker..."
git clone --depth 1 "$REPO" "$TMPDIR"

cd "$TMPDIR"
./install.sh
