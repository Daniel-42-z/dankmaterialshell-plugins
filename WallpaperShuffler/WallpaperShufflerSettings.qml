import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "wallpaperShufflerPlugin"

    StyledText {
        width: parent.width
        text: "Shuffle Wallpapers"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StringSetting {
        settingKey: "wallpaperPath"
        label: "Wallpaper Path"
        description: "Path to the wallpapers that will be shuffle-played (will be searched recursively)"
        defaultValue: "~/Pictures"
        placeholder: "/path/to/your/wallpapers/directory"
    }

	StringSetting {
		settingKey: "shuffleInterval"
		label: "Shuffle Interval"
		description: "The time in seconds between each shuffle"
		defaultValue: "1800"
	}
}
