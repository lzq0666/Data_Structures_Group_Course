import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StateManager 1.0

Item {
    signal logoutRequested()
    signal userManagementRequested()
    signal productManagementRequested()

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
                spacing: 0

                Row {
                    width: parent.width
                    height: 80
                    
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

                Item {
                    width: parent.width
                    height: parent.height - 80
                    
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -60
                        spacing: 60

                        Rectangle {
                            id: userManageButton
                            width: 240
                            height: 140
                            radius: 20
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
                                spacing: 15
                                
                                Rectangle {
                                    width: 60
                                    height: 60
                                    radius: 30
                                    color: "#3498db"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "👥"
                                        font.pixelSize: 28
                                    }
                                }
                                
                                Text {
                                    text: qsTr("用户管理")
                                    color: "#2c3e50"
                                    font.pixelSize: 18
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

                        Rectangle {
                            id: productManageButton
                            width: 240
                            height: 140
                            radius: 20
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
                                spacing: 15
                                
                                Rectangle {
                                    width: 60
                                    height: 60
                                    radius: 30
                                    color: "#e74c3c"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "📦"
                                        font.pixelSize: 28
                                    }
                                }
                                
                                Text {
                                    text: qsTr("商品管理")
                                    color: "#2c3e50"
                                    font.pixelSize: 18
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
                }
            }
        }
    }

    property StateManager stateManager: null
}