import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StateManager 1.0

Item {
    signal backToAdminRequested()
    signal logoutRequested()
    
    property string errorMessage: ""
    property string successMessage: ""
    property bool showError: false
    property bool showSuccess: false
    
    ListModel {
        id: userModel
        Component.onCompleted: {
            append({
                "userId": 1,
                "username": "user",
                "isAdmin": false,
                "status": "正常",
                "lastLogin": "2024-01-15",
                "shoppingItems": 0,
                "browseHistory": 5
            })
            append({
                "userId": 2,
                "username": "admin", 
                "isAdmin": true,
                "status": "正常",
                "lastLogin": "2024-01-16",
                "shoppingItems": 0,
                "browseHistory": 12
            })
            append({
                "userId": 3,
                "username": "testuser",
                "isAdmin": false,
                "status": "正常", 
                "lastLogin": "2024-01-10",
                "shoppingItems": 3,
                "browseHistory": 8
            })
        }
    }
    
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

        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.98, 1400)
            height: Math.min(parent.height * 0.98, 900)
            radius: 20
            color: "white"
            opacity: 0.98
            border.color: "#e0e0e0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20

                // 顶部导航栏
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    radius: 15
                    color: "#ffffff"
                    border.color: "#ecf0f1"
                    border.width: 2
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20
                        
                        // 返回按钮
                        Rectangle {
                            id: backButton
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 40
                            radius: 10
                            color: backArea.containsMouse ? "#3498db" : "#2c3e50"
                            
                            scale: backArea.containsMouse ? 1.03 : 1.0
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on scale { NumberAnimation { duration: 150 } }
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 5
                                
                                Text {
                                    text: "←"
                                    color: "white"
                                    font.pixelSize: 16
                                    font.bold: true
                                }
                                
                                Text {
                                    text: "返回"
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }
                            
                            MouseArea {
                                id: backArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: backToAdminRequested()
                            }
                        }
                        
                        // 标题区域
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignCenter
                            spacing: 4
                            
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 10
                                
                                Rectangle {
                                    Layout.preferredWidth: 35
                                    Layout.preferredHeight: 35
                                    radius: 17
                                    color: "#3498db"
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "👥"
                                        font.pixelSize: 18
                                    }
                                }
                                
                                Text {
                                    text: "用户管理"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#2c3e50"
                                }
                            }
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "管理系统用户账户与权限"
                                font.pixelSize: 14
                                color: "#7f8c8d"
                            }
                        }
                        
                        // 管理员信息
                        Column {
                            Layout.preferredWidth: 150
                            spacing: 5
                            
                            Text {
                                text: "管理员: " + (stateManager ? stateManager.getCurrentUser() : "未知")
                                color: "#34495e"
                                font.pixelSize: 12
                                anchors.right: parent.right
                            }
                            
                            Rectangle {
                                id: logoutButton
                                width: 60
                                height: 25
                                radius: 6
                                color: logoutArea.containsMouse ? "#e74c3c" : "#95a5a6"
                                anchors.right: parent.right
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "退出"
                                    color: "white"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                                
                                MouseArea {
                                    id: logoutArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: logoutRequested()
                                }
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }
                            }
                        }
                    }
                }

                // 消息提示区域
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: showError || showSuccess ? 50 : 0
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
                    
                    Behavior on Layout.preferredHeight {
                        NumberAnimation { duration: 300 }
                    }
                }

                // 工具栏
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    radius: 15
                    color: "#ffffff"
                    border.color: "#ecf0f1"
                    border.width: 2
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15
                        
                        Rectangle {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            radius: 15
                            color: "#2ecc71"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "📊"
                                font.pixelSize: 15
                            }
                        }
                        
                        ColumnLayout {
                            spacing: 2
                            
                            Text {
                                text: "用户统计"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#2c3e50"
                            }
                            
                            Text {
                                text: "共 " + userModel.count + " 个用户"
                                font.pixelSize: 12
                                color: "#7f8c8d"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // 搜索框（功能暂未实现）
                        Rectangle {
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 30
                            radius: 8
                            color: "#f8f9fa"
                            border.color: "#e9ecef"
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 5
                                
                                Text {
                                    text: "🔍"
                                    font.pixelSize: 12
                                    color: "#7f8c8d"
                                }
                                
                                TextField {
                                    Layout.fillWidth: true
                                    placeholderText: "搜索用户... (功能暂未开放)"
                                    font.pixelSize: 11
                                    color: "#2c3e50"
                                    placeholderTextColor: "#bdc3c7"
                                    background: Item {}
                                    verticalAlignment: TextInput.AlignVCenter
                                    enabled: false
                                }
                            }
                        }
                        
                        // 添加用户按钮（功能暂未实现）
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            radius: 8
                            color: addUserArea.containsMouse ? "#27ae60" : "#2ecc71"
                            
                            scale: addUserArea.containsMouse ? 1.02 : 1.0
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on scale { NumberAnimation { duration: 150 } }
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 3
                                
                                Text {
                                    text: "+"
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                
                                Text {
                                    text: "新增"
                                    color: "white"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }
                            
                            MouseArea {
                                id: addUserArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    showMessage("添加用户功能暂未实现", false)
                                }
                            }
                        }
                    }
                }

                // 用户列表
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 15
                    color: "#ffffff"
                    border.color: "#ecf0f1"
                    border.width: 2
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15
                        
                        // 表头
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                            radius: 8
                            color: "#f8f9fa"
                            border.color: "#e9ecef"
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 0
                                
                                Text {
                                    Layout.preferredWidth: 80
                                    text: "用户ID"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 120
                                    text: "用户名"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 100
                                    text: "用户类型"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 80
                                    text: "状态"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 100
                                    text: "最后登录"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 80
                                    text: "购物车"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 80
                                    text: "浏览记录"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Text {
                                    Layout.fillWidth: true
                                    text: "操作"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                        
                        // 用户列表
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            
                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                                width: 8
                                background: Rectangle {
                                    color: "#f8f9fa"
                                    radius: 4
                                }
                                contentItem: Rectangle {
                                    color: "#bdc3c7"
                                    radius: 4
                                }
                            }
                            
                            ListView {
                                model: userModel
                                spacing: 10
                                
                                delegate: Rectangle {
                                    width: ListView.view.width
                                    height: 70
                                    radius: 10
                                    color: "#ffffff"
                                    border.color: "#ecf0f1"
                                    border.width: 1
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.topMargin: 2
                                        anchors.leftMargin: 2
                                        color: "#05000000"
                                        radius: parent.radius
                                        z: -1
                                    }
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 15
                                        spacing: 0
                                        
                                        // 用户ID
                                        Text {
                                            Layout.preferredWidth: 80
                                            text: model.userId
                                            font.pixelSize: 13
                                            color: "#2c3e50"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        
                                        // 用户名
                                        RowLayout {
                                            Layout.preferredWidth: 120
                                            spacing: 8
                                            
                                            Rectangle {
                                                Layout.preferredWidth: 30
                                                Layout.preferredHeight: 30
                                                radius: 15
                                                color: model.isAdmin ? "#e74c3c" : "#3498db"
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: model.username.charAt(0).toUpperCase()
                                                    color: "white"
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                }
                                            }
                                            
                                            Text {
                                                text: model.username
                                                font.pixelSize: 13
                                                color: "#2c3e50"
                                                font.bold: true
                                            }
                                        }
                                        
                                        // 用户类型
                                        Rectangle {
                                            Layout.preferredWidth: 100
                                            Layout.alignment: Qt.AlignHCenter
                                            width: typeLabel.implicitWidth + 12
                                            height: 22
                                            radius: 11
                                            color: model.isAdmin ? "#e74c3c" : "#3498db"
                                            
                                            Text {
                                                id: typeLabel
                                                anchors.centerIn: parent
                                                text: model.isAdmin ? "管理员" : "普通用户"
                                                font.pixelSize: 10
                                                color: "white"
                                                font.bold: true
                                            }
                                        }
                                        
                                        // 状态
                                        Rectangle {
                                            Layout.preferredWidth: 80
                                            Layout.alignment: Qt.AlignHCenter
                                            width: statusLabel.implicitWidth + 12
                                            height: 22
                                            radius: 11
                                            color: "#2ecc71"
                                            
                                            Text {
                                                id: statusLabel
                                                anchors.centerIn: parent
                                                text: model.status
                                                font.pixelSize: 10
                                                color: "white"
                                                font.bold: true
                                            }
                                        }
                                        
                                        // 最后登录
                                        Text {
                                            Layout.preferredWidth: 100
                                            text: model.lastLogin
                                            font.pixelSize: 11
                                            color: "#7f8c8d"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        
                                        // 购物车
                                        Text {
                                            Layout.preferredWidth: 80
                                            text: model.shoppingItems
                                            font.pixelSize: 13
                                            color: "#2c3e50"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        
                                        // 浏览记录
                                        Text {
                                            Layout.preferredWidth: 80
                                            text: model.browseHistory
                                            font.pixelSize: 13
                                            color: "#2c3e50"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        
                                        // 操作按钮
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 5
                                            
                                            // 编辑按钮
                                            Rectangle {
                                                Layout.preferredWidth: 50
                                                Layout.preferredHeight: 25
                                                radius: 6
                                                color: editArea.containsMouse ? "#f39c12" : "#ffffff"
                                                border.color: editArea.containsMouse ? "#f39c12" : "#e67e22"
                                                border.width: 1
                                                
                                                scale: editArea.containsMouse ? 1.05 : 1.0
                                                
                                                Behavior on color { ColorAnimation { duration: 200 } }
                                                Behavior on scale { NumberAnimation { duration: 150 } }
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "编辑"
                                                    font.pixelSize: 10
                                                    color: editArea.containsMouse ? "white" : "#e67e22"
                                                    font.bold: true
                                                }
                                                
                                                MouseArea {
                                                    id: editArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        showMessage("编辑用户功能暂未实现", false)
                                                    }
                                                }
                                            }
                                            
                                            // 删除按钮（不能删除管理员）
                                            Rectangle {
                                                Layout.preferredWidth: 50
                                                Layout.preferredHeight: 25
                                                radius: 6
                                                color: model.isAdmin ? "#95a5a6" : (deleteArea.containsMouse ? "#e74c3c" : "#ffffff")
                                                border.color: model.isAdmin ? "#95a5a6" : (deleteArea.containsMouse ? "#e74c3c" : "#c0392b")
                                                border.width: 1
                                                opacity: model.isAdmin ? 0.6 : 1.0
                                                
                                                scale: (!model.isAdmin && deleteArea.containsMouse) ? 1.05 : 1.0
                                                
                                                Behavior on color { ColorAnimation { duration: 200 } }
                                                Behavior on scale { NumberAnimation { duration: 150 } }
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "删除"
                                                    font.pixelSize: 10
                                                    color: model.isAdmin ? "#ffffff" : (deleteArea.containsMouse ? "white" : "#c0392b")
                                                    font.bold: true
                                                }
                                                
                                                MouseArea {
                                                    id: deleteArea
                                                    anchors.fill: parent
                                                    hoverEnabled: !model.isAdmin
                                                    cursorShape: model.isAdmin ? Qt.ArrowCursor : Qt.PointingHandCursor
                                                    enabled: !model.isAdmin
                                                    onClicked: {
                                                        if (!model.isAdmin) {
                                                            showMessage("删除用户功能暂未实现", false)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    property StateManager stateManager: null
}