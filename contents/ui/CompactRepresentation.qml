import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    id: compactRoot

    Layout.minimumWidth: Kirigami.Units.iconSizes.small
    Layout.minimumHeight: Kirigami.Units.iconSizes.small
    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
    Layout.preferredHeight: Kirigami.Units.iconSizes.medium

    // Shared utilities
    UsageColorProvider {
        id: colorProvider
    }
    Constants {
        id: constants
    }

    // Show session usage, fall back to weekly if session is 0
    property real percent: root.sessionPercent > 0 ? root.sessionPercent : root.weeklyPercent
    property color usageColor: colorProvider.getColorForPercent(percent)

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
        hoverEnabled: true

        // Donut chart visualization
        Canvas {
            id: canvas
            anchors.fill: parent
            anchors.margins: constants.donutCanvasMargin

            onPaint: {
                var ctx = getContext("2d")
                var centerX = width / 2
                var centerY = height / 2
                var radius = Math.min(width, height) / 2 - constants.donutCanvasMargin
                var innerRadius = radius * constants.donutInnerRadiusRatio

                ctx.reset()

                // Background circle
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                ctx.fillStyle = Kirigami.Theme.backgroundColor
                ctx.fill()

                // Usage arc
                if (percent > 0) {
                    ctx.beginPath()
                    var startAngle = -Math.PI / 2
                    var endAngle = startAngle + (percent / 100) * 2 * Math.PI
                    ctx.moveTo(centerX, centerY)
                    ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                    ctx.closePath()
                    ctx.fillStyle = usageColor
                    ctx.fill()
                }

                // Inner circle (donut hole)
                ctx.beginPath()
                ctx.arc(centerX, centerY, innerRadius, 0, 2 * Math.PI)
                ctx.fillStyle = Kirigami.Theme.backgroundColor
                ctx.fill()
            }

            Connections {
                target: root

                function onSessionPercentChanged() {
                    canvas.requestPaint()
                }

                function onWeeklyPercentChanged() {
                    canvas.requestPaint()
                }
            }

            Connections {
                target: Kirigami.Theme

                function onHighlightColorChanged() {
                    canvas.requestPaint()
                }

                function onBackgroundColorChanged() {
                    canvas.requestPaint()
                }

                function onNegativeTextColorChanged() {
                    canvas.requestPaint()
                }

                function onNeutralTextColorChanged() {
                    canvas.requestPaint()
                }
            }

            Component.onCompleted: requestPaint()
        }

        // Percentage text in center
        Text {
            anchors.centerIn: parent
            text: root.isLoading ? "..." : (percent < 100 ? Math.round(percent) : "!")
            color: Kirigami.Theme.textColor
            font.pixelSize: parent.height * constants.donutTextSizeRatio
            font.bold: true
            renderType: Text.NativeRendering
        }

        // Loading indicator
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Kirigami.Theme.highlightColor
            border.width: 1
            radius: width / 2
            visible: root.isLoading
            opacity: 0.5

            SequentialAnimation on opacity {
                running: root.isLoading
                loops: Animation.Infinite
                NumberAnimation {
                    to: 0.2; duration: constants.loadingAnimationDuration
                }
                NumberAnimation {
                    to: 0.8; duration: constants.loadingAnimationDuration
                }
            }
        }
    }
}
