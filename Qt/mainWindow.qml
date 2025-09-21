import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import QtQuick.Controls.Basic 2.12

ApplicationWindow {
    id: logicWindow

    height: 800
    title: "Logic Simulator"
    visible: true //默认显示
    width: 1280

    Rectangle {
        height: parent.height
        width: parent.width

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                color: "#4158d0"
                position: 0.0
            }//开始颜色
            GradientStop {
                color: "#c850c0"
                position: 1.0
            }//结束颜色
        }

        // 主容器 Rectangle，包含图片和登录框
        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.85, 1100)
            height: Math.min(parent.height * 0.85, 650)
            radius: 20
            color: "white"
            opacity: 0.98
            border.color: "#e0e0e0"
            border.width: 1

            // RowLayout 布局：左侧图片，右侧登录框
            RowLayout {
                anchors.fill: parent
                anchors.margins: 40
                spacing: 60

                // 左侧图片区域
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.55

                    Image {
                        anchors.centerIn: parent
                        source: "../resources/images/undraw_enter-password_1kl4.svg"
                        fillMode: Image.PreserveAspectFit
                        width: Math.min(parent.width * 0.8, 350)
                        height: Math.min(parent.height * 0.8, 350)
                    }
                }

                // 右侧登录框区域
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.45

                    Column {
                        anchors.centerIn: parent
                        spacing: 25
                        width: Math.min(parent.width * 0.85, 320)

                        // 标题区域
                        Column {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8
                            
                            Text {
                                color: "#2c3e50"
                                font.pixelSize: 32
                                font.bold: true
                                text: qsTr("欢迎登录")
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                color: "#7f8c8d"
                                font.pixelSize: 16
                                text: qsTr("请输入您的登录信息")
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        //用户名输入框
                        Column {
                            width: parent.width
                            spacing: 8
                            
                            Text {
                                text: qsTr("用户名")
                                color: "#34495e"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            TextField {
                                id: username
                                color: "#2c3e50"
                                font.pixelSize: 16
                                height: 50
                                placeholderText: qsTr("请输入用户名")
                                leftPadding: 20
                                rightPadding: 20
                                placeholderTextColor: "#bdc3c7"
                                width: parent.width
                                verticalAlignment: TextInput.AlignVCenter
                                background: Rectangle {
                                    border.color: username.activeFocus ? "#3498db" : "#ecf0f1"
                                    border.width: username.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                    radius: 12
                                    
                                    // 添加微妙的内阴影效果
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        color: "transparent"
                                        border.color: username.activeFocus ? "#ffffff" : "#f8f9fa"
                                        border.width: 1
                                        radius: parent.radius - 1
                                    }
                                }
                            }
                        }

                        //密码输入框
                        Column {
                            width: parent.width
                            spacing: 8
                            
                            Text {
                                text: qsTr("密码")
                                color: "#34495e"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            TextField {
                                id: password
                                color: username.color
                                echoMode: TextInput.Password
                                font.pixelSize: username.font.pixelSize
                                height: username.height
                                placeholderText: qsTr("请输入密码")
                                leftPadding: username.leftPadding
                                rightPadding: username.rightPadding
                                placeholderTextColor: username.placeholderTextColor
                                width: parent.width
                                verticalAlignment: TextInput.AlignVCenter
                                background: Rectangle {
                                    border.color: password.activeFocus ? "#3498db" : "#ecf0f1"
                                    border.width: password.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                    radius: 12
                                    
                                    // 添加微妙的内阴影效果
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        color: "transparent"
                                        border.color: password.activeFocus ? "#ffffff" : "#f8f9fa"
                                        border.width: 1
                                        radius: parent.radius - 1
                                    }
                                }
                            }
                        }

                        //登录按钮
                        Rectangle {
                            id: loginButton
                            height: 55
                            width: parent.width
                            radius: 12
                            
                            property bool hovered: false
                            property bool pressed: false
                            
                            color: {
                                if (pressed) return "#2980b9"
                                if (hovered) return "#3498db"
                                return "#2c3e50"
                            }
                            
                            // 添加平滑的过渡动画
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
                                text: qsTr("登 录")
                                font.pixelSize: 18
                                font.bold: true
                                color: "white"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    print("用户名:" + username.text + " 密码:" + password.text);
                                }
                                
                                onPressed: {
                                    loginButton.pressed = true
                                }
                                
                                onReleased: {
                                    loginButton.pressed = false
                                }
                                
                                onEntered: {
                                    loginButton.hovered = true
                                }
                                
                                onExited: {
                                    loginButton.hovered = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}