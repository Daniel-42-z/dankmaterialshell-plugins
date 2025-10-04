import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "powerUsagePlugin"

    StyledText {
        width: parent.width
        text: "Power Usage Monitor Settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Configure how often the power usage is refreshed and displayed."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    SliderSetting {
        settingKey: "refreshInterval"
        label: "Refresh Interval"
        description: "How often to update power usage (in seconds)"
        defaultValue: 5000
        minimum: 1000
        maximum: 30000
        unit: "ms"
        leftIcon: "schedule"
    }

    StyledText {
        width: parent.width
        text: "💡 Tip: The script at ~/.local/bin/power-usage-basic.sh must be executable and return power usage in the format '4.2W'"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }
}
