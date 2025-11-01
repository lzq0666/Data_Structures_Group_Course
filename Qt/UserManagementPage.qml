import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StateManager 1.0
import UserManager 1.0

Item {
    signal backToAdminRequested()
    signal logoutRequested()
    
    // 新增页面跳转信号
    signal navigateToAddUserPage()
    signal navigateToEditUserPage(int userId, string username, bool isAdmin)
    signal navigateToUserDetailPage(int userId)
    signal navigateToUserAnalyticsPage()
    
    property string errorMessage: ""
    property string successMessage: ""
    property bool showError: false
    property bool showSuccess: false
    
    // 添加刷新锁定机制，防止重复刷新
    property bool isRefreshing: false
    
    // UserManager 实例
    UserManager {
        id: userManager
        
        onUserAdded: function(username) {
            showMessage("用户 " + username + " 添加成功", false)
            if (!isRefreshing) {
                refreshUserList()
            }
        }
        
        onUserDeleted: function(userId) {
            showMessage("用户删除成功", false)
            if (!isRefreshing) {
                refreshUserList()
            }
        }
        
        onUserUpdated: function(userId) {
            showMessage("用户信息更新成功", false)
            if (!isRefreshing) {
                refreshUserList()
            }
        }
        
        onErrorOccurred: function(error) {
            showMessage(error, true)
        }
        
        onDataChanged: {
            if (!isRefreshing) {
                refreshUserList()
            }
        }
    }
    
    // 用户数据模型
    ListModel {
        id: userModel
    }
    
    // 用户统计数据
    property var userStats: ({
        "totalUsers": 0,
        "adminUsers": 0,
        "regularUsers": 0
    })
    
    // 组件完成时加载数据
    Component.onCompleted: {
        loadUserData()
    }
    
    // 加载用户数据
    function loadUserData() {
        refreshUserList()
        refreshUserStats()
    }
    
    // 刷新用户列表 - 修复重复显示问题
    function refreshUserList() {
        if (isRefreshing) return // 防止重复刷新
        
        isRefreshing = true
        console.log("开始刷新用户列表...")
        
        // 清空现有数据
        userModel.clear()
        
        try {
            var users = userManager.getAllUsers()
            console.log("获取到用户数据:", users.length, "个用户")
            
            for (var i = 0; i < users.length; i++) {
                var user = users[i]
                
                // 添加默认注册日期如果不存在
                var registerDate = user.registerDate || "未知"
                
                userModel.append({
                    "userId": user.userId,
                    "username": user.username,
                    "userType": user.userType,
                    "isAdmin": user.isAdmin,
                    "cartItemCount": user.cartItemCount || 0,
                    "browseCount": user.browseCount || 0,
                    "registerDate": registerDate
                })
            }
            
            console.log("用户列表刷新完成，共", userModel.count, "个用户")
        } catch (error) {
            console.error("刷新用户列表时出错:", error)
            showMessage("刷新用户列表失败: " + error, true)
        } finally {
            isRefreshing = false
        }
    }
    
    // 刷新用户统计
    function refreshUserStats() {
        try {
            userStats = userManager.getUserStatistics()
        } catch (error) {
            console.error("刷新用户统计时出错:", error)
        }
    }
    
    // ========================= 接口函数 =========================
    
    // 用户管理接口 - 预留给其他页面调用
    function handleUserAdded(userData) {
        console.log("User added:", JSON.stringify(userData))
        if (userManager.addUser(userData.username, userData.password, userData.isAdmin)) {
            refreshUserList()
            showMessage("用户添加成功", false)
        }
    }
    
    function handleUserUpdated(userId, userData) {
        console.log("User updated:", userId, JSON.stringify(userData))
        userManager.updateUser(userId, userData.username, userData.isAdmin)
    }
    
    function getUserData(userId) {
        var users = userManager.getAllUsers()
        for (var i = 0; i < users.length; i++) {
            if (users[i].userId === userId) {
                return users[i]
            }
        }
        return null
    }
    
    function validateUserData(userData) {
        if (!userData.username || userData.username.trim() === "") {
            return { valid: false, error: "用户名不能为空" }
        }
        if (!userData.password || userData.password.trim() === "") {
            return { valid: false, error: "密码不能为空" }
        }
        return { valid: true, error: "" }
    }
    
    // ========================= 对话框 =========================
    
    // 添加用户对话框 - 简化为跳转按钮
    Dialog {
        id: addUserDialog
        title: "新增用户"
        modal: true
        anchors.centerIn: parent
        width: 400
        height: 200
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20
            
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "点击下方按钮跳转到详细的用户添加页面"
                font.pixelSize: 16
                color: "#2c3e50"
                horizontalAlignment: Text.AlignHCenter
            }
            
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                Layout.preferredHeight: 45
                radius: 10
                color: addPageArea.containsMouse ? "#27ae60" : "#2ecc71"
                
                scale: addPageArea.containsMouse ? 1.02 : 1.0
                
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on scale { NumberAnimation { duration: 150 } }
                
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Text {
                        text: "📝"
                        color: "white"
                        font.pixelSize: 16
                    }
                    
                    Text {
                        text: "进入添加用户页面"
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                    }
                }
                
                MouseArea {
                    id: addPageArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        addUserDialog.close()
                        navigateToAddUserPage()
                    }
                }
            }
        }
        
        standardButtons: Dialog.Cancel
    }
    
    // 编辑用户对话框 - 简化为跳转按钮
    Dialog {
        id: editUserDialog
        title: "编辑用户"
        modal: true
        anchors.centerIn: parent
        width: 400
        height: 250
        
        property int editUserId: -1
        property string editUsername: ""
        property bool editIsAdmin: false
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20
            
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "当前用户: " + editUserDialog.editUsername
                font.pixelSize: 16
                font.bold: true
                color: "#2c3e50"
                horizontalAlignment: Text.AlignHCenter
            }
            
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "点击下方按钮跳转到详细的用户编辑页面"
                font.pixelSize: 14
                color: "#7f8c8d"
                horizontalAlignment: Text.AlignHCenter
            }
            
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                Layout.preferredHeight: 45
                radius: 10
                color: editPageArea.containsMouse ? "#e67e22" : "#f39c12"
                
                scale: editPageArea.containsMouse ? 1.02 : 1.0
                
                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on scale { NumberAnimation { duration: 150 } }
                
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Text {
                        text: "✏️"
                        color: "white"
                        font.pixelSize: 16
                    }
                    
                    Text {
                        text: "进入编辑用户页面"
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                    }
                }
                
                MouseArea {
                    id: editPageArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        editUserDialog.close()
                        navigateToEditUserPage(editUserDialog.editUserId, editUserDialog.editUsername, editUserDialog.editIsAdmin)
                    }
                }
            }
        }
        
        standardButtons: Dialog.Cancel
    }
    
    // 删除确认对话框
    Dialog {
        id: deleteConfirmDialog
        title: "确认删除"
        modal: true
        anchors.centerIn: parent
        width: 300
        height: 150
        
        property int deleteUserId: -1
        property string deleteUsername: ""
        
        Text {
            anchors.centerIn: parent
            text: "确定要删除用户 \"" + deleteConfirmDialog.deleteUsername + "\" 吗？"
            font.pixelSize: 14
            color: "#2c3e50"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
        
        standardButtons: Dialog.Yes | Dialog.No
        
        onAccepted: {
            userManager.deleteUser(deleteUserId)
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

                // 顶部标题栏
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
                        }
                        
                        // 用户信息和退出
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

                // 消息提示栏
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

                // 统计和操作栏
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
                        
                        // 统计图标
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
                        
                        // 统计信息（现在可以点击跳转到分析页面）
                        ColumnLayout {
                            spacing: 2
                            
                            MouseArea {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: navigateToUserAnalyticsPage()
                                
                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 2
                                    
                                    Text {
                                        text: "用户统计 (点击查看详情)"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: parent.parent.containsMouse ? "#3498db" : "#2c3e50"
                                    }
                                    
                                    Text {
                                        text: "总计: " + userStats.totalUsers + " 人 (管理员: " + userStats.adminUsers + ", 普通用户: " + userStats.regularUsers + ")"
                                        font.pixelSize: 12
                                        color: "#7f8c8d"
                                    }
                                }
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // 刷新按钮
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 35
                            radius: 8
                            color: refreshArea.containsMouse ? "#2980b9" : "#3498db"
                            
                            scale: refreshArea.containsMouse ? 1.02 : 1.0
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on scale { NumberAnimation { duration: 150 } }
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 5
                                
                                Text {
                                    text: "🔄"
                                    color: "white"
                                    font.pixelSize: 12
                                }
                                
                                Text {
                                    text: "刷新"
                                    color: "white"
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                            }
                            
                            MouseArea {
                                id: refreshArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    loadUserData()
                                    showMessage("数据已刷新", false)
                                }
                            }
                        }
                        
                        // 新增用户按钮
                        Rectangle {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 35
                            radius: 8
                            color: addUserArea.containsMouse ? "#27ae60" : "#2ecc71"
                            
                            scale: addUserArea.containsMouse ? 1.02 : 1.0
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on scale { NumberAnimation { duration: 150 } }
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 5
                                
                                Text {
                                    text: "➕"
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                
                                Text {
                                    text: "新增用户"
                                    color: "white"
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                            }
                            
                            MouseArea {
                                id: addUserArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    addUserDialog.open()
                                }
                            }
                        }
                    }
                }

                // 用户列表主体
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
                        
                        // 表格标题行
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            radius: 8
                            color: "#f8f9fa"
                            border.color: "#e9ecef"
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 20
                                anchors.rightMargin: 20
                                spacing: 0
                                
                                Text {
                                    Layout.preferredWidth: 250
                                    text: "用户名"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 150
                                    text: "用户类型"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 120
                                    text: "购物车"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 120
                                    text: "浏览数"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 200
                                    text: "操作"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                        
                        // 滚动列表
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
                                id: userListView
                                model: userModel
                                spacing: 12
                                
                                delegate: Rectangle {
                                    width: userListView.width
                                    height: 80
                                    radius: 10
                                    color: "#ffffff"
                                    border.color: "#e8f5e8"
                                    border.width: 2
                                    
                                    // 添加轻微的阴影效果
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.topMargin: 3
                                        anchors.leftMargin: 3
                                        color: "#10000000"
                                        radius: parent.radius
                                        z: -1
                                    }
                                    
                                    // 添加点击区域用于查看用户详情
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            navigateToUserDetailPage(model.userId)
                                        }
                                    }
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 20
                                        anchors.rightMargin: 20
                                        spacing: 0
                                        
                                        // 用户名列
                                        Item {
                                            Layout.preferredWidth: 250
                                            Layout.preferredHeight: parent.height
                                            
                                            RowLayout {
                                                anchors.centerIn: parent
                                                spacing: 12
                                                
                                                Rectangle {
                                                    Layout.preferredWidth: 45
                                                    Layout.preferredHeight: 45
                                                    radius: 22.5
                                                    color: getUserTypeColor(model.userType)
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: model.username ? model.username.charAt(0).toUpperCase() : "?"
                                                        color: "white"
                                                        font.pixelSize: 16
                                                        font.bold: true
                                                    }
                                                }
                                                
                                                Column {
                                                    Layout.alignment: Qt.AlignVCenter
                                                    spacing: 3
                                                    
                                                    Text {
                                                        text: model.username || "未知用户"
                                                        font.pixelSize: 14
                                                        color: "#2c3e50"
                                                        font.bold: true
                                                    }
                                                    
                                                    Text {
                                                        text: "ID: " + model.userId + " | 注册: " + (model.registerDate || "未知")
                                                        font.pixelSize: 11
                                                        color: "#7f8c8d"
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // 用户类型列
                                        Item {
                                            Layout.preferredWidth: 150
                                            Layout.preferredHeight: parent.height
                                            
                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: Math.min(typeLabel.implicitWidth + 20, 120)
                                                height: 30
                                                radius: 15
                                                color: getUserTypeColor(model.userType)
                                                
                                                Text {
                                                    id: typeLabel
                                                    anchors.centerIn: parent
                                                    text: model.userType || "未知"
                                                    font.pixelSize: 12
                                                    color: "white"
                                                    font.bold: true
                                                    elide: Text.ElideRight
                                                }
                                            }
                                        }
                                        
                                        // 购物车商品数列
                                        Item {
                                            Layout.preferredWidth: 120
                                            Layout.preferredHeight: parent.height
                                            
                                            RowLayout {
                                                anchors.centerIn: parent
                                                spacing: 6
                                                
                                                Text {
                                                    text: "🛒"
                                                    font.pixelSize: 16
                                                }
                                                
                                                Text {
                                                    text: (model.cartItemCount || 0) + " 件"
                                                    font.pixelSize: 13
                                                    font.bold: true
                                                    color: (model.cartItemCount || 0) > 0 ? "#e67e22" : "#95a5a6"
                                                }
                                            }
                                        }
                                        
                                        // 浏览数列
                                        Item {
                                            Layout.preferredWidth: 120
                                            Layout.preferredHeight: parent.height
                                            
                                            RowLayout {
                                                anchors.centerIn: parent
                                                spacing: 6
                                                
                                                Text {
                                                    text: "👁"
                                                    font.pixelSize: 14
                                                }
                                                
                                                Text {
                                                    text: (model.browseCount || 0) + " 次"
                                                    font.pixelSize: 13
                                                    font.bold: true
                                                    color: getBrowseCountColor(model.browseCount || 0)
                                                }
                                            }
                                        }
                                        
                                        // 操作列
                                        Item {
                                            Layout.preferredWidth: 200
                                            Layout.preferredHeight: parent.height
                                            
                                            RowLayout {
                                                anchors.centerIn: parent
                                                spacing: 15
                                                
                                                // 编辑按钮
                                                Rectangle {
                                                    Layout.preferredWidth: 40
                                                    Layout.preferredHeight: 40
                                                    radius: 20
                                                    color: editArea.containsMouse ? "#f39c12" : "#ecf0f1"
                                                    border.color: "#f39c12"
                                                    border.width: 1
                                                    
                                                    scale: editArea.containsMouse ? 1.1 : 1.0
                                                    
                                                    Behavior on color { ColorAnimation { duration: 200 } }
                                                    Behavior on scale { NumberAnimation { duration: 150 } }
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "✏"
                                                        font.pixelSize: 15
                                                        color: editArea.containsMouse ? "white" : "#f39c12"
                                                    }
                                                    
                                                    MouseArea {
                                                        id: editArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            editUserDialog.editUserId = model.userId
                                                            editUserDialog.editUsername = model.username
                                                            editUserDialog.editIsAdmin = model.isAdmin
                                                            editUserDialog.open()
                                                        }
                                                    }
                                                    
                                                    ToolTip {
                                                        visible: editArea.containsMouse
                                                        text: "编辑用户"
                                                        delay: 500
                                                    }
                                                }
                                                
                                                // 删除按钮 - 修复工具提示显示逻辑
                                                Rectangle {
                                                    Layout.preferredWidth: 40
                                                    Layout.preferredHeight: 40
                                                    radius: 20
                                                    color: {
                                                        if (model.isAdmin) {
                                                            return "#95a5a6"  // 管理员时显示灰色
                                                        } else {
                                                            return deleteArea.containsMouse ? "#e74c3c" : "#ecf0f1"
                                                        }
                                                    }
                                                    border.color: model.isAdmin ? "#95a5a6" : "#e74c3c"
                                                    border.width: 1
                                                    opacity: model.isAdmin ? 0.6 : 1.0
                                                    
                                                    scale: (!model.isAdmin && deleteArea.containsMouse) ? 1.1 : 1.0
                                                    
                                                    Behavior on color { ColorAnimation { duration: 200 } }
                                                    Behavior on scale { NumberAnimation { duration: 150 } }
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "🗑"
                                                        font.pixelSize: 15
                                                        color: {
                                                            if (model.isAdmin) {
                                                                return "#ffffff"
                                                            } else {
                                                                return deleteArea.containsMouse ? "white" : "#e74c3c"
                                                            }
                                                        }
                                                    }
                                                    
                                                    MouseArea {
                                                        id: deleteArea
                                                        anchors.fill: parent
                                                        hoverEnabled: !model.isAdmin
                                                        cursorShape: model.isAdmin ? Qt.ArrowCursor : Qt.PointingHandCursor
                                                        enabled: !model.isAdmin
                                                        onClicked: {
                                                            if (!model.isAdmin) {
                                                                deleteConfirmDialog.deleteUserId = model.userId
                                                                deleteConfirmDialog.deleteUsername = model.username
                                                                deleteConfirmDialog.open()
                                                            }
                                                        }
                                                    }
                                                    
                                                    // 修复工具提示逻辑
                                                    ToolTip {
                                                        visible: model.isAdmin ? true : deleteArea.containsMouse
                                                        text: model.isAdmin ? "管理员无法删除" : "删除用户"
                                                        delay: model.isAdmin ? 0 : 500
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
    
    // 辅助函数 - 修复颜色映射
    function getUserTypeColor(userType) {
        if (!userType) return "#95a5a6"
        
        switch(userType) {
            case "管理员": return "#e74c3c"
            case "普通用户": return "#3498db"
            default: return "#95a5a6"
        }
    }
    
    function getBrowseCountColor(count) {
        var browseCount = count || 0
        if (browseCount > 200) return "#e74c3c"  // 红色 - 高活跃
        if (browseCount > 100) return "#f39c12"  // 橙色 - 中活跃
        if (browseCount > 50) return "#2ecc71"   // 绿色 - 一般活跃
        return "#95a5a6"                         // 灰色 - 低活跃
    }
}