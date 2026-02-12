import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: colorProvider
    visible: false

    property int criticalThreshold: 90
    property int warningThreshold: 75

    function getColorForPercent(percent) {
        if (percent >= criticalThreshold) return Kirigami.Theme.negativeTextColor
        if (percent >= warningThreshold) return Kirigami.Theme.neutralTextColor
        return Kirigami.Theme.positiveTextColor
    }
}
