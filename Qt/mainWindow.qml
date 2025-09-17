import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Window

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

        Rectangle {
            anchors.centerIn: parent//居中
            height: 500
            radius: 10//圆角
            width: 800

            Text {
                color: "#333333"
                font.pixelSize: 24
                height: 50
                text: qsTr("登陆系统")
                width: 120
                x: 530
                y: 150
            }
            //用户名
            TextField {
                id: username
                color: "#494949"
                font.pixelSize: 22
                height: 50
                placeholderText: qsTr("用户名")
                leftPadding:20
                placeholderTextColor: "#999999"
                width: 300
                x: 440
                y: 200
                background: Rectangle {
                    //圆角
                    border.color: "#e6e6e6"
                    border.width: 1
                    color: "#e6e6e6"
                    radius: 25
                }
            }
            //密码
            TextField {
                id: password
                color: username.color
                echoMode: TextInput.Password
                font.pixelSize: username.font.pixelSize
                height: username.height
                placeholderText: qsTr("密码")
                leftPadding: username.leftPadding
                placeholderTextColor: username.placeholderTextColor
                width: username.width
                x: username.x
                y: username.y + username.height + 20
                background: Rectangle {
                    //圆角
                    border.color: username.background.border.color
                    border.width: username.background.border.width
                    color: username.background.color
                    radius: username.background.radius
                }
            }
            //登陆按钮
            Button {
                font.pixelSize: 22
                height: password.height
                text: qsTr("登  录")
                width: password.width
                x: password.x
                y: password.y + password.height + 20
                background: Rectangle {
                    //圆角
                    border.color: username.background.border.color
                    border.width: username.background.border.width
                    color: username.background.color
                    radius: username.background.radius
                }

                onClicked: {
                    print("用户名:" + username.text + " 密码:" + password.text);  //改这部分
                }
            }

        }
    }
}