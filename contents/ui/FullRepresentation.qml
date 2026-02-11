import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

PlasmaExtras.Representation {
    id: fullRoot

    implicitWidth: Kirigami.Units.gridUnit * 22
    implicitHeight: contentLayout.implicitHeight + Kirigami.Units.largeSpacing * 2

    // Usage data model for the main bars
    property var usageModel: [
        {title: "Current Session", percent: root.sessionPercent, resetsAt: root.sessionResetsAt},
        {title: "Weekly Limits", percent: root.weeklyPercent, resetsAt: root.weeklyResetsAt}
    ]

    header: PlasmaExtras.PlasmoidHeading
    {
        RowLayout {
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            PlasmaExtras.Heading {
                Layout.fillWidth: true
                level: 2
                text: "Claude Usage"
            }

            // Plan badge
            Rectangle {
                visible: root.subscriptionType !== "" && root.subscriptionType !== "unknown"
                Layout.alignment: Qt.AlignVCenter
                width: badgeText.implicitWidth + Kirigami.Units.smallSpacing * 2
                height: badgeText.implicitHeight + Kirigami.Units.smallSpacing
                radius: height / 2
                color: Qt.alpha(Kirigami.Theme.highlightColor, 0.2)
                border.color: Kirigami.Theme.highlightColor
                border.width: 1

                PlasmaComponents.Label {
                    id: badgeText
                    anchors.centerIn: parent
                    text: root.subscriptionType.charAt(0).toUpperCase() + root.subscriptionType.slice(1)
                    font: Kirigami.Theme.smallFont
                    color: Kirigami.Theme.highlightColor
                }
            }

            PlasmaComponents.ToolButton {
                icon.name: "view-refresh"
                onClicked: root.refresh()
                enabled: !root.isLoading

                PlasmaComponents.ToolTip {
                    text: "Refresh now"
                }
            }

            PlasmaComponents.ToolButton {
                icon.name: "configure"
                onClicked: Plasmoid.internalAction("configure").trigger()

                PlasmaComponents.ToolTip {
                    text: "Configure"
                }
            }

            PlasmaComponents.ToolButton {
                icon.name: "window-pin"
                onClicked: root.pinned = !root.pinned
                checkable: true
                checked: root.pinned

                PlasmaComponents.ToolTip {
                    text: root.pinned ? "Unpin popup" : "Keep open"
                }
            }
        }
    }

    ColumnLayout {
        id: contentLayout
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Kirigami.Units.largeSpacing
        }
        spacing: Kirigami.Units.mediumSpacing

        // Error message
        PlasmaExtras.Heading {
            Layout.fillWidth: true
            level: 4
            text: root.errorMessage
            color: Kirigami.Theme.negativeTextColor
            wrapMode: Text.WordWrap
            visible: root.errorMessage !== ""
            horizontalAlignment: Text.AlignHCenter
        }

        // Loading indicator
        Rectangle {
            Layout.fillWidth: true
            height: 2
            color: Kirigami.Theme.highlightColor
            visible: root.isLoading
            opacity: 0.5
        }

        // Main usage bars (Session + Weekly)
        Repeater {
            model: usageModel

            UsageBar {
                Layout.fillWidth: true
                title: modelData.title
                percent: modelData.percent
                resetsAt: modelData.resetsAt
            }
        }

        // Separator before model breakdown
        Kirigami.Separator {
            Layout.fillWidth: true
            visible: root.sonnetPercent > 0 || root.opusPercent > 0
        }

        // Per-model breakdown table
        ModelBreakdownTable {
            Layout.fillWidth: true
            visible: root.sonnetPercent > 0 || root.opusPercent > 0
            sonnetPercent: root.sonnetPercent
            sonnetResetsAt: root.sonnetResetsAt
            opusPercent: root.opusPercent
            opusResetsAt: root.opusResetsAt
        }

        // Extra usage section (paid overage)
        ColumnLayout {
            Layout.fillWidth: true
            visible: root.hasExtra && Plasmoid.configuration.showExtraUsage
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Separator {
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents.Label {
                    text: "Extra Usage"
                    Layout.fillWidth: true
                    font.weight: Font.Medium
                }

                PlasmaComponents.Label {
                    text: "$" + root.extraUsed.toFixed(2) + " / $" + root.extraLimit.toFixed(2)
                    font: Kirigami.Theme.smallFont
                    opacity: 0.8
                }
            }
        }

        // Separator before chart
        Kirigami.Separator {
            Layout.fillWidth: true
            visible: Plasmoid.configuration.showRecentUsage
        }

        // Daily usage chart
        UsageBarChart {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 5
            visible: Plasmoid.configuration.showRecentUsage
        }

        // Last updated
        PlasmaComponents.Label {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.smallSpacing
            horizontalAlignment: Text.AlignHCenter
            text: root.lastUpdated ? "Updated: " + root.lastUpdated : "Not yet updated"
            opacity: 0.6
            font: Kirigami.Theme.smallFont
        }
    }
}
