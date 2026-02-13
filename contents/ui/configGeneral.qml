import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_refreshIntervalMinutes: refreshSpinBox.value
    property int cfg_refreshIntervalMinutesDefault: 1
    property alias cfg_showExtraUsage: showExtraUsageCheckBox.checked
    property bool cfg_showExtraUsageDefault: true
    property alias cfg_showRecentUsage: showRecentUsageCheckBox.checked
    property bool cfg_showRecentUsageDefault: false

    Kirigami.FormLayout {
        QQC2.SpinBox {
            id: refreshSpinBox
            Kirigami.FormData.label: i18nc("@label:spinbox", "Refresh interval (minutes):")
            from: 1
            to: 60
            stepSize: 1
        }

        QQC2.Label {
            text: i18ncp("@info", "Every %1 minute", "Every %1 minutes", refreshSpinBox.value)
            opacity: 0.7
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
