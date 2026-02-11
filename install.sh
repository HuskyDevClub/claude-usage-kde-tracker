#!/bin/bash
set -e

WIDGET_ID="com.github.yudonglin.claude-usage-tracker"
WIDGET_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if already installed — upgrade instead
if kpackagetool6 --type Plasma/Applet --list 2>/dev/null | grep -q "^${WIDGET_ID}$"; then
    echo "Upgrading existing installation..."
    kpackagetool6 --type Plasma/Applet --upgrade "$WIDGET_DIR"
else
    echo "Installing widget..."
    kpackagetool6 --type Plasma/Applet --install "$WIDGET_DIR"
fi

# Clear QML cache so Plasma picks up the new files
rm -rf ~/.cache/plasmashell/qmlcache

echo "Done. Restarting plasmashell to apply changes..."
plasmashell --replace &disown 2>/dev/null

echo "Add the widget via: right-click panel → Add Widgets → search 'Claude'"
