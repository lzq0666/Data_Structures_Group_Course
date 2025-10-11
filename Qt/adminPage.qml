import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StateManager 1.0

Item {
    // 定义信号，用于与父组件通信
    signal logoutRequested()
    signal userManagementRequested()
    signal productManagementRequested()
    signal orderManagementRequested()
    signal systemSettingsRequested()

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
            width: Math.min(parent.width * 0.9, 1000)
            height: Math.min(parent.height * 0.9, 700)
            radius: 20
            color: "white"
            opacity: 0.98
            border.color: "#e0e0e0"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 0  // 移除统一间距，使用独立控制

                // 顶部区域：标题和管理员信息
                Row {
                    width: parent.width
                    height: 80
                    
                    // 左侧标题
                    Column {
                        width: parent.width * 0.7
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: qsTr("管理员控制面板")
                            color: "#2c3e50"
                            font.pixelSize: 28
                            font.bold: true
                        }
                        
                        Text {
                            text: qsTr("系统管理与配置中心")
                            color: "#7f8c8d"
                            font.pixelSize: 16
                        }
                    }
                    
                    // 右侧管理员信息
                    Column {
                        width: parent.width * 0.3
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8
                        
                        Text {
                            text: qsTr("管理员: ") + (stateManager ? stateManager.getCurrentUser() : "未知")
                            color: "#34495e"
                            font.pixelSize: 14
                            anchors.right: parent.right
                        }
                        
                        Rectangle {
                            id: logoutButton
                            width: 70
                            height: 30
                            radius: 8
                            color: logoutArea.containsMouse ? "#e74c3c" : "#95a5a6"
                            anchors.right: parent.right
                            
                            Text {
                                anchors.centerIn: parent
                                text: qsTr("退出")
                                color: "white"
                                font.pixelSize: 12
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

                // 添加间距
                Item {
                    width: parent.width
                    height: 60  // 增加顶部间距
                }

                // 功能按钮区域 - 垂直居中
                Item {
                    width: parent.width
                    height: parent.height - 140  // 减去顶部区域和间距的高度
                    
                    Column {
                        anchors.centerIn: parent  // 在可用空间中垂直和水平居中
                        spacing: 30

                        // 第一行：用户管理和商品管理
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 40

                            // 用户管理按钮
                            Rectangle {
                                id: userManageButton
                                width: 200
                                height: 120
                                radius: 15
                                color: "#ffffff"
                                border.color: userManageArea.containsMouse ? "#3498db" : "#ecf0f1"
                                border.width: 2
                                
                                scale: userManageArea.containsMouse ? 1.05 : 1.0
                                
                                Behavior on border.color {
                                    ColorAnimation { duration: 200 }
                                }
                                
                                Behavior on scale {
                                    NumberAnimation { duration: 150 }
                                }
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    
                                    Rectangle {
                                        width: 50
                                        height: 50
                                        radius: 25
                                        color: "#3498db"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "👥"
                                            font.pixelSize: 24
                                        }
                                    }
                                    
                                    Text {
                                        text: qsTr("用户管理")
                                        color: "#2c3e50"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: userManageArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: userManagementRequested()
                                }
                            }

                            // 商品管理按钮
                            Rectangle {
                                id: productManageButton
                                width: 200
                                height: 120
                                radius: 15
                                color: "#ffffff"
                                border.color: productManageArea.containsMouse ? "#e74c3c" : "#ecf0f1"
                                border.width: 2
                                
                                scale: productManageArea.containsMouse ? 1.05 : 1.0
                                
                                Behavior on border.color {
                                    ColorAnimation { duration: 200 }
                                }
                                
                                Behavior on scale {
                                    NumberAnimation { duration: 150 }
                                }
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    
                                    Rectangle {
                                        width: 50
                                        height: 50
                                        radius: 25
                                        color: "#e74c3c"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "📦"
                                            font.pixelSize: 24
                                        }
                                    }
                                    
                                    Text {
                                        text: qsTr("商品管理")
                                        color: "#2c3e50"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: productManageArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: productManagementRequested()
                                }
                            }
                        }

                        // 第二行：订单管理和系统设置
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 40

                            // 订单管理按钮
                            Rectangle {
                                id: orderManageButton
                                width: 200
                                height: 120
                                radius: 15
                                color: "#ffffff"
                                border.color: orderManageArea.containsMouse ? "#f39c12" : "#ecf0f1"
                                border.width: 2
                                
                                scale: orderManageArea.containsMouse ? 1.05 : 1.0
                                
                                Behavior on border.color {
                                    ColorAnimation { duration: 200 }
                                }
                                
                                Behavior on scale {
                                    NumberAnimation { duration: 150 }
                                }
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    
                                    Rectangle {
                                        width: 50
                                        height: 50
                                        radius: 25
                                        color: "#f39c12"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "📋"
                                            font.pixelSize: 24
                                        }
                                    }
                                    
                                    Text {
                                        text: qsTr("订单管理")
                                        color: "#2c3e50"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: orderManageArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: orderManagementRequested()
                                }
                            }

                            // 系统设置按钮
                            Rectangle {
                                id: systemSettingsButton
                                width: 200
                                height: 120
                                radius: 15
                                color: "#ffffff"
                                border.color: systemSettingsArea.containsMouse ? "#9b59b6" : "#ecf0f1"
                                border.width: 2
                                
                                scale: systemSettingsArea.containsMouse ? 1.05 : 1.0
                                
                                Behavior on border.color {
                                    ColorAnimation { duration: 200 }
                                }
                                
                                Behavior on scale {
                                    NumberAnimation { duration: 150 }
                                }
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    
                                    Rectangle {
                                        width: 50
                                        height: 50
                                        radius: 25
                                        color: "#9b59b6"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "⚙️"
                                            font.pixelSize: 24
                                        }
                                    }
                                    
                                    Text {
                                        text: qsTr("系统设置")
                                        color: "#2c3e50"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: systemSettingsArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: systemSettingsRequested()
                                }
                            }
                        }

                        // 底部提示信息
                        Text {
                            text: qsTr("选择上方功能模块进行系统管理")
                            color: "#7f8c8d"
                            font.pixelSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                            topPadding: 20
                        }
                    }
                }
            }
        }
    }

    // StateManager 实例引用
    property StateManager stateManager: null
}
