import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: colorProvider
    visible: false

    function getColorForPercent(percent) {
        if (percent >= Constants.usageCriticalThreshold) return Kirigami.Theme.negativeTextColor
        if (percent >= Constants.usageWarningThreshold) return Kirigami.Theme.neutralTextColor
        return Kirigami.Theme.positiveTextColor
    }
}
