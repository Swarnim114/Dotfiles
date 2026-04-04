import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI

Item {
    id: root
    property var pluginApi: null

    property string status: "Unknown"
    property bool isConnected: false
    property bool isConnecting: false
    property bool isDisconnecting: false
    property bool isLoading: false
    property string accountType: ""
    property string connectionMode: ""
    
    readonly property bool isBusy: isConnecting || isDisconnecting || status === "Connecting" || status === "Disconnecting"

    // Timer to delay the status check slightly after connecting/disconnecting
    // because the warp-cli daemon takes a brief moment to change state.
    Timer {
        id: postActionTimer
        interval: 1000
        running: false
        repeat: false
        onTriggered: {
            root.isConnecting = false
            root.isDisconnecting = false
            updateStatus()
        }
    }

    // Poll for status every 5 seconds
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!root.isBusy) {
                updateStatus()
            }
        }
    }

    // Status check process
    Process {
        id: statusProcess
        command: ["warp-cli", "status"]
        
        stdout: SplitParser {
            onRead: (line) => {
                parseStatusLine(line)
            }
        }
        
        onExited: (exitCode) => {
            root.isLoading = false
        }
    }

    // Connect process
    Process {
        id: connectProcess
        command: ["warp-cli", "connect"]
        
        onStarted: {
            root.isConnecting = true
            root.status = "Connecting"
        }
        
        onExited: (exitCode) => {
            postActionTimer.restart()
        }
    }

    // Disconnect process
    Process {
        id: disconnectProcess
        command: ["warp-cli", "disconnect"]
        
        onStarted: {
            root.isDisconnecting = true
            root.status = "Disconnecting"
        }
        
        onExited: (exitCode) => {
            postActionTimer.restart()
        }
    }

    function parseStatusLine(line) {
        const trimmed = line.trim()
        
        // Parse status line
        if (trimmed.startsWith("Status update:")) {
            const statusPart = trimmed.replace("Status update:", "").trim()
            root.status = statusPart
            root.isConnected = statusPart === "Connected"
        }
        
        // Parse account type
        if (trimmed.startsWith("Account type:")) {
            root.accountType = trimmed.replace("Account type:", "").trim()
        }
        
        // Parse connection mode
        if (trimmed.startsWith("Mode:")) {
            root.connectionMode = trimmed.replace("Mode:", "").trim()
        }
    }

    function updateStatus() {
        root.isLoading = true
        statusProcess.running = true
    }

    function connect() {
        if (root.isBusy || root.isConnected) return
        connectProcess.running = true
    }

    function disconnect() {
        if (root.isBusy || !root.isConnected) return
        disconnectProcess.running = true
    }

    function toggle() {
        if (root.isBusy) return
        
        if (root.isConnected) {
            disconnect()
        } else {
            connect()
        }
    }

    function tr(key, data) {
        if (!pluginApi)
            return key
        return pluginApi.tr(key, data)
    }

    Component.onCompleted: {
        Logger.i("WARPManager", "Plugin started")
        updateStatus()
    }
}
