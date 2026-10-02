import qs.components
import M3Shapes
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    anchors {
        top: true
        right: true
    }
    margins {
        top: 10
        right: 10
    }
    color: "transparent"
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    property int cpuUsage: 0
    property int memUsage: 0
    property int diskUsage: 0
    property real lastTotal: 0
    property real lastIdle: 0

    Process {
        id: cpuProc
        command: ["head", "-1", "/proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = this.text.trim().split(/\s+/).slice(1, 8).map(Number)
                const total = t.reduce((a, b) => a + b, 0)
                const idle = t[3] + t[4]
                const dTotal = total - lastTotal
                if (lastTotal > 0 && dTotal > 0)
                    cpuUsage = Math.round(100 * (dTotal - (idle - lastIdle)) / dTotal)
                lastTotal = total
                lastIdle = idle
            }
        }
    }

    Process {
        id: memProc
        command: ["free"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [, total, used] = this.text.split("\n")[1].trim().split(/\s+/)
                memUsage = Math.round(100 * used / total)
            }
        }
    }

    Process {
        id: diskProc
        command: ["df", "--output=pcent", "/"]
        stdout: StdioCollector {
            onStreamFinished: diskUsage = parseInt(this.text.split("\n")[1]) || 0
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
            diskProc.running = true
        }
    }

    ColumnLayout {
        id: layout

        Repeater {
            model: [
                {
                    label: "Cpu",
                    icon: "earthquake",
                    badge: MaterialShape.Pentagon
                },
                {
                    label: "Mem",
                    icon: "memory",
                    badge: MaterialShape.Cookie4Sided
                },
                {
                    label: "Disk",
                    icon: "hard_drive",
                    badge: MaterialShape.Sunny
                }
            ]

            MaterialShape {
                required property var modelData
                required property int index

                implicitSize: 90
                shape: MaterialShape.Square
                color: Colors.bg

                ColumnLayout {
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        margins: 10
                    }
                    spacing: -4

                    StyledText {
                        text: [root.cpuUsage, root.memUsage, root.diskUsage][index] + "%"
                        font.bold: true
                    }
                    StyledText {
                        text: modelData.label
                        font.pixelSize: 12
                    }
                }

                MaterialShape {
                    anchors {
                        top: parent.top
                        right: parent.right
                        margins: 8
                    }
                    implicitSize: 30
                    shape: modelData.badge
                    color: Colors.sf

                    MaterialIcon {
                        text: modelData.icon
                    }
                }
            }
        }
    }
}