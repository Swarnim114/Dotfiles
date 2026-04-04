import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

NIconButton {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0
    
    readonly property var pluginSettings: {
        return pluginApi && pluginApi.pluginSettings ? pluginApi.pluginSettings : {}
    }
    
    readonly property var main: {
        return pluginApi && pluginApi.mainInstance ? pluginApi.mainInstance : {}
    }
    
    readonly property var tr: {
        return pluginApi && pluginApi.tr ? pluginApi.tr : (key) => key
    }
    
    readonly property string screenName: screen && screen.name ? screen.name : ""
    readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
    readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
    
    readonly property string displayMode: root.pluginSettings.displayMode ?? "alwaysShow"
    readonly property string connectedColor: root.pluginSettings.connectedColor ?? "primary"
    readonly property string disconnectedColor: root.pluginSettings.disconnectedColor ?? "none"
    
    readonly property bool isConnected: root.main.isConnected ?? false
    readonly property bool isBusy: root.main.isBusy ?? false
    readonly property string status: root.main.status ?? "Unknown"

    icon: root.isBusy ? "reload" : root.isConnected ? "cloud-lock" : "cloud-off"
    
    readonly property bool isPanelOpen: pluginApi && pluginApi.panelOpenScreen === screen
    tooltipText: isPanelOpen ? "" : "WARP: " + root.status
    
    tooltipDirection: BarService.getTooltipDirection(screen?.name)
    baseSize: Style.getCapsuleHeightForScreen(screen?.name)
    applyUiScale: false
    customRadius: Style.radiusL

    colorBg: Style.capsuleColor
    colorFg: root.isConnected ? Color.resolveColorKeyOptional(root.connectedColor) || Color.mPrimary : Color.mOnSurface
    colorBgHover: Color.mHover
    colorFgHover: Color.mOnHover
    colorBorder: "transparent"
    colorBorderHover: "transparent"

    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    Component.onCompleted: {
        Logger.i("WARPManager", "Bar widget loaded")
    }

    NPopupContextMenu {
        id: contextMenu

        model: [{
            "label": "Connect",
            "action": "connect",
            "icon": "plug-connected",
            "enabled": !root.isConnected && !root.isBusy
        }, {
            "label": "Disconnect",
            "action": "disconnect",
            "icon": "plug-connected-x",
            "enabled": root.isConnected && !root.isBusy
        }, {
            "label": "Refresh Status",
            "action": "refresh",
            "icon": "refresh"
        }]
        
        onTriggered: (action) => {
            contextMenu.close()
            PanelService.closeContextMenu(screen)
            
            if (action === "connect")
                root.main.connect()
            else if (action === "disconnect")
                root.main.disconnect()
            else if (action === "refresh")
                root.main.updateStatus()
        }
    }

    onClicked: {
        if (pluginApi && pluginApi.openPanel) {
            pluginApi.openPanel(screen, root)
        }
    }
    
    onRightClicked: {
        PanelService.showContextMenu(contextMenu, root, screen)
    }
}
