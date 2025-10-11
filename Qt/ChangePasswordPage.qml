import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StateManager 1.0

Item {
    // 定义信号，用于与父组件通信
    signal backToUserInfoRequested()
    signal changePasswordRequested(string oldPassword, string newPassword, string confirmPassword)
    
    // 属性
    property string errorMessage: ""
    property string successMessage: ""
    property bool showError: false
    property bool showSuccess: false
    
    // 添加用于显示消息的函数
    function showChangePasswordError(message) {
        errorMessage = message
        showError = true
        showSuccess = false
    }
    
    function showChangePasswordSuccess(message) {
        successMessage = message
        showSuccess = true
        showError = false
        
        // 3秒后自动返回用户信息页面
        successTimer.restart()
    }
    
    function clearMessages() {
        errorMessage = ""
        successMessage = ""
        showError = false
        showSuccess = false
    }
    
    Timer {
        id: successTimer
        interval: 2000
        onTriggered: {
            clearMessages()
            clearForm()
            backToUserInfoRequested()
        }
    }
    
    function clearForm() {
        oldPasswordField.text = ""
        newPasswordField.text = ""
        confirmPasswordField.text = ""
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
            width: Math.min(parent.width * 0.9, 600)
            height: Math.min(parent.height * 0.9, 650)
            radius: 20
            color: "white"
            opacity: 0.98
            border.color: "#e0e0e0"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 40
                spacing: 0

                // 顶部区域：标题和返回按钮
                Row {
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
                                clearMessages()
                                clearForm()
                                backToUserInfoRequested()
                            }
                        }
                        
                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }
                    
                    // 标题
                    Text {
                        text: qsTr("修改密码")
                        color: "#2c3e50"
                        font.pixelSize: 28
                        font.bold: true
                        anchors.centerIn: parent
                    }
                    
                    // 右侧空白保持平衡
                    Item {
                        width: 100
                        height: 40
                    }
                }

                // 间距
                Item {
                    width: parent.width
                    height: 40
                }

                // 修改密码表单区域
                Rectangle {
                    width: parent.width
                    height: parent.height - 100
                    color: "transparent"
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 25
                        width: Math.min(parent.width * 0.8, 400)

                        // 用户信息提示
                        Column {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10
                            
                            Text {
                                text: qsTr("当前用户: ") + (stateManager ? stateManager.getCurrentUser() : "未知")
                                color: "#2c3e50"
                                font.pixelSize: 18
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                text: qsTr("请输入原密码和新密码")
                                color: "#7f8c8d"
                                font.pixelSize: 14
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        // 消息提示区域
                        Rectangle {
                            width: parent.width
                            height: showError || showSuccess ? 50 : 0
                            radius: 8
                            color: showError ? "#fee" : "#efe"
                            border.color: showError ? "#e74c3c" : "#27ae60"
                            border.width: showError || showSuccess ? 1 : 0
                            visible: showError || showSuccess
                            
                            Text {
                                anchors.centerIn: parent
                                text: showError ? errorMessage : successMessage
                                color: showError ? "#e74c3c" : "#27ae60"
                                font.pixelSize: 14
                                font.bold: true
                                wrapMode: Text.WordWrap
                            }
                            
                            Behavior on height {
                                NumberAnimation { duration: 300 }
                            }
                        }

                        // 原密码输入框
                        Column {
                            width: parent.width
                            spacing: 8
                            
                            Text {
                                text: qsTr("原密码")
                                color: "#34495e"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            TextField {
                                id: oldPasswordField
                                color: "#2c3e50"
                                echoMode: TextInput.Password
                                font.pixelSize: 16
                                height: 50
                                placeholderText: qsTr("请输入原密码")
                                leftPadding: 20
                                rightPadding: 20
                                placeholderTextColor: "#bdc3c7"
                                width: parent.width
                                verticalAlignment: TextInput.AlignVCenter
                                background: Rectangle {
                                    border.color: oldPasswordField.activeFocus ? "#3498db" : "#ecf0f1"
                                    border.width: oldPasswordField.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                    radius: 12
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        color: "transparent"
                                        border.color: oldPasswordField.activeFocus ? "#ffffff" : "#f8f9fa"
                                        border.width: 1
                                        radius: parent.radius - 1
                                    }
                                }
                                onTextChanged: clearMessages()
                            }
                        }

                        // 新密码输入框
                        Column {
                            width: parent.width
                            spacing: 8
                            
                            Text {
                                text: qsTr("新密码")
                                color: "#34495e"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            TextField {
                                id: newPasswordField
                                color: "#2c3e50"
                                echoMode: TextInput.Password
                                font.pixelSize: 16
                                height: 50
                                placeholderText: qsTr("请输入新密码（至少6位）")
                                leftPadding: 20
                                rightPadding: 20
                                placeholderTextColor: "#bdc3c7"
                                width: parent.width
                                verticalAlignment: TextInput.AlignVCenter
                                background: Rectangle {
                                    border.color: newPasswordField.activeFocus ? "#3498db" : "#ecf0f1"
                                    border.width: newPasswordField.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                    radius: 12
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        color: "transparent"
                                        border.color: newPasswordField.activeFocus ? "#ffffff" : "#f8f9fa"
                                        border.width: 1
                                        radius: parent.radius - 1
                                    }
                                }
                                onTextChanged: clearMessages()
                            }
                        }

                        // 确认新密码输入框
                        Column {
                            width: parent.width
                            spacing: 8
                            
                            Text {
                                text: qsTr("确认新密码")
                                color: "#34495e"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            TextField {
                                id: confirmPasswordField
                                color: "#2c3e50"
                                echoMode: TextInput.Password
                                font.pixelSize: 16
                                height: 50
                                placeholderText: qsTr("请再次输入新密码")
                                leftPadding: 20
                                rightPadding: 20
                                placeholderTextColor: "#bdc3c7"
                                width: parent.width
                                verticalAlignment: TextInput.AlignVCenter
                                background: Rectangle {
                                    border.color: confirmPasswordField.activeFocus ? "#3498db" : "#ecf0f1"
                                    border.width: confirmPasswordField.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                    radius: 12
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        color: "transparent"
                                        border.color: confirmPasswordField.activeFocus ? "#ffffff" : "#f8f9fa"
                                        border.width: 1
                                        radius: parent.radius - 1
                                    }
                                }
                                onTextChanged: clearMessages()
                            }
                        }

                        // 按钮区域
                        Column {
                            width: parent.width
                            spacing: 15

                            // 确认修改按钮
                            Rectangle {
                                id: changeButton
                                height: 55
                                width: parent.width
                                radius: 12
                                
                                property bool hovered: false
                                property bool pressed: false
                                
                                color: {
                                    if (pressed) return "#27ae60"
                                    if (hovered) return "#2ecc71"
                                    return "#2c3e50"
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
                                    text: qsTr("确认修改")
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "white"
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    
                                    onClicked: {
                                        clearMessages()
                                        changePasswordRequested(oldPasswordField.text, newPasswordField.text, confirmPasswordField.text)
                                    }
                                    
                                    onPressed: {
                                        changeButton.pressed = true
                                    }
                                    
                                    onReleased: {
                                        changeButton.pressed = false
                                    }
                                    
                                    onEntered: {
                                        changeButton.hovered = true
                                    }
                                    
                                    onExited: {
                                        changeButton.hovered = false
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
                                
                                Behavior on border.color {
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
                                        clearMessages()
                                        clearForm()
                                        backToUserInfoRequested()
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
                        Text {
                            text: qsTr("新密码长度至少需要6位字符")
                            color: "#7f8c8d"
                            font.pixelSize: 12
                            anchors.horizontalCenter: parent.horizontalCenter
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }

    // StateManager 实例引用
    property StateManager stateManager: null
}