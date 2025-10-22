import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StateManager 1.0

Item {
    // 定义信号，用于与父组件通信
    signal backToMainMenuRequested()
    signal logoutRequested()
    signal changePasswordRequested()
    
    // 属性
    property string errorMessage: ""
    property string successMessage: ""
    property bool showError: false
    property bool showSuccess: false
    
    // 添加用于显示消息的函数
    function showMessage(message, isError) {
        if (isError) {
            errorMessage = message
            showError = true
            showSuccess = false
        } else {
            successMessage = message
            showSuccess = true
            showError = false
        }
        
        // 3秒后自动隐藏消息
        messageTimer.restart()
    }
    
    function clearMessages() {
        errorMessage = ""
        successMessage = ""
        showError = false
        showSuccess = false
    }
    
    Timer {
        id: messageTimer
        interval: 3000
        onTriggered: clearMessages()
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
            width: Math.min(parent.width * 0.9, 800)
            height: Math.min(parent.height * 0.9, 700)
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
                            onClicked: backToMainMenuRequested()
                        }
                        
                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }
                    
                    // 标题
                    Text {
                        text: qsTr("用户信息")
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
                    }
                    
                    Behavior on height {
                        NumberAnimation { duration: 300 }
                    }
                }

                // 间距（消息区域后）
                Item {
                    width: parent.width
                    height: showError || showSuccess ? 20 : 0
                }

                // 用户信息主要内容区域
                Rectangle {
                    width: parent.width
                    height: parent.height - 120 - (showError || showSuccess ? 70 : 0)
                    color: "transparent"
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 30
                        width: Math.min(parent.width * 0.8, 500)

                        // 用户头像和基本信息
                        Column {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 20

                            // 用户头像
                            Rectangle {
                                width: 120
                                height: 120
                                radius: 60
                                color: "#9b59b6"
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: stateManager ? stateManager.getCurrentUser().charAt(0).toUpperCase() : "U"
                                    color: "white"
                                    font.pixelSize: 48
                                    font.bold: true
                                }
                            }

                            // 用户名
                            Text {
                                text: stateManager ? stateManager.getCurrentUser() : qsTr("未知用户")
                                color: "#2c3e50"
                                font.pixelSize: 24
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            // 用户权限
                            Rectangle {
                                width: adminLabel.width + 16
                                height: 30
                                radius: 15
                                color: stateManager && stateManager.isCurrentUserAdmin() ? "#e74c3c" : "#3498db"
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                Text {
                                    id: adminLabel
                                    anchors.centerIn: parent
                                    text: stateManager && stateManager.isCurrentUserAdmin() ? qsTr("管理员") : qsTr("普通用户")
                                    color: "white"
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                            }
                        }

                        // 用户统计信息（删除收藏数目）
                        Rectangle {
                            width: parent.width
                            height: 120
                            radius: 12
                            color: "#f8f9fa"
                            border.color: "#e9ecef"
                            border.width: 1

                            Row {
                                anchors.centerIn: parent
                                spacing: 100  // 增加间距，因为只有两项

                                // 购物车数量
                                Column {
                                    spacing: 8
                                    
                                    Text {
                                        text: "0" // TODO: 从数据管理器获取实际数据
                                        color: "#2c3e50"
                                        font.pixelSize: 28
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: qsTr("购物车商品")
                                        color: "#7f8c8d"
                                        font.pixelSize: 14
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }

                                // 浏览历史数量
                                Column {
                                    spacing: 8
                                    
                                    Text {
                                        text: "0" // TODO: 从数据管理器获取实际数据
                                        color: "#2c3e50"
                                        font.pixelSize: 28
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: qsTr("浏览历史")
                                        color: "#7f8c8d"
                                        font.pixelSize: 14
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }

                        // 操作按钮区域
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 20

                            // 修改密码按钮
                            Rectangle {
                                id: changePasswordButton
                                width: 140
                                height: 50
                                radius: 10
                                color: changePasswordArea.containsMouse ? "#f39c12" : "#ffffff"
                                border.color: changePasswordArea.containsMouse ? "#f39c12" : "#e67e22"
                                border.width: 2
                                
                                scale: changePasswordArea.containsMouse ? 1.05 : 1.0
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }
                                
                                Behavior on scale {
                                    NumberAnimation { duration: 150 }
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: qsTr("修改密码")
                                    color: changePasswordArea.containsMouse ? "white" : "#e67e22"
                                    font.pixelSize: 14
                                    font.bold: true
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 200 }
                                    }
                                }
                                
                                MouseArea {
                                    id: changePasswordArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        // 启用修改密码功能
                                        changePasswordRequested()
                                    }
                                }
                            }

                            // 退出登录按钮
                            Rectangle {
                                id: logoutButton
                                width: 140
                                height: 50
                                radius: 10
                                color: logoutArea.containsMouse ? "#e74c3c" : "#ffffff"
                                border.color: logoutArea.containsMouse ? "#e74c3c" : "#c0392b"
                                border.width: 2
                                
                                scale: logoutArea.containsMouse ? 1.05 : 1.0
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }
                                
                                Behavior on scale {
                                    NumberAnimation { duration: 150 }
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: qsTr("退出登录")
                                    color: logoutArea.containsMouse ? "white" : "#c0392b"
                                    font.pixelSize: 14
                                    font.bold: true
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 200 }
                                    }
                                }
                                
                                MouseArea {
                                    id: logoutArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: logoutRequested()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // StateManager 实例引用
    property StateManager stateManager: null
}