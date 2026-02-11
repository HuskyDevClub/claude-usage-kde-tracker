import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: modelTable

    property real sonnetPercent: 0
    property string sonnetResetsAt: ""
    property real opusPercent: 0
    property string opusResetsAt: ""

    UsageColorProvider {
        id: colorProvider
    }
    TimeFormatter {
        id: timeFormatter
    }

    spacing: Kirigami.Units.smallSpacing

    PlasmaComponents.Label {
        text: "Per-Model Usage"
        font.weight: Font.Medium
        Layout.fillWidth: true
    }

    // Header row
    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents.Label {
            text: "Model"
            Layout.fillWidth: true
            font: Kirigami.Theme.smallFont
            opacity: 0.6
        }

        PlasmaComponents.Label {
            text: "Utilization"
            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
            horizontalAlignment: Text.AlignRight
            font: Kirigami.Theme.smallFont
            opacity: 0.6
        }
    }

    // Sonnet row
    ColumnLayout {
        Layout.fillWidth: true
        visible: sonnetPercent > 0
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Label {
                text: "Sonnet"
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                text: sonnetPercent.toFixed(1) + "%"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                horizontalAlignment: Text.AlignRight
                color: colorProvider.getColorForPercent(sonnetPercent)
                font.bold: true
            }
        }

        // Mini progress bar
        Rectangle {
            Layout.fillWidth: true
            height: 3
            radius: height / 2
            color: Qt.alpha(Kirigami.Theme.textColor, 0.1)

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: parent.width * Math.min(sonnetPercent, 100) / 100
                radius: parent.radius
                color: colorProvider.getColorForPercent(sonnetPercent)

                Behavior on width {
                    NumberAnimation {
                        duration: 300; easing.type: Easing.OutQuad
                    }
                }
            }
        }

        PlasmaComponents.Label {
            visible: sonnetResetsAt !== ""
            text: timeFormatter.formatResetTime(sonnetResetsAt)
            font: Kirigami.Theme.smallFont
            opacity: 0.5
        }
    }

    // Opus row
    ColumnLayout {
        Layout.fillWidth: true
        visible: opusPercent > 0
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Label {
                text: "Opus"
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                text: opusPercent.toFixed(1) + "%"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                horizontalAlignment: Text.AlignRight
                color: colorProvider.getColorForPercent(opusPercent)
                font.bold: true
            }
        }

        // Mini progress bar
        Rectangle {
            Layout.fillWidth: true
            height: 3
            radius: height / 2
            color: Qt.alpha(Kirigami.Theme.textColor, 0.1)

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: parent.width * Math.min(opusPercent, 100) / 100
                radius: parent.radius
                color: colorProvider.getColorForPercent(opusPercent)

                Behavior on width {
                    NumberAnimation {
                        duration: 300; easing.type: Easing.OutQuad
                    }
                }
            }
        }

        PlasmaComponents.Label {
            visible: opusResetsAt !== ""
            text: timeFormatter.formatResetTime(opusResetsAt)
            font: Kirigami.Theme.smallFont
            opacity: 0.5
        }
    }

    // Empty state
    PlasmaComponents.Label {
        visible: sonnetPercent <= 0 && opusPercent <= 0
        text: "No per-model data available"
        font: Kirigami.Theme.smallFont
        opacity: 0.5
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
    }
}
