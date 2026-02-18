#!/bin/bash
set -e

WIDGET_ID="com.github.huskydevclub.claude-usage-kde-tracker"
WIDGET_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if already installed — upgrade instead
if kpackagetool6 --type Plasma/Applet --list 2>/dev/null | grep -q "^${WIDGET_ID}$"; then
    echo "Upgrading existing installation..."
    kpackagetool6 --type Plasma/Applet --upgrade "$WIDGET_DIR"
else
    echo "Installing widget..."
    kpackagetool6 --type Plasma/Applet --install "$WIDGET_DIR"
fi

# Install icon to system icon theme so the widget explorer can find it
ICON_DIR="$HOME/.local/share/icons/hicolor"
mkdir -p "$ICON_DIR/256x256/apps"
cp "$WIDGET_DIR/screenshots/preview.png" "$ICON_DIR/256x256/apps/claude.png"
gtk-update-icon-cache "$ICON_DIR" 2>/dev/null || true

# Clear QML cache so Plasma picks up the new files
rm -rf ~/.cache/plasmashell/qmlcache

echo "Done. Restart plasmashell or log out/in to apply changes."
echo "  To restart manually: plasmashell --replace &disown"
echo "Add the widget via: right-click panel → Add Widgets → search 'Claude'"
