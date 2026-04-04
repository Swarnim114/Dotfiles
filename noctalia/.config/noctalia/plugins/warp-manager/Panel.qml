import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

Item {
    id: root

    property var pluginApi: null
    property var screen: null
    readonly property var mainInstance: pluginApi?.mainInstance

    readonly property bool isConnected: mainInstance?.isConnected || false
    readonly property bool isBusy: mainInstance?.isBusy || false
    readonly property string status: mainInstance?.status || "Unknown"

    property real contentPreferredWidth: 350
    property real contentPreferredHeight: 300

    readonly property var geometryPlaceholder: bg
    readonly property bool allowAttach: true

    Rectangle {
        id: bg
        anchors.fill: parent
        color: Color.mSurface // Adapt to Noctalia theme
        radius: Style.radiusL

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            Item { Layout.fillHeight: true } // Spacer

            // Main WARP Text
            NText {
                text: "WARP"
                color: isConnected ? Color.mPrimary : Color.mOnSurfaceVariant // Uses Noctalia theme
                font.pixelSize: 64
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Item { Layout.preferredHeight: 20 }

            // The Switch
            Rectangle {
                id: toggleContainer
                Layout.alignment: Qt.AlignHCenter
                width: 90
                height: 48
                radius: height / 2
                color: isConnected ? Color.mPrimary : Color.mSurfaceVariant
                opacity: isBusy ? 0.6 : 1.0

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                Rectangle {
                    id: toggleThumb
                    width: 40
                    height: 40
                    radius: width / 2
                    color: isConnected ? Color.mOnPrimary : Color.mOnSurface
                    anchors.verticalCenter: parent.verticalCenter
                    x: isConnected ? parent.width - width - 4 : 4

                    Behavior on x {
                        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (mainInstance && !isBusy) {
                            mainInstance.toggle()
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: 30 }

            // Status Text
            NText {
                text: isBusy ? (mainInstance.isConnecting ? "Connecting" : "Disconnecting") : (isConnected ? "Connected" : "Disconnected")
                font.pixelSize: 20
                font.bold: true
                color: Color.mOnSurface
                Layout.alignment: Qt.AlignHCenter
            }

            Item { Layout.fillHeight: true } // Spacer
        }
    }
}