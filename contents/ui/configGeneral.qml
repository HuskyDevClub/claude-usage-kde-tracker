import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_refreshInterval: refreshSpinBox.value
    property int cfg_refreshIntervalDefault: 60
    property alias cfg_autoRefreshMinutes: autoRefreshSpinBox.value
    property int cfg_autoRefreshMinutesDefault: 10
    property alias cfg_showExtraUsage: showExtraUsageCheckBox.checked
    property bool cfg_showExtraUsageDefault: false
    property alias cfg_showRecentUsage: showRecentUsageCheckBox.checked
    property bool cfg_showRecentUsageDefault: false

    Kirigami.FormLayout {
        QQC2.SpinBox {
            id: refreshSpinBox
            Kirigami.FormData.label: i18nc("@label:spinbox", "Cache duration (seconds):")
            30
            to: 600
            stepSize: 30
        }

        QQC2.Label {
            text: {
                var seconds = refreshSpinBox.value
                if (seconds < 60) {
                    return i18ncp("@info", "%1 second", "%1 seconds", seconds)
                } else {
                    var minutes = Math.floor(seconds / 60)
                    var remainder = seconds % 60
                    if (remainder === 0) {
                        return i18ncp("@info", "%1 minute", "%1 minutes", minutes)
                    }
                    return i18ncp("@info", "%1 minute", "%1 minutes", minutes) + " " +
                        i18ncp("@info", "%1 second", "%1 seconds", remainder)
                }
            }
            opacity: 0.7
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
        }

        QQC2.SpinBox {
            id: autoRefreshSpinBox
            Kirigami.FormData.label: i18nc("@label:spinbox", "Auto-refresh (minutes, 0 = off):")
            0
            to: 60
            stepSize: 1
        }

        QQC2.Label {
            text: autoRefreshSpinBox.value === 0
                ? i18nc("@info", "Disabled")
                : i18ncp("@info", "Every %1 minute", "Every %1 minutes", autoRefreshSpinBox.value)
            opacity: 0.7
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18nc("@title", "Display")
        }

        QQC2.CheckBox {
            id: showExtraUsageCheckBox
            Kirigami.FormData.label: i18nc("@label:checkbox", "Show extra usage:")
            text: i18nc("@option:check", "Show paid overage section")
        }

        QQC2.CheckBox {
            id: showRecentUsageCheckBox
            Kirigami.FormData.label: i18nc("@label:checkbox", "Show recent usage:")
            text: i18nc("@option:check", "Show daily usage chart")
        }
    }
}
