import qs.components
import M3Shapes
import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root
    implicitWidth: 160
    implicitHeight: 160
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Bottom
    exclusiveZone: 0

    property int clockSize: 150
    property int dateSize: 35
    property int dateTextSize: 14
    property int clockTextSize: 50

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Item {
        anchors.fill: parent

        MaterialShape {
            id: s
            anchors.centerIn: parent
            implicitSize: root.clockSize
            shape: MaterialShape.Cookie4Sided
            color: Colors.bg

            property bool spinning: true

            RotationAnimator on rotation {
                from: 0
                to: 360
                duration: 12000
                loops: Animation.Infinite
                paused: !s.spinning
            }

            MouseArea {
                anchors.fill: parent
                onClicked: s.spinning = !s.spinning
            }
        }

        MaterialShape {
            anchors {
                left: parent.left
                leftMargin: 10
                top: parent.top
                topMargin: 20
            }
            implicitSize: root.dateSize
            shape: MaterialShape.Pentagon
            color: Colors.sf

            StyledText {
                anchors.centerIn: parent
                text: Qt.formatDateTime(clock.date, "dd")
                font.pixelSize: root.dateTextSize
                font.bold: true
                rightPadding: 2
            }
        }

        MaterialShape {
            anchors {
                right: parent.right
                rightMargin: 10
                bottom: parent.bottom
                bottomMargin: 20
            }
            implicitSize: root.dateSize
            shape: MaterialShape.Pill
            color: Colors.sf

            StyledText {
                anchors.centerIn: parent
                text: Qt.formatDateTime(clock.date, "ddd")
                font.pixelSize: root.dateTextSize
                font.bold: true
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: -20

            StyledText {
                text: Qt.formatDateTime(clock.date, "hh")
                font.pixelSize: root.clockTextSize
                font.bold: true
            }
            StyledText {
                text: Qt.formatDateTime(clock.date, "mm")
                font.pixelSize: root.clockTextSize
                font.bold: true
            }
        }
    }
}