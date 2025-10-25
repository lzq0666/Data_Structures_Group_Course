import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs
import StateManager 1.0

Item {
    // 定义信号，用于与父组件通信
    signal backToAdminMenuRequested()  // TODO: 连接到返回上一级的逻辑
    signal importDataRequested(string filePath)  // TODO: 连接到后端 C++ 数据导入函数

    // 属性
    property string selectedFilePath: ""
    property string statusMessage: ""
    property bool showStatus: false
    property bool isSuccess: false

    // 显示导入状态的函数（由 C++ 调用）
    function showImportStatus(success, message) {
        isSuccess = success
        statusMessage = message
        showStatus = true

        // 5秒后自动隐藏消息
        statusTimer.restart()
    }

    function clearStatus() {
        statusMessage = ""
        showStatus = false
    }

    Timer {
        id: statusTimer
        interval: 5000
        onTriggered: {
            clearStatus()
        }
    }

    // 文件选择对话框
    FileDialog {
        id: fileDialog
        title: qsTr("选择要导入的数据文件")
        nameFilters: ["JSON files (*.json)", "All files (*)"]
        onAccepted: {
            // 获取选中的文件路径
            selectedFilePath = fileDialog.selectedFile.toString()
            // 移除 file:/// 前缀（Windows 系统）
            if (selectedFilePath.startsWith("file:///")) {
                selectedFilePath = selectedFilePath.substring(8)
            } else if (selectedFilePath.startsWith("file://")) {
                selectedFilePath = selectedFilePath.substring(7)
            }
            console.log("选中文件:", selectedFilePath)
            clearStatus()
        }
        onRejected: {
            console.log("取消选择文件")
        }
    }

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                color: "#4158d0"
                position: 0.0
            }
            GradientStop {
                color: "#c850c0"
                position: 1.0
            }
        }

        // 主容器 Rectangle
        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.9, 700)
            height: Math.min(parent.height * 0.9, 600)
            radius: 20
            color: "white"
            opacity: 0.98
            border.color: "#e0e0e0"
            border.width: 1

            // 使用 ScrollView 来处理内容溢出
            ScrollView {
                anchors.fill: parent
                anchors.margins: 40
                contentWidth: width
                contentHeight: contentColumn.implicitHeight
                clip: true

                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                Column {
                    id: contentColumn
                    width: parent.width
                    spacing: 30

                    // 顶部区域：标题和返回按钮
                    Item {
                        width: parent.width
                        height: 60

                        // 返回按钮
                        Rectangle {
                            id: backButton
                            width: 100
                            height: 40
                            radius: 8
                            color: backArea.containsMouse ? "#3498db" : "#95a5a6"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left

                            Row {
                                anchors.centerIn: parent
                                spacing: 5

                                Text {
                                    text: "←"
                                    color: "white"
                                    font.pixelSize: 16
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: qsTr("返回")
                                    color: "white"
                                    font.pixelSize: 12
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: backArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // TODO: 实现返回上一级的逻辑
                                    clearStatus()
                                    selectedFilePath = ""
                                    backRequested()
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }

                        // 标题
                        Text {
                            text: qsTr("数据导入")
                            color: "#2c3e50"
                            font.pixelSize: 28
                            font.bold: true
                            anchors.centerIn: parent
                        }
                    }

                    // 主内容区域
                    Column {
                        width: parent.width
                        spacing: 25

                        // 说明文本
                        Column {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10
                            width: parent.width * 0.9

                            Text {
                                text: qsTr("导入系统数据")
                                color: "#2c3e50"
                                font.pixelSize: 20
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: qsTr("选择 JSON 格式的数据文件进行导入")
                                color: "#7f8c8d"
                                font.pixelSize: 14
                                anchors.horizontalCenter: parent.horizontalCenter
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        // 文件选择区域
                        Column {
                            width: Math.min(parent.width * 0.85, 500)
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 15

                            Text {
                                text: qsTr("选择文件")
                                color: "#34495e"
                                font.pixelSize: 16
                                font.bold: true
                            }

                            // 文件选择按钮和路径显示
                            Rectangle {
                                width: parent.width
                                height: 120
                                radius: 12
                                color: "#f8f9fa"
                                border.color: selectFileArea.containsMouse ? "#3498db" : "#ecf0f1"
                                border.width: 2

                                Behavior on border
                                .
                                color {
                                    ColorAnimation {
                                        duration: 200
                                    }
                                }

                                Column {
                                    anchors.centerIn: parent
                                    width: parent.width - 40
                                    spacing: 10

                                    // 文件图标和提示
                                    Item {
                                        width: parent.width
                                        height: 50

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 5

                                            Text {
                                                text: "📁"
                                                font.pixelSize: 32
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: selectedFilePath === "" ? qsTr("点击选择文件") : qsTr("已选择文件")
                                                color: "#7f8c8d"
                                                font.pixelSize: 14
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }

                                    // 显示选中的文件路径
                                    Rectangle {
                                        width: parent.width
                                        height: 40
                                        radius: 8
                                        color: "white"
                                        border.color: "#e0e0e0"
                                        border.width: 1
                                        visible: selectedFilePath !== ""

                                        Text {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            text: selectedFilePath
                                            color: "#2c3e50"
                                            font.pixelSize: 12
                                            elide: Text.ElideMiddle
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }

                                MouseArea {
                                    id: selectFileArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        fileDialog.open()
                                    }
                                }
                            }
                        }

                        // 导入状态显示区域
                        Item {
                            width: parent.width
                            height: statusRect.visible ? statusRect.height + 10 : 0
                            visible: showStatus

                            Rectangle {
                                id: statusRect
                                width: Math.min(parent.width * 0.85, 500)
                                height: Math.max(50, statusText.contentHeight + 20)
                                radius: 8
                                color: isSuccess ? "#d4edda" : "#f8d7da"
                                border.color: isSuccess ? "#28a745" : "#dc3545"
                                border.width: 2
                                anchors.horizontalCenter: parent.horizontalCenter

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 10

                                    Text {
                                        text: isSuccess ? "✓" : "✗"
                                        color: isSuccess ? "#28a745" : "#dc3545"
                                        font.pixelSize: 20
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        id: statusText
                                        text: statusMessage
                                        color: isSuccess ? "#155724" : "#721c24"
                                        font.pixelSize: 14
                                        font.bold: true
                                        wrapMode: Text.WordWrap
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            Behavior on height {
                                NumberAnimation {
                                    duration: 300
                                }
                            }
                        }

                        // 确认导入按钮
                        Column {
                            width: Math.min(parent.width * 0.85, 500)
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 15

                            Rectangle {
                                id: importButton
                                height: 60
                                width: parent.width
                                radius: 12

                                property bool hovered: false
                                property bool pressed: false

                                enabled: selectedFilePath !== ""
                                opacity: enabled ? 1.0 : 0.5

                                color: {
                                    if (!enabled) return "#bdc3c7"
                                    if (pressed) return "#27ae60"
                                    if (hovered) return "#2ecc71"
                                    return "#28a745"
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                    }
                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 100
                                    }
                                }

                                scale: pressed ? 0.98 : 1.0

                                Text {
                                    anchors.centerIn: parent
                                    text: qsTr("确认导入")
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "white"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: parent.enabled
                                    hoverEnabled: true
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor

                                    onClicked: {
                                        if (selectedFilePath !== "") {
                                            console.log("请求导入文件:", selectedFilePath)
                                            clearStatus()
                                            // TODO: 调用后端 C++ 函数进行数据导入
                                            importDataRequested(selectedFilePath)
                                        }
                                    }

                                    onPressed: {
                                        importButton.pressed = true
                                    }

                                    onReleased: {
                                        importButton.pressed = false
                                    }

                                    onEntered: {
                                        importButton.hovered = true
                                    }

                                    onExited: {
                                        importButton.hovered = false
                                    }
                                }
                            }

                            // 取消按钮
                            Rectangle {
                                id: cancelButton
                                height: 55
                                width: parent.width
                                radius: 12

                                property bool hovered: false
                                property bool pressed: false

                                color: {
                                    if (pressed) return "#95a5a6"
                                    if (hovered) return "#bdc3c7"
                                    return "#ffffff"
                                }

                                border.color: {
                                    if (pressed) return "#95a5a6"
                                    if (hovered) return "#bdc3c7"
                                    return "#95a5a6"
                                }
                                border.width: 2

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                    }
                                }

                                Behavior on border
                                .
                                color {
                                    ColorAnimation {
                                        duration: 200
                                    }
                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 100
                                    }
                                }

                                scale: pressed ? 0.98 : 1.0

                                Text {
                                    anchors.centerIn: parent
                                    text: qsTr("取消")
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: {
                                        if (cancelButton.pressed || cancelButton.hovered) return "white"
                                        return "#95a5a6"
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        clearStatus()
                                        selectedFilePath = ""
                                        backRequested()
                                    }

                                    onPressed: {
                                        cancelButton.pressed = true
                                    }

                                    onReleased: {
                                        cancelButton.pressed = false
                                    }

                                    onEntered: {
                                        cancelButton.hovered = true
                                    }

                                    onExited: {
                                        cancelButton.hovered = false
                                    }
                                }
                            }
                        }

                        // 底部提示
                        Column {
                            width: parent.width * 0.85
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8

                            Rectangle {
                                width: parent.width
                                height: tipsColumn.height + 20
                                radius: 8
                                color: "#fff3cd"
                                border.color: "#ffc107"
                                border.width: 1

                                Column {
                                    id: tipsColumn
                                    anchors.centerIn: parent
                                    width: parent.width - 30
                                    spacing: 5

                                    Text {
                                        text: qsTr("⚠ 温馨提示：")
                                        color: "#856404"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }

                                    Text {
                                        text: qsTr("• 请确保导入的文件格式为 JSON")
                                        color: "#856404"
                                        font.pixelSize: 12
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                    }

                                    Text {
                                        text: qsTr("• 导入操作将覆盖现有数据，请谨慎操作")
                                        color: "#856404"
                                        font.pixelSize: 12
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                    }

                                    Text {
                                        text: qsTr("• 建议在导入前先备份当前数据")
                                        color: "#856404"
                                        font.pixelSize: 12
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                    }
                                }
                            }
                        }

                        // 底部间距
                        Item {
                            width: parent.width
                            height: 20
                        }
                    }
                }
            }
        }
    }

    // StateManager 实例引用
    property StateManager stateManager: null
}
