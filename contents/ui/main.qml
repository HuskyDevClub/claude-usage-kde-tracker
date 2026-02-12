import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as PlasmaSupport
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // Usage data properties
    property real sessionUsed: 0
    property real weeklyUsed: 0
    property real sonnetUsed: 0
    property real opusUsed: 0
    property string sessionResetsAt: ""
    property string weeklyResetsAt: ""
    property string sonnetResetsAt: ""
    property string opusResetsAt: ""
    property string subscriptionType: ""
    property string lastUpdated: ""
    property string errorMessage: ""
    property bool isLoading: false
    property bool pinned: false

    // Extra usage (paid overage)
    property real extraUsed: 0
    property real extraLimit: 0
    property real extraUtilization: 0
    property bool hasExtra: false

    // Daily usage history for chart
    property var dailyHistory: []

    hideOnWindowDeactivate: !pinned

    // Cache control
    property var lastFetchTime: null
    property int cacheMinutes: Math.max(1, Plasmoid.configuration.refreshInterval / 60)

    // Computed percentages
    property real sessionPercent: sessionUsed
    property real weeklyPercent: weeklyUsed
    property real sonnetPercent: sonnetUsed
    property real opusPercent: opusUsed
    property real maxPercent: Math.max(sessionPercent, weeklyPercent, sonnetPercent, opusPercent)

    switchWidth: Kirigami.Units.gridUnit * 14
    switchHeight: Kirigami.Units.gridUnit * 12

    toolTipMainText: "Claude Usage Tracker"
    toolTipSubText: errorMessage !== "" ? errorMessage :
        "Session: " + sessionPercent.toFixed(1) + "% | Weekly: " + weeklyPercent.toFixed(1) + "%"

    compactRepresentation: CompactRepresentation {
    }
    fullRepresentation: FullRepresentation {
    }

    // Watch for expanded state changes
    Connections {
        target: root

        function onExpandedChanged() {
            if (root.expanded && isCacheStale()) {
                fetchUsage()
            }
        }
    }

    // Check if cache is stale
    function isCacheStale() {
        if (!lastFetchTime) return true
        var now = new Date()
        var diffMinutes = (now - lastFetchTime) / (1000 * 60)
        return diffMinutes >= cacheMinutes
    }

    // Helper function to handle command output
    function handleCommandOutput(data, onSuccess, onError) {
        var stdout = data["stdout"] || ""
        var stderr = data["stderr"] || ""
        var exitCode = data["exit code"] || 0

        if (exitCode === 0 && stdout) {
            try {
                var result = JSON.parse(stdout)
                onSuccess(result)
            } catch (e) {
                if (onError) onError("Parse error")
            }
        } else if (stderr && onError) {
            var truncatedError = stderr.length > Constants.errorMessageMaxLength
                ? stderr.substring(0, Constants.errorMessageMaxLength - 3) + "..."
                : stderr
            onError(truncatedError)
        } else if (onError) {
            onError("Fetch failed")
        }
    }

    // DataSource for running the fetch script
    PlasmaSupport.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: function (source, data) {
            disconnectSource(source)
            isLoading = false

            handleCommandOutput(data,
                    function (result) {
                    parseUsageData(result)
                    lastFetchTime = new Date()
                    lastUpdated = lastFetchTime.toLocaleTimeString(Qt.locale(), "HH:mm:ss")
                },
                    function (error) {
                    errorMessage = error
                }
            )
        }

        function exec(cmd) {
            connectSource(cmd)
        }
    }

    // DataSource for loading cached data at startup
    PlasmaSupport.DataSource {
        id: cacheLoader
        engine: "executable"
        connectedSources: []

        onNewData: function (source, data) {
            disconnectSource(source)

            handleCommandOutput(data,
                    function (result) {
                    parseUsageData(result)
                    lastUpdated = "cached"
                },
                null  // Silently ignore cache errors
            )
        }

        function loadCache() {
            connectSource("cat \"$HOME/.local/share/claude-usage-tracker/usage.json\" 2>/dev/null")
        }
    }

    // Fetch usage via Python script
    function fetchUsage() {
        if (isLoading) return

        isLoading = true
        errorMessage = ""

        var scriptPath = Qt.resolvedUrl("../code/fetch_usage.py").toString().replace(/^file:\/\//, "")
        executable.exec("python3 \"" + scriptPath + "\"")
    }

    // Parse API response with validation
    function parseUsageData(data) {
        if (!data || typeof data !== "object") {
            errorMessage = "Invalid response format"
            return
        }

        if (data.error) {
            errorMessage = data.error
            return
        }

        // Session (5h window)
        if (data.session && typeof data.session === "object") {
            sessionUsed = data.session.used || 0
            sessionResetsAt = data.session.resetsAt || ""
        }

        // Weekly
        if (data.weekly && typeof data.weekly === "object") {
            weeklyUsed = data.weekly.used || 0
            weeklyResetsAt = data.weekly.resetsAt || ""
        }

        // Sonnet
        if (data.sonnet && typeof data.sonnet === "object") {
            sonnetUsed = data.sonnet.used || 0
            sonnetResetsAt = data.sonnet.resetsAt || ""
        }

        // Opus
        if (data.opus && typeof data.opus === "object") {
            opusUsed = data.opus.used || 0
            opusResetsAt = data.opus.resetsAt || ""
        }

        // Extra usage
        if (data.extra && typeof data.extra === "object") {
            extraUsed = data.extra.used || 0
            extraLimit = data.extra.limit || 0
            extraUtilization = data.extra.utilization || 0
            hasExtra = true
        } else {
            hasExtra = false
        }

        // Subscription type
        if (data.subscriptionType) {
            subscriptionType = data.subscriptionType
        }

        // Daily history
        if (data.dailyHistory && Array.isArray(data.dailyHistory)) {
            dailyHistory = data.dailyHistory
        }

        errorMessage = ""
    }

    // Manual refresh (force fetch)
    function refresh() {
        lastFetchTime = null
        fetchUsage()
    }

    // Global tick counter for reset time updates (shared by UsageBar and ModelBreakdownTable)
    property int resetTimeTick: 0
    Timer {
        interval: 30000
        running: sessionResetsAt !== "" || weeklyResetsAt !== "" || sonnetResetsAt !== "" || opusResetsAt !== ""
        repeat: true
        onTriggered: root.resetTimeTick++
    }

    // Auto-refresh timer (configurable, 0 = disabled)
    Timer {
        id: refreshTimer
        interval: Math.max(60000, Plasmoid.configuration.autoRefreshMinutes * 60 * 1000)
        running: Plasmoid.configuration.autoRefreshMinutes > 0
        repeat: true
        onTriggered: fetchUsage()
    }

    // Initial load: first show cached data, then fetch fresh data
    Component.onCompleted: {
        cacheLoader.loadCache()
        fetchUsage()
    }
}
