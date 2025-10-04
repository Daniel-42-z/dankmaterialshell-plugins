import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent{
    id: root
    
    // Expand tilde to home directory
    function expandPath(path) {
        if (path.startsWith("~/")) {
            return Quickshell.env("HOME") + path.substring(1);
        }
        return path;
    }
    
    property string wallpaperPath: expandPath(pluginData.wallpaperPath || "~/Pictures")
    property int shuffleInterval: (pluginData.shuffleInterval || 1800) * 1000
    property string scriptPath: Qt.resolvedUrl("shuffle-wallpapers").toString().replace("file://", "")

    Component.onCompleted: {
        console.log("=== Wallpaper Shuffler Plugin Started ===");
        console.log("Wallpaper Path:", root.wallpaperPath);
        console.log("Shuffle Interval:", root.shuffleInterval, "ms");
        console.log("Script Path:", root.scriptPath);
    }

    Process {
        id: shuffleProcess
        command: ["bash", root.scriptPath, root.wallpaperPath]
        running: false

        onRunningChanged: {
            console.log("Process running:", running);
            if (!running) {
                console.log("Wallpaper shuffled successfully");
            }
        }
        
        onExited: (exitCode, exitStatus) => {
            console.log("Process exited with code:", exitCode);
        }
    }

    Timer {
        interval: root.shuffleInterval
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            console.log("Timer triggered - starting shuffle process");
            shuffleProcess.running = true;
        }
    }
}
