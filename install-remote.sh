#!/bin/bash
set -e

REPO="HuskyDevClub/claude-usage-kde-tracker"
BRANCH="main"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading Claude Usage Tracker..."

if command -v curl &>/dev/null; then
    curl -sL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar xz -C "$TMPDIR" --strip-components=1
elif command -v wget &>/dev/null; then
    wget -qO- "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar xz -C "$TMPDIR" --strip-components=1
else
    echo "Error: curl or wget is required" >&2
    exit 1
fi

cd "$TMPDIR"
./install.sh
