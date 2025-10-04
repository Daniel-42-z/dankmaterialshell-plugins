import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property string powerUsage: "..."
    property int refreshInterval: pluginData.refreshInterval || 5000
    property string scriptPath: Qt.resolvedUrl("power-usage.sh").toString().replace("file://", "")

    Process {
        id: powerProcess
        command: ["sh", root.scriptPath]
        running: false

        stdout: SplitParser {
            onRead: data => {
                root.powerUsage = data.trim()
            }
        }

        onRunningChanged: {
            if (!running) {
                console.log("Power usage updated:", root.powerUsage)
            }
        }
    }

    Timer {
        interval: root.refreshInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            powerProcess.running = true
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            StyledText {
                text: "󰠠 "
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.powerUsage
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            StyledText {
                text: "󰠠 "
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.powerUsage
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
