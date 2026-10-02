import qs.components
import Quickshell.Widgets
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root
    anchors {
        top: true
        left: true
    }
    margins {
        top: 10
        left: 10
    }
    implicitWidth: 200
    implicitHeight: 120
    WlrLayershell.layer: WlrLayer.Bottom
    exclusiveZone: 0
    color: "transparent"

    readonly property string hostname: hostnameFile.text().trim()
    property string uptimeText: "..."

    property int wsCount: 9
    readonly property var activeWindow: ToplevelManager.activeToplevel
    readonly property string desktopName: "Desktop"
    readonly property string appIcon: root.activeWindow?.appId ? DesktopEntries.heuristicLookup(root.activeWindow.appId)?.icon ?? "" : ""

    FileView {
        id: hostnameFile
        path: "/etc/hostname"
    }

    Process {
        id: uptimeProc
        command: ["cat", "/proc/uptime"]
        stdout: StdioCollector {
            onStreamFinished: {
                const totalSeconds = parseFloat(text.trim().split(/\s+/)[0])
                if (!isNaN(totalSeconds)) {
                    const h = Math.floor(totalSeconds / 3600)
                    const m = Math.floor((totalSeconds % 3600) / 60)
                    root.uptimeText = "up • " + h + "h " + m + "m"
                }
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!uptimeProc.running) uptimeProc.running = true
    }

    function focusWorkspace(id) {
        if (id < 1 || id > wsCount)
            return
        if (Hyprland.usingLua)
            Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })")
        else
            Hyprland.dispatch("workspace " + id)
    }

    function changeWorkspace(direction) {
        const current = Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1

        let next = current + direction
        
        if (next > wsCount)
            next = 1;
        else if (next < 1)
            next = wsCount

        focusWorkspace(next)
    }

    Rectangle {
        anchors.fill: parent
        radius: 40
        color: Colors.bg

        ClippingRectangle {
            id: c
            width: 85
            height: 85
            anchors {
                left: parent.left
                top: parent.top
                leftMargin: 12
                topMargin: 12
            }
            radius: 30
            color: Colors.sf

            Image {
                anchors.fill: parent
                source: "../assets/Fujibayashi.jpg"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize: Qt.size(180, 180)
            }
        }
        
        IconImage {
            anchors {
                bottom: c.bottom
                right: c.right
                rightMargin: -5
            }
            implicitSize: 22
            source: root.appIcon ? Quickshell.iconPath(root.appIcon, true) : ""
        }

        Column {
            anchors {
                right: parent.right
                top: parent.top
                rightMargin: 20
                topMargin: 20
            }

            StyledText {
                text: Quickshell.env("USER") + "@" + root.hostname
                font.pixelSize: 14
            }

            StyledText {
                text: root.uptimeText
                font.pixelSize: 12
                opacity: 0.7
            }
        }

        Rectangle {
            anchors {
                bottom: parent.bottom
                right: parent.right
                rightMargin: 20
                bottomMargin: 10
            }
            width: 60
            height: 30
            radius: 20
            color: Colors.sf

            StyledText {
                anchors.centerIn: parent
                text: "ws " + Hyprland.focusedMonitor?.activeWorkspace?.id ?? ""
                font.pixelSize: 12
                font.features: ({
                        "tnum": 1
                    })
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.NoButton
                onWheel: wheel => {
                    if (wheel.angleDelta.y > 0)
                        root.changeWorkspace(1)
                    else if (wheel.angleDelta.y < 0)
                        root.changeWorkspace(-1)
                    wheel.accepted = true
                }
            }
        }
    }
}