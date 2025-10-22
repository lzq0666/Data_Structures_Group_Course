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
    
    // 商品数据模型 - 示例数据结构
    ListModel {
        id: productModel
        Component.onCompleted: {
            // 示例商品数据
            append({
                "productId": 1,
                "name": "iPhone 15 Pro",
                "price": 7999.0,
                "stock": 50,
                "category": "手机",
                "avgRating": 4.8,
                "reviewers": 1200,
                "status": "在售"
            })
            append({
                "productId": 2,
                "name": "MacBook Pro M3",
                "price": 12999.0,
                "stock": 30,
                "category": "电脑",
                "avgRating": 4.9,
                "reviewers": 800,
                "status": "在售"
            })
            append({
                "productId": 3,
                "name": "AirPods Pro",
                "price": 1899.0,
                "stock": 0,
                "category": "耳机",
                "avgRating": 4.7,
                "reviewers": 2500,
                "status": "缺货"
            })
            append({
                "productId": 4,
                "name": "iPad Air",
                "price": 4399.0,
                "stock": 80,
                "category": "平板",
                "avgRating": 4.6,
                "reviewers": 1800,
                "status": "在售"
            })
            append({
                "productId": 5,
                "name": "Apple Watch Series 9",
                "price": 2899.0,
                "stock": 60,
                "category": "手表",
                "avgRating": 4.5,
                "reviewers": 1500,
                "status": "在售"
            })
            append({
                "productId": 6,
                "name": "Samsung Galaxy S24",
                "price": 6999.0,
                "stock": 45,
                "category": "手机",
                "avgRating": 4.6,
                "reviewers": 900,
                "status": "在售"
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
                color: "#667eea"
                position: 0.0
            }
            GradientStop {
                color: "#764ba2"
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
                                    color: "#e74c3c"
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "📦"
                                        font.pixelSize: 18
                                    }
                                }
                                
                                Text {
                                    text: "商品管理"
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
                            color: "#e74c3c"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "📊"
                                font.pixelSize: 15
                            }
                        }
                        
                        // 统计信息
                        ColumnLayout {
                            spacing: 2
                            
                            Text {
                                text: "商品统计"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#2c3e50"
                            }
                            
                            Text {
                                text: "总计: " + productModel.count + " 件商品"
                                font.pixelSize: 12
                                color: "#7f8c8d"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // 新增商品按钮
                        Rectangle {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 35
                            radius: 8
                            color: addProductArea.containsMouse ? "#e74c3c" : "#ec7063"
                            
                            scale: addProductArea.containsMouse ? 1.02 : 1.0
                            
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
                                    text: "新增商品"
                                    color: "white"
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                            }
                            
                            MouseArea {
                                id: addProductArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    showMessage("新增商品功能界面即将开发", false)
                                }
                            }
                        }
                    }
                }

                // 商品列表主体
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
                                    text: "商品名称"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignLeft
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 100
                                    text: "价格"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 80
                                    text: "库存"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 100
                                    text: "分类"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 120
                                    text: "评分/评价数"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 80
                                    text: "状态"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#2c3e50"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                Text {
                                    Layout.preferredWidth: 140
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
                                id: productListView
                                model: productModel
                                spacing: 12
                                
                                delegate: Rectangle {
                                    width: productListView.width
                                    height: 80
                                    radius: 10
                                    color: "#ffffff"
                                    border.color: "#ffeaa7"
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
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 20
                                        anchors.rightMargin: 20
                                        spacing: 0
                                        
                                        // 商品名称列 - 完全左对齐
                                        Item {
                                            Layout.preferredWidth: 250
                                            Layout.preferredHeight: parent.height
                                            
                                            Row {
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 12
                                                
                                                Rectangle {
                                                    width: 45
                                                    height: 45
                                                    radius: 22.5
                                                    color: getCategoryColor(model.category)
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: getCategoryIcon(model.category)
                                                        font.pixelSize: 16
                                                    }
                                                }
                                                
                                                Column {
                                                    spacing: 3
                                                    
                                                    Text {
                                                        text: model.name
                                                        font.pixelSize: 14
                                                        color: "#2c3e50"
                                                        font.bold: true
                                                        elide: Text.ElideRight
                                                        maximumLineCount: 1
                                                    }
                                                    
                                                    Text {
                                                        text: "分类: " + model.category
                                                        font.pixelSize: 11
                                                        color: "#7f8c8d"
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // 价格列
                                        Item {
                                            Layout.preferredWidth: 100
                                            Layout.preferredHeight: parent.height
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: "¥" + model.price.toFixed(0)
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "#e74c3c"
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }
                                        
                                        // 库存列
                                        Item {
                                            Layout.preferredWidth: 80
                                            Layout.preferredHeight: parent.height
                                            
                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: 50
                                                height: 28
                                                radius: 14
                                                color: getStockColor(model.stock)
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: model.stock
                                                    font.pixelSize: 12
                                                    color: "white"
                                                    font.bold: true
                                                }
                                            }
                                        }
                                        
                                        // 分类列
                                        Item {
                                            Layout.preferredWidth: 100
                                            Layout.preferredHeight: parent.height
                                            
                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: Math.min(categoryLabel.implicitWidth + 16, 80)
                                                height: 28
                                                radius: 14
                                                color: getCategoryColor(model.category)
                                                
                                                Text {
                                                    id: categoryLabel
                                                    anchors.centerIn: parent
                                                    text: model.category
                                                    font.pixelSize: 11
                                                    color: "white"
                                                    font.bold: true
                                                    elide: Text.ElideRight
                                                }
                                            }
                                        }
                                        
                                        // 评分/评价数列
                                        Item {
                                            Layout.preferredWidth: 120
                                            Layout.preferredHeight: parent.height
                                            
                                            Column {
                                                anchors.centerIn: parent
                                                spacing: 2
                                                
                                                RowLayout {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    spacing: 3
                                                    
                                                    Text {
                                                        text: "⭐"
                                                        font.pixelSize: 14
                                                    }
                                                    
                                                    Text {
                                                        text: model.avgRating.toFixed(1)
                                                        font.pixelSize: 13
                                                        font.bold: true
                                                        color: "#f39c12"
                                                    }
                                                }
                                                
                                                Text {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: model.reviewers + " 评价"
                                                    font.pixelSize: 10
                                                    color: "#7f8c8d"
                                                }
                                            }
                                        }
                                        
                                        // 状态列
                                        Item {
                                            Layout.preferredWidth: 80
                                            Layout.preferredHeight: parent.height
                                            
                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: 60
                                                height: 28
                                                radius: 14
                                                color: getStatusColor(model.status)
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: model.status
                                                    font.pixelSize: 11
                                                    color: "white"
                                                    font.bold: true
                                                }
                                            }
                                        }
                                        
                                        // 操作列
                                        Item {
                                            Layout.preferredWidth: 140
                                            Layout.preferredHeight: parent.height
                                            
                                            RowLayout {
                                                anchors.centerIn: parent
                                                spacing: 12
                                                
                                                // 编辑按钮
                                                Rectangle {
                                                    Layout.preferredWidth: 36
                                                    Layout.preferredHeight: 36
                                                    radius: 18
                                                    color: editArea.containsMouse ? "#f39c12" : "#ecf0f1"
                                                    border.color: "#f39c12"
                                                    border.width: 1
                                                    
                                                    scale: editArea.containsMouse ? 1.1 : 1.0
                                                    
                                                    Behavior on color { ColorAnimation { duration: 200 } }
                                                    Behavior on scale { NumberAnimation { duration: 150 } }
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "✏"
                                                        font.pixelSize: 14
                                                        color: editArea.containsMouse ? "white" : "#f39c12"
                                                    }
                                                    
                                                    MouseArea {
                                                        id: editArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            showMessage("编辑商品 " + model.name + " 的信息", false)
                                                        }
                                                    }
                                                    
                                                    ToolTip {
                                                        visible: editArea.containsMouse
                                                        text: "编辑商品"
                                                        delay: 500
                                                    }
                                                }
                                                
                                                // 删除按钮
                                                Rectangle {
                                                    Layout.preferredWidth: 36
                                                    Layout.preferredHeight: 36
                                                    radius: 18
                                                    color: deleteArea.containsMouse ? "#e74c3c" : "#ecf0f1"
                                                    border.color: "#e74c3c"
                                                    border.width: 1
                                                    
                                                    scale: deleteArea.containsMouse ? 1.1 : 1.0
                                                    
                                                    Behavior on color { ColorAnimation { duration: 200 } }
                                                    Behavior on scale { NumberAnimation { duration: 150 } }
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "🗑"
                                                        font.pixelSize: 14
                                                        color: deleteArea.containsMouse ? "white" : "#e74c3c"
                                                    }
                                                    
                                                    MouseArea {
                                                        id: deleteArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            showMessage("确认删除商品 " + model.name + "?", true)
                                                        }
                                                    }
                                                    
                                                    ToolTip {
                                                        visible: deleteArea.containsMouse
                                                        text: "删除商品"
                                                        delay: 500
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
    
    // 辅助函数
    function getCategoryColor(category) {
        switch(category) {
            case "手机": return "#3498db"
            case "电脑": return "#9b59b6"
            case "耳机": return "#e67e22"
            case "平板": return "#2ecc71"
            case "手表": return "#e74c3c"
            default: return "#95a5a6"
        }
    }
    
    function getCategoryIcon(category) {
        switch(category) {
            case "手机": return "📱"
            case "电脑": return "💻"
            case "耳机": return "🎧"
            case "平板": return "📱"
            case "手表": return "⌚"
            default: return "📦"
        }
    }
    
    function getStockColor(stock) {
        if (stock === 0) return "#e74c3c"        // 红色 - 缺货
        if (stock < 20) return "#f39c12"         // 橙色 - 库存低
        if (stock < 50) return "#f1c40f"         // 黄色 - 库存中等
        return "#2ecc71"                         // 绿色 - 库存充足
    }
    
    function getStatusColor(status) {
        switch(status) {
            case "在售": return "#2ecc71"        // 绿色
            case "缺货": return "#e74c3c"        // 红色
            case "下架": return "#95a5a6"        // 灰色
            default: return "#3498db"            // 蓝色
        }
    }
}