#!/bin/bash
set -e

WIDGET_ID="com.github.yudonglin.claude-usage-tracker"

if kpackagetool6 --type Plasma/Applet --list 2>/dev/null | grep -q "^${WIDGET_ID}$"; then
    kpackagetool6 --type Plasma/Applet --remove "$WIDGET_ID"
    echo "Widget uninstalled."
else
    echo "Widget is not installed."
fi
