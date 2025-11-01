import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StateManager 1.0

Item {
    // 定义信号，用于与父组件通信
    signal logoutRequested()
    signal browseProductsRequested()
    signal personalRecommendRequested()
    signal shoppingCartRequested()
    signal userInfoRequested()  // 新增用户信息信号

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                color: "#a1c4fd"
                position: 0.0
            }
            GradientStop {
                color: "#c2e9fb"
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

                // 顶部区域：标题和用户信息
                Row {
                    width: parent.width
                    height: 80
                    
                    // 左侧标题
                    Column {
                        width: parent.width * 0.7
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: qsTr("商品推荐系统")
                            color: "#2c3e50"
                            font.pixelSize: 28
                            font.bold: true
                        }
                        
                        Text {
                            text: qsTr("欢迎使用智能推荐功能")
                            color: "#7f8c8d"
                            font.pixelSize: 16
                        }
                    }
                    
                    // 右侧用户信息
                    Column {
                        width: parent.width * 0.3
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8
                        
                        Text {
                            text: qsTr("用户: ") + (stateManager ? stateManager.getCurrentUser() : "未知")
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

                        // 第一行：浏览商品和个性化推荐
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 40

                            // 浏览商品按钮
                            Rectangle {
                                id: browseButton
                                width: 200
                                height: 120
                                radius: 15
                                color: "#ffffff"
                                border.color: browseArea.containsMouse ? "#3498db" : "#ecf0f1"
                                border.width: 2
                                
                                scale: browseArea.containsMouse ? 1.05 : 1.0
                                
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
                                            text: "🛍"
                                            font.pixelSize: 24
                                        }
                                    }
                                    
                                    Text {
                                        text: qsTr("浏览商品")
                                        color: "#2c3e50"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: browseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: browseProductsRequested()
                                }
                            }

                            // 个性化推荐按钮
                            Rectangle {
                                id: recommendButton
                                width: 200
                                height: 120
                                radius: 15
                                color: "#ffffff"
                                border.color: recommendArea.containsMouse ? "#e74c3c" : "#ecf0f1"
                                border.width: 2
                                
                                scale: recommendArea.containsMouse ? 1.05 : 1.0
                                
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
                                            text: "🎯"
                                            font.pixelSize: 24
                                        }
                                    }
                                    
                                    Text {
                                        text: qsTr("个性化推荐")
                                        color: "#2c3e50"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: recommendArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: personalRecommendRequested()
                                }
                            }
                        }

                        // 第二行：用户信息和购物车
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 40

                            // 用户信息按钮
                            Rectangle {
                                id: userInfoButton
                                width: 200
                                height: 120
                                radius: 15
                                color: "#ffffff"
                                border.color: userInfoArea.containsMouse ? "#9b59b6" : "#ecf0f1"
                                border.width: 2
                                
                                scale: userInfoArea.containsMouse ? 1.05 : 1.0
                                
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
                                            text: "👤"
                                            font.pixelSize: 24
                                        }
                                    }
                                    
                                    Text {
                                        text: qsTr("用户信息")
                                        color: "#2c3e50"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: userInfoArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: userInfoRequested()
                                }
                            }

                            // 购物车按钮
                            Rectangle {
                                id: cartButton
                                width: 200
                                height: 120
                                radius: 15
                                color: "#ffffff"
                                border.color: cartArea.containsMouse ? "#f39c12" : "#ecf0f1"
                                border.width: 2
                                
                                scale: cartArea.containsMouse ? 1.05 : 1.0
                                
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
                                            text: "🛒"
                                            font.pixelSize: 24
                                        }
                                    }
                                    
                                    Text {
                                        text: qsTr("购物车")
                                        color: "#2c3e50"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: cartArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: shoppingCartRequested()
                                }
                            }
                        }

                        // 底部提示信息
                        Text {
                            text: qsTr("点击上方按钮开始使用系统功能")
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