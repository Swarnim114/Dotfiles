import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
Item {
    id: root
    property var pluginApi: null
    readonly property var mainInstance: pluginApi?.mainInstance
    property real contentPreferredWidth: 600
    property real contentPreferredHeight: 800
    anchors.fill: parent
    readonly property var geometryPlaceholder: root
    

        readonly property var c: ({
        background: "#1E1E1E",
        surface_container_low: "#252525",
        surface_container: "#2A2A2A",
        surface_container_highest: "#333333",
        outline_variant: "#444444",
        primary: "#8AB4F8",
        on_primary: "#1e1e1e",
        on_surface: "#FFFFFF",
        on_surface_variant: "#BBBBBB",
        surface_container_high: "#3A3A3A",
        surface_bright: "#404040",
        surface_dim: "#171717",
        error: "#FF5252",
        on_error: "#000000"
    })
    readonly property string fontBody: "Noto Sans"

    property int tabIndex: 0

    property int browseStack: 0
    property int libraryStack: 0

    property string selectedMangaId: ""

    Rectangle { anchors.fill: parent; color: c.background }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            height: 44
            color: c.surface_container_low
            z: 10

            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 1; color: c.outline_variant; opacity: 0.4
            }

            Row {
                anchors.fill: parent

                Repeater {
                    model: [
                        { label: "Browse",  icon: "⊞" },
                        { label: "Library", icon: "⊟" }
                    ]

                    delegate: Item {
                        width: root.width / 2
                        height: parent.height

                        readonly property bool active: root.tabIndex === index

                        Rectangle {
                            anchors.fill: parent
                            color: tabArea.containsMouse && !active
                                ? Qt.rgba(c.primary.r, c.primary.g, c.primary.b, 0.05)
                                : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.icon
                                font.pixelSize: 13
                                color: active ? c.primary : c.on_surface_variant
                                opacity: active ? 1 : 0.5
                                Behavior on color { ColorAnimation { duration: 180 } }
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.label
                                font.family: root.fontBody
                                font.pixelSize: 10
                                font.letterSpacing: 0.6
                                color: active ? c.primary : c.on_surface_variant
                                opacity: active ? 1 : 0.5
                                Behavior on color { ColorAnimation { duration: 180 } }
                            }
                        }

                        Rectangle {
                            anchors {
                                bottom: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                            }
                            width: active ? 28 : 0
                            height: 2; radius: 1
                            color: c.primary
                            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        }

                        MouseArea {
                            id: tabArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.tabIndex = index
                        }
                    }
                }
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.tabIndex

            Item {

                BrowseView {
        property var mainInstance: root.mainInstance
        property var c: root.c

                    anchors.fill: parent
                    visible: root.browseStack === 0
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                    onMangaSelected: function(mangaId) {
                        root.selectedMangaId = mangaId
                        root.browseStack = 1
                    }
                }

                DetailView {
        property var mainInstance: root.mainInstance
        property var c: root.c

                    id: browseDetail
                    anchors.fill: parent
                    visible: root.browseStack === 1
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                    onBackRequested:   { root.browseStack = 0 }
                    onChapterSelected: { root.browseStack = 2 }
                }

                ReaderView {
        property var mainInstance: root.mainInstance
        property var c: root.c

                    id: browseReader
                    anchors.fill: parent
                    visible: root.browseStack === 2
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                    onBackRequested: {
                        root.browseStack = 1
                        browseReader.reset()
                    }
                }
            }

            Item {
                LibraryView {
        property var mainInstance: root.mainInstance
        property var c: root.c

                    anchors.fill: parent
                    visible: root.libraryStack === 0
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                    onMangaSelected: function(mangaId) {
                        root.selectedMangaId = mangaId
                        root.libraryStack = 1
                    }
                }

                DetailView {
        property var mainInstance: root.mainInstance
        property var c: root.c

                    id: libraryDetail
                    anchors.fill: parent
                    visible: root.libraryStack === 1
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                    onBackRequested:   { root.libraryStack = 0 }
                    onChapterSelected: { root.libraryStack = 2 }
                }

                ReaderView {
        property var mainInstance: root.mainInstance
        property var c: root.c

                    id: libraryReader
                    anchors.fill: parent
                    visible: root.libraryStack === 2
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                    onBackRequested: {
                        root.libraryStack = 1
                        libraryReader.reset()
                    }
                }
            }
        }
    }
}
