import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import QtQuick.Controls.Basic 2.12
import LoginManager 1.0

ApplicationWindow {
    id: logicWindow

    height: 800
    title: "Logic Simulator"
    visible: true //默认显示
    width: 1280

    // 状态管理
    property bool isLoggedIn: false
    property string currentUser: ""
    property int currentMode: 0 // 0: 登录, 1: 注册, 2: 修改密码

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
            height: Math.min(parent.height * 0.85, 700)
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
                        spacing: 20
                        width: Math.min(parent.width * 0.85, 320)

                        // 模式切换按钮
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10
                            
                            Repeater {
                                model: ["登录", "注册", "修改密码"]
                                delegate: Rectangle {
                                    width: 80
                                    height: 30
                                    radius: 15
                                    color: currentMode === index ? "#3498db" : "transparent"
                                    border.color: "#3498db"
                                    border.width: 1
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: currentMode === index ? "white" : "#3498db"
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            currentMode = index
                                            clearInputs()
                                            clearMessage()
                                        }
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }
                        }

                        // 标题区域
                        Column {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8
                            
                            Text {
                                color: "#2c3e50"
                                font.pixelSize: 28
                                font.bold: true
                                text: {
                                    switch(currentMode) {
                                        case 0: return qsTr("欢迎登录")
                                        case 1: return qsTr("用户注册")  
                                        case 2: return qsTr("修改密码")
                                        default: return qsTr("欢迎登录")
                                    }
                                }
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                color: "#7f8c8d"
                                font.pixelSize: 14
                                text: {
                                    switch(currentMode) {
                                        case 0: return qsTr("请输入您的登录信息")
                                        case 1: return qsTr("姓氏与名字之间请用_连接")
                                        case 2: return qsTr("请输入用户信息和新密码")
                                        default: return qsTr("请输入您的登录信息")
                                    }
                                }
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
                                height: 45
                                placeholderText: qsTr("请输入用户名")
                                leftPadding: 20
                                rightPadding: 20
                                placeholderTextColor: "#bdc3c7"
                                width: parent.width
                                verticalAlignment: TextInput.AlignVCenter
                                
                                Keys.onReturnPressed: {
                                    if (currentMode === 2) oldPassword.forceActiveFocus()
                                    else password.forceActiveFocus()
                                }
                                Keys.onEnterPressed: {
                                    if (currentMode === 2) oldPassword.forceActiveFocus()
                                    else password.forceActiveFocus()
                                }
                                
                                background: Rectangle {
                                    border.color: username.activeFocus ? "#3498db" : "#ecf0f1"
                                    border.width: username.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                    radius: 12
                                }
                            }
                        }

                        // 旧密码输入框 (仅修改密码模式显示)
                        Column {
                            width: parent.width
                            spacing: 8
                            visible: currentMode === 2
                            height: visible ? implicitHeight : 0
                            
                            Text {
                                text: qsTr("旧密码")
                                color: "#34495e"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            TextField {
                                id: oldPassword
                                color: "#2c3e50"
                                echoMode: TextInput.Password
                                font.pixelSize: 16
                                height: 45
                                placeholderText: qsTr("请输入旧密码")
                                leftPadding: 20
                                rightPadding: 20
                                placeholderTextColor: "#bdc3c7"
                                width: parent.width
                                verticalAlignment: TextInput.AlignVCenter
                                
                                Keys.onReturnPressed: password.forceActiveFocus()
                                Keys.onEnterPressed: password.forceActiveFocus()
                                
                                background: Rectangle {
                                    border.color: oldPassword.activeFocus ? "#3498db" : "#ecf0f1"
                                    border.width: oldPassword.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                    radius: 12
                                }
                            }
                        }

                        //密码输入框
                        Column {
                            width: parent.width
                            spacing: 8
                            
                            Text {
                                text: currentMode === 2 ? qsTr("新密码") : qsTr("密码")
                                color: "#34495e"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            TextField {
                                id: password
                                color: "#2c3e50"
                                echoMode: TextInput.Password
                                font.pixelSize: 16
                                height: 45
                                placeholderText: {
                                    switch(currentMode) {
                                        case 0: return qsTr("请输入密码")
                                        case 1: return qsTr("请输入密码（至少6位）")
                                        case 2: return qsTr("请输入新密码（至少6位）")
                                        default: return qsTr("请输入密码")
                                    }
                                }
                                leftPadding: 20
                                rightPadding: 20
                                placeholderTextColor: "#bdc3c7"
                                width: parent.width
                                verticalAlignment: TextInput.AlignVCenter
                                
                                Keys.onReturnPressed: handleAction()
                                Keys.onEnterPressed: handleAction()
                                
                                background: Rectangle {
                                    border.color: password.activeFocus ? "#3498db" : "#ecf0f1"
                                    border.width: password.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                    radius: 12
                                }
                            }
                        }

                        // 消息提示区域
                        Rectangle {
                            id: messageArea
                            width: parent.width
                            height: messageText.visible ? 35 : 0
                            color: "transparent"
                            
                            Text {
                                id: messageText
                                anchors.centerIn: parent
                                width: parent.width
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: 13
                                visible: text.length > 0
                                
                                property bool isSuccess: false
                                color: isSuccess ? "#27ae60" : "#e74c3c"
                            }
                            
                            Timer {
                                id: messageTimer
                                interval: 4000
                                onTriggered: messageText.text = ""
                            }
                        }

                        // 主操作按钮
                        Rectangle {
                            id: actionButton
                            height: 50
                            width: parent.width
                            radius: 12
                            
                            property bool hovered: false
                            property bool pressed: false
                            property bool loading: false
                            
                            color: {
                                if (loading) return "#95a5a6"
                                if (pressed) return "#2980b9"
                                if (hovered) return "#3498db"
                                return "#2c3e50"
                            }
                            
                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                            
                            Behavior on scale {
                                NumberAnimation { duration: 100 }
                            }
                            
                            scale: pressed ? 0.98 : 1.0
                            
                            Text {
                                anchors.centerIn: parent
                                text: {
                                    if (actionButton.loading) {
                                        switch(currentMode) {
                                            case 0: return qsTr("登录中...")
                                            case 1: return qsTr("注册中...")
                                            case 2: return qsTr("修改中...")
                                            default: return qsTr("处理中...")
                                        }
                                    } else {
                                        switch(currentMode) {
                                            case 0: return qsTr("登 录")
                                            case 1: return qsTr("注 册")
                                            case 2: return qsTr("修改密码")
                                            default: return qsTr("确 定")
                                        }
                                    }
                                }
                                font.pixelSize: 16
                                font.bold: true
                                color: "white"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: !actionButton.loading
                                
                                onClicked: handleAction()
                                onPressed: actionButton.pressed = true
                                onReleased: actionButton.pressed = false
                                onEntered: actionButton.hovered = true
                                onExited: actionButton.hovered = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 处理主要操作
    function handleAction() {
        if (actionButton.loading) return
        
        var user = username.text.trim()
        var pass = password.text
        
        if (user.length === 0) {
            showMessage("请输入用户名", false)
            return
        }
        
        if (pass.length === 0) {
            showMessage("请输入密码", false)
            return
        }
        
        actionButton.loading = true
        
        switch(currentMode) {
            case 0: // 登录
                loginManager.login(user, pass)
                break
            case 1: // 注册  
                loginManager.registerUser(user, pass)
                break
            case 2: // 修改密码
                var oldPass = oldPassword.text
                if (oldPass.length === 0) {
                    showMessage("请输入旧密码", false)
                    actionButton.loading = false
                    return
                }
                loginManager.changePassword(user, oldPass, pass)
                break
        }
    }
    
    // 显示消息
    function showMessage(message, isSuccess) {
        messageText.text = message
        messageText.isSuccess = isSuccess
        messageTimer.restart()
    }
    
    // 清空输入框
    function clearInputs() {
        username.text = ""
        password.text = ""
        oldPassword.text = ""
    }
    
    // 清空消息
    function clearMessage() {
        messageText.text = ""
    }
    
    // 登录成功后的处理
    function onLoginSuccess(user) {
        isLoggedIn = true
        currentUser = user
        showMessage("登录成功！欢迎 " + user, true)
        
        // 这里可以添加跳转到主应用界面的逻辑
        // 例如：stackView.push("MainApp.qml")
    }
    
    // LoginManager 信号连接
    Connections {
        target: loginManager
        
        function onLoginResult(success, message) {
            actionButton.loading = false
            showMessage(message, success)
            
            if (success) {
                onLoginSuccess(username.text.trim())
            }
        }
        
        function onRegisterResult(success, message) {
            actionButton.loading = false
            showMessage(message, success)
            
            if (success) {
                // 注册成功后切换到登录模式
                currentMode = 0
                clearInputs()
            }
        }
        
        function onChangePasswordResult(success, message) {
            actionButton.loading = false
            showMessage(message, success)
            
            if (success) {
                // 修改密码成功后切换到登录模式
                currentMode = 0
                clearInputs()
            }
        }
    }
}