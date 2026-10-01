import qs.components
import M3Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root
    implicitWidth: 250
    implicitHeight: 100
    anchors.top: true
    margins.top: 10
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Bottom
    exclusiveZone: 0

    property int artSize: 100
    property int artSourceSize: 200
    property int radiusSize: 18

    property MprisPlayer picked: null
    readonly property var players: Mpris.players.values
    readonly property MprisPlayer player: {
        const list = players;
        if (picked !== null) {
            for (let i = 0; i < list.length; i++) {
                if (list[i] === picked)
                    return picked;
            }
        }
        return list[0] ?? null;
    }
    readonly property bool isPlaying: player?.isPlaying ?? false

    Instantiator {
        model: root.players
        delegate: Connections {
            required property var modelData
            target: modelData

            Component.onCompleted: {
                if (modelData.isPlaying)
                    root.picked = modelData;
            }

            function onIsPlayingChanged() {
                if (modelData.isPlaying)
                    root.picked = modelData;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.bg
        radius: root.radiusSize

        RowLayout {
            anchors.fill: parent
            spacing: 10

            ClippingRectangle {
                Layout.preferredWidth: root.artSize
                Layout.fillHeight: true
                topLeftRadius: root.radiusSize
                bottomLeftRadius: root.radiusSize
                color: Colors.sf

                Image {
                    id: cover
                    anchors.fill: parent
                    source: root.player?.trackArtUrl || "../assets/Fujibayashi.jpg"
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize.width: root.artSourceSize
                    sourceSize.height: root.artSourceSize
                }

                MaterialShape {
                    id: loader
                    anchors.centerIn: parent
                    implicitSize: 40
                    color: Colors.bg
                    visible: cover.status === Image.Loading
                    shape: shapes[shapeIndex]
                    animationDuration: 650

                    property int shapeIndex: 0
                    property var shapes: [
                        MaterialShape.SoftBurst,
                        MaterialShape.Cookie9Sided,
                        MaterialShape.Pentagon,
                        MaterialShape.Pill,
                        MaterialShape.Sunny,
                        MaterialShape.Cookie4Sided,
                        MaterialShape.Oval,
                    ]

                    Timer {
                        interval: 650
                        repeat: true
                        running: cover.status === Image.Loading
                        onTriggered: loader.shapeIndex = (loader.shapeIndex + 1) % loader.shapes.length
                    }

                    SequentialAnimation on scale {
                        running: cover.status === Image.Loading
                        loops: Animation.Infinite

                        NumberAnimation {
                            from: 1
                            to: 1.14
                            duration: 325
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.5
                        }
                        NumberAnimation {
                            from: 1.14
                            to: 1
                            duration: 325
                            easing.type: Easing.InOutQuad
                        }
                    }

                    RotationAnimator on rotation {
                        from: 0
                        to: 360
                        duration: 4666
                        loops: Animation.Infinite
                        running: cover.status === Image.Loading
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onWheel: wheel => {
                        if (wheel.angleDelta.y > 0)
                            Quickshell.execDetached(["wpctl", "set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@", "5%+"]);
                        else
                            Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]);
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.rightMargin: 12
                Layout.topMargin: 8
                Layout.bottomMargin: 12

                StyledText {
                    Layout.fillWidth: true
                    text: root.player?.trackArtist || "Unknown Artist"
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.player?.trackTitle || "Unknown Title"
                    font.bold: true
                    elide: Text.ElideRight
                }

                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Btn {
                        enabled: root.player?.canGoPrevious ?? false

                        MaterialIcon {
                            text: "skip_previous"
                        }

                        ClickArea {
                            onClicked: root.player?.previous()
                        }
                    }

                    Btn {
                        implicitSize: 34
                        shape: MaterialShape.VerySunny
                        enabled: root.player?.canTogglePlaying ?? false

                        MaterialIcon {
                            text: root.isPlaying ? "pause" : "play_arrow"
                        }

                        ClickArea {
                            onClicked: root.player?.togglePlaying()
                        }
                    }

                    Btn {
                        enabled: root.player?.canGoNext ?? false

                        MaterialIcon {
                            text: "skip_next"
                        }

                        ClickArea {
                            onClicked: root.player?.next()
                        }
                    }
                }
            }
        }
    }

    component Btn: MaterialShape {
        implicitSize: 28
        shape: MaterialShape.Circle
        color: Colors.sf
        opacity: enabled ? 1 : 0.35

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutQuad
            }
        }
    }

    component ClickArea: MouseArea {
        anchors.fill: parent
        enabled: parent.enabled
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onPressed: parent.scale = 0.88
        onReleased: parent.scale = 1
        onCanceled: parent.scale = 1
    }
}