import QtQuick 2.12
import QtQuick.Controls.Fusion 2.12
import QtQuick.Layouts 1.12
import StateManager 1.0
import DataManager 1.0

Item {
    id: cartPage
    anchors.fill: parent

    signal backToMainMenuRequested()

    property var stateManager: null
    property string currentUserName: ""
    property real totalPrice: 0
    property int totalQuantity: 0
    property string totalPriceText: "\u00A50.00"

    DataManager {
        id: dataManager
    }

    ListModel {
        id: cartModel
    }

    function refreshCart() {
        console.log("开始刷新购物车数据...")
        
        // 检查 StateManager 是否注入
        if (!cartPage.stateManager) {
            console.log("StateManager 未注入，无法加载购物车")
            // 尝试清空数据显示
            cartModel.clear()
            cartPage.totalPrice = 0
            cartPage.totalQuantity = 0
            cartPage.totalPriceText = cartPage.formatPrice(0)
            cartPage.currentUserName = ""
            return
        }

        // 获取当前用户名
        cartPage.currentUserName = cartPage.stateManager.getCurrentUser()
        console.log("当前用户:", cartPage.currentUserName)
        
        if (!cartPage.currentUserName || cartPage.currentUserName.length === 0) {
            console.log("用户未登录，清空购物车显示")
            cartModel.clear()
            cartPage.totalPrice = 0
            cartPage.totalQuantity = 0
            cartPage.totalPriceText = cartPage.formatPrice(0)
            return
        }

        // 调用 DataManager 获取购物车详情
        var result = dataManager.getShoppingCartDetails(cartPage.currentUserName)
        console.log("购物车数据获取结果:", JSON.stringify(result))
        
        cartModel.clear()

        if (result && result.items && result.items.length > 0) {
            console.log("找到购物车商品:", result.items.length, "个")
            
            for (var i = 0; i < result.items.length; ++i) {
                var item = result.items[i] || {}
                console.log("添加商品:", item.name, "数量:", item.quantity, "单价:", item.unitPrice)
                
                cartModel.append({
                    productId: item.productId || 0,  // 添加商品ID，用于操作
                    name: item.name || "未知商品",
                    quantity: item.quantity || 0,
                    unitPrice: item.unitPrice || 0,
                    subtotal: item.subtotal || 0,
                    displayUnitPrice: cartPage.formatPrice(item.unitPrice || 0),
                    displaySubtotal: cartPage.formatPrice(item.subtotal || 0)
                })
            }
            
            cartPage.totalPrice = result.totalPrice || 0
            cartPage.totalQuantity = result.totalQuantity || 0
            cartPage.totalPriceText = cartPage.formatPrice(cartPage.totalPrice)
            
            console.log("购物车总计: 商品数量", cartPage.totalQuantity, "总价", cartPage.totalPrice)
        } else {
            console.log("购物车为空或无有效数据")
            cartPage.totalPrice = 0
            cartPage.totalQuantity = 0
            cartPage.totalPriceText = cartPage.formatPrice(0)
        }
    }

    function formatPrice(value) {
        return "\u00A5" + Number(value || 0).toFixed(2)
    }

    // 新增：修改商品数量
    function updateQuantity(productId, newQuantity) {
        if (!cartPage.stateManager) {
            console.log("StateManager 未注入，无法修改数量")
            return false
        }
        
        console.log("修改商品数量，ID:", productId, "新数量:", newQuantity)
        
        if (newQuantity <= 0) {
            // 数量为0或负数时删除商品
            return removeItem(productId)
        }
        
        var success = cartPage.stateManager.updateCartQuantity(productId, newQuantity)
        if (success) {
            console.log("商品数量修改成功")
            // 刷新购物车显示
            refreshCart()
            return true
        } else {
            console.log("商品数量修改失败")
            return false
        }
    }

    // 新增：删除商品
    function removeItem(productId) {
        if (!cartPage.stateManager) {
            console.log("StateManager 未注入，无法删除商品")
            return false
        }
        
        console.log("删除购物车商品，ID:", productId)
        
        var success = cartPage.stateManager.removeFromCart(productId)
        if (success) {
            console.log("商品删除成功")
            // 刷新购物车显示
            refreshCart()
            return true
        } else {
            console.log("商品删除失败")
            return false
        }
    }

    // 监听状态管理器的状态变化
    Connections {
        target: cartPage.stateManager
        enabled: cartPage.stateManager !== null

        function onStateChanged() {
            console.log("购物车页面接收到状态变化信号")
            if (!cartPage.stateManager) {
                return
            }
            
            var currentState = cartPage.stateManager.getCurrentState()
            console.log("当前状态:", currentState, "购物车状态:", StateManager.STATE_SHOPPING_CART)
            
            if (currentState === StateManager.STATE_SHOPPING_CART) {
                console.log("状态切换到购物车，刷新数据")
                cartPage.refreshCart()
            }
        }
    }

    // 组件完成时刷新购物车，并添加延时确保状态管理器已注入
    Component.onCompleted: {
        console.log("购物车组件加载完成")
        // 延时调用以确保 stateManager 已经注入
        Qt.callLater(function() {
            console.log("延时刷新购物车, stateManager:", cartPage.stateManager)
            cartPage.refreshCart()
        })
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                color: "#4158d0"; position: 0.0
            }
            GradientStop {
                color: "#c850c0"; position: 1.0
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.92, 1280)
        height: Math.min(parent.height * 0.92, 860)
        radius: 20
        color: "white"
        opacity: 0.98
        border.color: "#e0e0e0"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 60

                Rectangle {
                    id: backButton
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 40
                    radius: 10
                    color: backArea.containsMouse ? "#3498db" : "#2c3e50"

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "\u2190"; color: "white"; font.pixelSize: 16; font.bold: true
                        }
                        Text {
                            text: qsTr("返回"); color: "white"; font.pixelSize: 14; font.bold: true
                        }
                    }

                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: cartPage.backToMainMenuRequested()
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignLeft
                    spacing: 4
                    Text {
                        text: qsTr("🛒 购物车管理")
                        font.pixelSize: 26
                        font.bold: true
                        color: "#2c3e50"
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text {
                        text: cartPage.currentUserName && cartPage.currentUserName.length > 0 ? 
                              qsTr("当前用户: ") + cartPage.currentUserName : 
                              qsTr("未登录用户")
                        font.pixelSize: 13
                        color: "#7f8c8d"
                        horizontalAlignment: Text.AlignLeft
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 2; color: "#ecf0f1"; radius: 1
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 12
                color: "#f8f9fa"
                border.color: "#e0e0e0"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10

                    Text {
                        Layout.preferredWidth: 280
                        Layout.alignment: Qt.AlignLeft
                        text: qsTr("商品名称")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2c3e50"
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text {
                        Layout.preferredWidth: 100
                        Layout.alignment: Qt.AlignLeft
                        text: qsTr("单价")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2c3e50"
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text {
                        Layout.preferredWidth: 150
                        Layout.alignment: Qt.AlignLeft
                        text: qsTr("数量操作")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2c3e50"
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text {
                        Layout.preferredWidth: 100
                        Layout.alignment: Qt.AlignLeft
                        text: qsTr("小计")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2c3e50"
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text {
                        Layout.preferredWidth: 80
                        Layout.alignment: Qt.AlignLeft
                        text: qsTr("操作")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2c3e50"
                        horizontalAlignment: Text.AlignLeft
                    }
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: cartList
                    width: parent.width
                    model: cartModel
                    spacing: 10

                    delegate: Rectangle {
                        width: parent ? parent.width : 0
                        height: 80
                        radius: 12
                        color: "#ffffff"
                        border.color: "#ecf0f1"
                        border.width: 1

                        // 添加轻微的阴影效果
                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: 2
                            anchors.leftMargin: 2
                            color: "#10000000"
                            radius: parent.radius
                            z: -1
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            // 商品名称
                            Text {
                                Layout.preferredWidth: 280
                                Layout.alignment: Qt.AlignLeft
                                text: model.name && model.name.length > 0 ? model.name : qsTr("未知商品")
                                font.pixelSize: 14
                                color: "#2c3e50"
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignLeft
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                            }

                            // 单价
                            Text {
                                Layout.preferredWidth: 100
                                Layout.alignment: Qt.AlignLeft
                                text: model.displayUnitPrice || "\u00A50.00"
                                font.pixelSize: 14
                                color: "#2c3e50"
                                horizontalAlignment: Text.AlignLeft
                            }

                            // 数量操作区域
                            RowLayout {
                                Layout.preferredWidth: 150
                                Layout.alignment: Qt.AlignLeft
                                spacing: 5

                                // 减少数量按钮
                                Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 6
                                    color: decreaseArea.containsMouse ? "#e74c3c" : "#95a5a6"
                                    
                                    scale: decreaseArea.pressed ? 0.95 : 1.0
                                    
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    Behavior on scale { NumberAnimation { duration: 100 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "−"
                                        color: "white"
                                        font.pixelSize: 16
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: decreaseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        onClicked: {
                                            var newQuantity = Math.max(0, model.quantity - 1)
                                            cartPage.updateQuantity(model.productId, newQuantity)
                                        }
                                    }
                                }

                                // 当前数量显示
                                Rectangle {
                                    width: 50
                                    height: 30
                                    radius: 6
                                    color: "#f8f9fa"
                                    border.color: "#dee2e6"
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: model.quantity || 0
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#2c3e50"
                                    }
                                }

                                // 增加数量按钮
                                Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 6
                                    color: increaseArea.containsMouse ? "#27ae60" : "#2ecc71"
                                    
                                    scale: increaseArea.pressed ? 0.95 : 1.0
                                    
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    Behavior on scale { NumberAnimation { duration: 100 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "+"
                                        color: "white"
                                        font.pixelSize: 16
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: increaseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        onClicked: {
                                            var newQuantity = model.quantity + 1
                                            cartPage.updateQuantity(model.productId, newQuantity)
                                        }
                                    }
                                }
                            }

                            // 小计
                            Text {
                                Layout.preferredWidth: 100
                                Layout.alignment: Qt.AlignLeft
                                text: model.displaySubtotal || "\u00A50.00"
                                font.pixelSize: 14
                                color: "#e74c3c"
                                horizontalAlignment: Text.AlignLeft
                                font.bold: true
                            }

                            // 删除按钮 - 修改对齐方式
                            Item {
                                Layout.preferredWidth: 80
                                Layout.fillHeight: true
                                
                                Rectangle {
                                    anchors.left: parent.left  // 改为左对齐
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 70
                                    height: 35
                                    radius: 8
                                    color: deleteArea.containsMouse ? "#c0392b" : "#e74c3c"
                                    
                                    scale: deleteArea.pressed ? 0.95 : 1.0
                                    
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    Behavior on scale { NumberAnimation { duration: 100 } }

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 4

                                        Text {
                                            text: "🗑️"
                                            font.pixelSize: 14
                                        }

                                        Text {
                                            text: "删除"
                                            color: "white"
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }

                                    MouseArea {
                                        id: deleteArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        onClicked: {
                                            // 显示删除确认动画
                                            deleteConfirmAnimation.start()
                                            
                                            // 延迟执行删除操作
                                            deleteTimer.productIdToDelete = model.productId
                                            deleteTimer.start()
                                        }
                                    }

                                    // 删除确认动画
                                    Rectangle {
                                        id: deleteConfirmRect
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: "#ffffff"
                                        opacity: 0
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓"
                                            font.pixelSize: 12
                                            color: "#e74c3c"
                                            font.bold: true
                                        }
                                        
                                        SequentialAnimation {
                                            id: deleteConfirmAnimation
                                            
                                            ParallelAnimation {
                                                NumberAnimation {
                                                    target: deleteConfirmRect
                                                    property: "opacity"
                                                    from: 0; to: 1; duration: 150
                                                }
                                                NumberAnimation {
                                                    target: deleteConfirmRect
                                                    property: "scale"
                                                    from: 0.5; to: 1.2; duration: 150
                                                }
                                            }
                                            
                                            PauseAnimation { duration: 300 }
                                            
                                            ParallelAnimation {
                                                NumberAnimation {
                                                    target: deleteConfirmRect
                                                    property: "opacity"
                                                    to: 0; duration: 150
                                                }
                                                NumberAnimation {
                                                    target: deleteConfirmRect
                                                    property: "scale"
                                                    to: 1.0; duration: 150
                                                }
                                            }
                                        }
                                    }

                                    // 删除延迟定时器
                                    Timer {
                                        id: deleteTimer
                                        interval: 200
                                        repeat: false
                                        property int productIdToDelete: -1
                                        
                                        onTriggered: {
                                            if (productIdToDelete !== -1) {
                                                cartPage.removeItem(productIdToDelete)
                                                productIdToDelete = -1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                radius: 15
                color: "#ffffff"
                border.color: "#ecf0f1"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    ColumnLayout {
                        Layout.alignment: Qt.AlignLeft
                        spacing: 6
                        Text {
                            text: qsTr("商品种类: ") + cartModel.count
                            font.pixelSize: 14
                            color: "#2c3e50"
                            horizontalAlignment: Text.AlignLeft
                        }
                        Text {
                            text: qsTr("商品数量: ") + cartPage.totalQuantity
                            font.pixelSize: 14
                            color: "#2c3e50"
                            horizontalAlignment: Text.AlignLeft
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignLeft
                        spacing: 6
                        Text {
                            text: qsTr("总金额")
                            font.pixelSize: 16
                            font.bold: true
                            color: "#2c3e50"
                            horizontalAlignment: Text.AlignLeft
                        }
                        Text {
                            text: cartPage.totalPriceText
                            font.pixelSize: 28
                            font.bold: true
                            color: "#e74c3c"
                            horizontalAlignment: Text.AlignLeft
                        }
                    }

                    // 新增：清空购物车按钮
                    Rectangle {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 45
                        radius: 10
                        color: clearAllArea.containsMouse ? "#c0392b" : "#e74c3c"
                        visible: cartModel.count > 0
                        
                        scale: clearAllArea.pressed ? 0.98 : 1.0
                        
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "🗑️"
                                font.pixelSize: 16
                            }

                            Text {
                                text: "清空购物车"
                                color: "white"
                                font.pixelSize: 13
                                font.bold: true
                            }
                        }

                        MouseArea {
                            id: clearAllArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            onClicked: {
                                clearAllConfirmDialog.open()
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true; Layout.preferredHeight: 20
            }
        }
        
        // 购物车为空时的提示信息
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 15
            visible: cartModel.count === 0
            
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "🛒"
                font.pixelSize: 48
                color: "#bdc3c7"
            }
            
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("购物车为空")
                font.pixelSize: 20
                color: "#7f8c8d"
                font.bold: true
            }
            
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("快去挑选喜欢的商品吧！")
                font.pixelSize: 16
                color: "#95a5a6"
            }
        }
    }

    // 清空购物车确认对话框
    Rectangle {
        id: clearAllConfirmDialog
        anchors.centerIn: parent
        width: 400
        height: 250
        radius: 15
        color: "white"
        border.color: "#e0e0e0"
        border.width: 2
        visible: false
        z: 1000

        function open() {
            visible = true
            opacity = 1
            scale = 1
        }

        function close() {
            visible = false
        }

        // 背景遮罩
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1000
            color: "#80000000"
            z: -1
            
            MouseArea {
                anchors.fill: parent
                onClicked: clearAllConfirmDialog.close()
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "⚠️ 确认清空购物车"
                font.pixelSize: 18
                font.bold: true
                color: "#e74c3c"
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                text: "此操作将删除购物车中的所有商品，\n确定要继续吗？"
                font.pixelSize: 14
                color: "#2c3e50"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    radius: 10
                    color: cancelArea.containsMouse ? "#95a5a6" : "#bdc3c7"

                    Text {
                        anchors.centerIn: parent
                        text: "取消"
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        id: cancelArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: clearAllConfirmDialog.close()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    radius: 10
                    color: confirmArea.containsMouse ? "#c0392b" : "#e74c3c"

                    Text {
                        anchors.centerIn: parent
                        text: "确认清空"
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        id: confirmArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            clearAllConfirmDialog.close()
                            clearAllItems()
                        }
                    }
                }
            }
        }
    }

    // 清空所有商品的函数
    function clearAllItems() {
        if (!cartPage.stateManager || cartModel.count === 0) {
            return
        }

        console.log("开始清空购物车，共", cartModel.count, "个商品")

        // 逐个删除所有商品
        for (var i = 0; i < cartModel.count; i++) {
            var item = cartModel.get(i)
            if (item && item.productId) {
                cartPage.stateManager.removeFromCart(item.productId)
            }
        }

        // 刷新购物车显示
        refreshCart()
        
        console.log("购物车清空完成")
    }
}