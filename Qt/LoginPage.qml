import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Item {
    // 定义信号，用于与父组件通信
    signal loginRequested(string username, string password)
    signal registerRequested() // 改为无参数信号，用于跳转到注册页面
    
    // 添加用于显示登录错误信息的属性
    property string errorMessage: ""
    property bool showError: false
    
    // 添加用于接收登录结果的函数
    function showLoginError(message) {
        errorMessage = message
        showError = true
    }
    
    function clearError() {
        errorMessage = ""
        showError = false
    }

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

        // 主容器 Rectangle，包含图片和登录框
        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.85, 1100)
            height: Math.min(parent.height * 0.85, 650) // 恢复原始高度
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
                        source: "qrc:/resources/images/undraw_enter-password_1kl4.svg"
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
                        spacing: 25 // 恢复原始间距
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

                        // 错误提示文本
                        Text {
                            width: parent.width
                            visible: showError
                            text: errorMessage
                            color: "#e74c3c"
                            font.pixelSize: 14
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            
                            // 添加淡入淡出动画
                            opacity: showError ? 1.0 : 0.0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 300
                                }
                            }
                        }

                        // 按钮区域
                        Column {
                            width: parent.width
                            spacing: 15

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
                                        // 清除之前的错误信息
                                        clearError()
                                        // 发射信号给父组件处理登录
                                        loginRequested(username.text, password.text);
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

                            //前往注册按钮
                            Rectangle {
                                id: registerButton
                                height: 55
                                width: parent.width
                                radius: 12
                                
                                property bool hovered: false
                                property bool pressed: false
                                
                                color: {
                                    if (pressed) return "#27ae60"
                                    if (hovered) return "#2ecc71"
                                    return "#ffffff"
                                }
                                
                                border.color: {
                                    if (pressed) return "#27ae60"
                                    if (hovered) return "#2ecc71"
                                    return "#2ecc71"
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
                                    text: qsTr("前往注册")
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: {
                                        if (registerButton.pressed || registerButton.hovered) return "white"
                                        return "#2ecc71"
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
                                        // 清除之前的错误信息
                                        clearError()
                                        // 发射无参数信号跳转到注册页面
                                        registerRequested();
                                    }
                                    
                                    onPressed: {
                                        registerButton.pressed = true
                                    }
                                    
                                    onReleased: {
                                        registerButton.pressed = false
                                    }
                                    
                                    onEntered: {
                                        registerButton.hovered = true
                                    }
                                    
                                    onExited: {
                                        registerButton.hovered = false
                                    }
                                }
                            }
                        }

                        // 底部提示信息
                        Text {
                            text: qsTr("没有账户？点击前往注册按钮创建新账户")
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
}