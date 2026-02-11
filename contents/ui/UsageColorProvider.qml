import QtQuick
import org.kde.kirigami as Kirigami

QtObject {
    id: colorProvider

    readonly property int criticalThreshold: 90
    readonly property int warningThreshold: 75

    function getColorForPercent(percent) {
        if (percent >= criticalThreshold) return Kirigami.Theme.negativeTextColor
        if (percent >= warningThreshold)

    }
}
