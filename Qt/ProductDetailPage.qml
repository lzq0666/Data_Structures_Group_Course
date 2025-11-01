import QtQuick 2.12
import QtQuick.Controls.Fusion 2.12
import QtQuick.Layouts 1.12
import StateManager 1.0
import DataManager 1.0

Item {
    id: productDetailPage
    anchors.fill: parent
    
    // 与主窗口通信的信号
    signal backToBrowseRequested()
    signal addToCartRequested(int productId, string productName, real price, int quantity)
    
    // StateManager 引用 - 修改：在组件完成后自动尝试从父窗口获取 stateManager
    property var stateManager: null
    
    // 当前商品信息
    property int currentProductId: -1
    property var currentProduct: null
    
    // DataManager实例
    DataManager {
        id: dataManager
    }
    
    // 购买数量
    property int selectedQuantity: 1
    
    // 评价相关属性
    property int selectedRating: -1
    
    // 使用与主界面相同的渐变背景
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
    }
    
    // 主容器
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.95, 1400)
        height: Math.min(parent.height * 0.95, 900)
        radius: 20
        color: "white"
        opacity: 0.98
        border.color: "#e0e0e0"
        border.width: 1
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20
            
            // 顶部导航栏
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                radius: 15
                color: "#ffffff"
                border.color: "#ecf0f1"
                border.width: 2
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 25
                    
                    // 返回按钮
                    Rectangle {
                        id: backButton
                        Layout.preferredWidth: 110
                        Layout.preferredHeight: 40
                        radius: 10
                        color: backArea.containsMouse ? "#3498db" : "#2c3e50"
                        
                        scale: backArea.containsMouse ? 1.03 : 1.0
                        
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            
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
                            onClicked: backToBrowseRequested()
                        }
                    }
                    
                    // 标题区域
                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                        text: "📋 商品详情"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#2c3e50"
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Item {
                        Layout.preferredWidth: 110
                    }
                }
            }
            
            // 商品详情内容区域
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
                
                // 修改：使用 ColumnLayout 作为 ScrollView 的内容，而不是 Rectangle
                ColumnLayout {
                    id: contentColumn
                    width: parent.width * 0.95  // 稍微减少宽度以适应滚动条
                    spacing: 25
                    
                    // 主要产品信息区域
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 400
                        radius: 15
                        color: "#ffffff"
                        border.color: "#ecf0f1"
                        border.width: 2
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 30
                            spacing: 40
                            
                            // 左侧商品图片区域
                            Rectangle {
                                Layout.preferredWidth: 350
                                Layout.fillHeight: true
                                radius: 12
                                color: "#f8f9fa"
                                border.color: "#e9ecef"
                                border.width: 1
                                
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 15
                                    
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: getCategoryIcon(currentProduct ? currentProduct.category : "")
                                        font.pixelSize: 80
                                        color: getCategoryColor(currentProduct ? currentProduct.category : "")
                                    }
                                    
                                    Rectangle {
                                        Layout.preferredWidth: 120
                                        Layout.preferredHeight: 30
                                        Layout.alignment: Qt.AlignHCenter
                                        radius: 15
                                        color: getCategoryColor(currentProduct ? currentProduct.category : "")
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: currentProduct ? currentProduct.category : "未分类"
                                            font.pixelSize: 14
                                            color: "white"
                                            font.bold: true
                                        }
                                    }
                                }
                            }
                            
                            // 右侧商品信息
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 20
                                
                                // 商品名称
                                Text {
                                    Layout.fillWidth: true
                                    text: currentProduct ? currentProduct.name : "商品名称"
                                    font.pixelSize: 28
                                    font.bold: true
                                    color: "#2c3e50"
                                    wrapMode: Text.WordWrap
                                }
                                
                                // 价格显示
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    radius: 10
                                    color: "#fee2e2"
                                    border.color: "#fecaca"
                                    border.width: 1
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 15
                                        
                                        Text {
                                            text: "💰"
                                            font.pixelSize: 24
                                        }
                                        
                                        Text {
                                            text: "¥" + (currentProduct ? currentProduct.price.toFixed(2) : "0.00")
                                            font.pixelSize: 32
                                            font.bold: true
                                            color: "#e74c3c"
                                        }
                                        
                                        Item { Layout.fillWidth: true }
                                    }
                                }
                                
                                // 评分和库存信息
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 20
                                    
                                    // 评分区域
                                    Rectangle {
                                        Layout.preferredWidth: 180
                                        Layout.preferredHeight: 50
                                        radius: 10
                                        color: "#fef3c7"
                                        border.color: "#fde68a"
                                        border.width: 1
                                        
                                        RowLayout {
                                            anchors.centerIn: parent
                                            spacing: 8
                                            
                                            Text {
                                                text: "⭐"
                                                font.pixelSize: 20
                                            }
                                            
                                            Text {
                                                id: productRatingText
                                                text: (currentProduct ? currentProduct.avgRating.toFixed(1) : "0.0")
                                                font.pixelSize: 18
                                                font.bold: true
                                                color: "#f39c12"
                                            }
                                            
                                            Text {
                                                id: productReviewersText
                                                text: "(" + (currentProduct ? currentProduct.reviewers : 0) + "评价)"
                                                font.pixelSize: 12
                                                color: "#8b7355"
                                            }
                                        }
                                    }
                                    
                                    // 库存区域
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 50
                                        radius: 10
                                        color: (currentProduct && currentProduct.stock > 0) ? "#dcfce7" : "#fee2e2"
                                        border.color: (currentProduct && currentProduct.stock > 0) ? "#bbf7d0" : "#fecaca"
                                        border.width: 1
                                        
                                        RowLayout {
                                            anchors.centerIn: parent
                                            spacing: 8
                                            
                                            Text {
                                                text: (currentProduct && currentProduct.stock > 0) ? "📦" : "❌"
                                                font.pixelSize: 18
                                            }
                                            
                                            Text {
                                                text: "库存: " + (currentProduct ? currentProduct.stock : 0) + " 件"
                                                font.pixelSize: 16
                                                font.bold: true
                                                color: (currentProduct && currentProduct.stock > 0) ? "#16a34a" : "#dc2626"
                                            }
                                        }
                                    }
                                }
                                
                                Item { Layout.fillHeight: true }
                            }
                        }
                    }
                    
                    // 购买操作区域
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        radius: 15
                        color: "#ffffff"
                        border.color: "#ecf0f1"
                        border.width: 2
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 30
                            spacing: 20
                            
                            Text {
                                text: "🛒 购买选项"
                                font.pixelSize: 20
                                font.bold: true
                                color: "#2c3e50"
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 30
                                
                                // 数量选择器
                                ColumnLayout {
                                    spacing: 8
                                    
                                    Text {
                                        text: "选择数量:"
                                        font.pixelSize: 14
                                        color: "#555"
                                    }
                                    
                                    RowLayout {
                                        spacing: 8
                                        
                                        Rectangle {
                                            width: 40
                                            height: 40
                                            radius: 8
                                            color: decreaseArea.containsMouse ? "#e74c3c" : "#95a5a6"
                                            
                                            scale: decreaseArea.pressed ? 0.95 : 1.0
                                            
                                            Behavior on color { ColorAnimation { duration: 200 } }
                                            Behavior on scale { NumberAnimation { duration: 100 } }
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: "−"
                                                color: "white"
                                                font.pixelSize: 20
                                                font.bold: true
                                            }
                                            
                                            MouseArea {
                                                id: decreaseArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                enabled: selectedQuantity > 1
                                                
                                                onClicked: {
                                                    if (selectedQuantity > 1) {
                                                        selectedQuantity--
                                                    }
                                                }
                                            }
                                        }
                                        
                                        Rectangle {
                                            width: 60
                                            height: 40
                                            radius: 8
                                            color: "#f8f9fa"
                                            border.color: "#dee2e6"
                                            border.width: 1
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: selectedQuantity.toString()
                                                font.pixelSize: 16
                                                font.bold: true
                                                color: "#2c3e50"
                                            }
                                        }
                                        
                                        Rectangle {
                                            width: 40
                                            height: 40
                                            radius: 8
                                            color: increaseArea.containsMouse ? "#27ae60" : "#2ecc71"
                                            
                                            scale: increaseArea.pressed ? 0.95 : 1.0
                                            
                                            Behavior on color { ColorAnimation { duration: 200 } }
                                            Behavior on scale { NumberAnimation { duration: 100 } }
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: "+"
                                                color: "white"
                                                font.pixelSize: 20
                                                font.bold: true
                                            }
                                            
                                            MouseArea {
                                                id: increaseArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                enabled: currentProduct && selectedQuantity < currentProduct.stock
                                                
                                                onClicked: {
                                                    if (currentProduct && selectedQuantity < currentProduct.stock) {
                                                        selectedQuantity++
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // 总价显示
                                ColumnLayout {
                                    spacing: 8
                                    
                                    Text {
                                        text: "小计:"
                                        font.pixelSize: 14
                                        color: "#555"
                                    }
                                    
                                    Text {
                                        text: "¥" + (currentProduct ? (currentProduct.price * selectedQuantity).toFixed(2) : "0.00")
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "#e74c3c"
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                // 加入购物车按钮
                                Rectangle {
                                    Layout.preferredWidth: 200
                                    Layout.preferredHeight: 50
                                    radius: 12
                                    color: addToCartArea.containsMouse ? "#27ae60" : "#2ecc71"
                                    
                                    scale: addToCartArea.pressed ? 0.98 : 1.0
                                    
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    Behavior on scale { NumberAnimation { duration: 100 } }
                                    
                                    enabled: currentProduct && currentProduct.stock > 0
                                    opacity: enabled ? 1.0 : 0.5
                                    
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 8
                                        
                                        Text {
                                            text: "🛒"
                                            font.pixelSize: 18
                                        }
                                        
                                        Text {
                                            text: "加入购物车"
                                            color: "white"
                                            font.pixelSize: 16
                                            font.bold: true
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: addToCartArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        enabled: parent.enabled
                                        
                                        onClicked: {
                                            if (currentProduct) {
                                                console.log("添加到购物车:", currentProduct.name, "数量:", selectedQuantity)
                                                addToCartRequested(currentProduct.productId, currentProduct.name, currentProduct.price, selectedQuantity)
                                                
                                                // 显示成功反馈
                                                successFeedback.start()
                                            }
                                        }
                                    }
                                    
                                    // 成功反馈动画
                                    Rectangle {
                                        id: successRect
                                        anchors.centerIn: parent
                                        width: 40
                                        height: 40
                                        radius: 20
                                        color: "#ffffff"
                                        opacity: 0
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓"
                                            font.pixelSize: 20
                                            color: "#2ecc71"
                                            font.bold: true
                                        }
                                        
                                        SequentialAnimation {
                                            id: successFeedback
                                            
                                            ParallelAnimation {
                                                NumberAnimation {
                                                    target: successRect
                                                    property: "opacity"
                                                    from: 0; to: 1; duration: 200
                                                }
                                                NumberAnimation {
                                                    target: successRect
                                                    property: "scale"
                                                    from: 0.5; to: 1.2; duration: 200
                                                }
                                            }
                                            
                                            PauseAnimation { duration: 500 }
                                            
                                            ParallelAnimation {
                                                NumberAnimation {
                                                    target: successRect
                                                    property: "opacity"
                                                    to: 0; duration: 200
                                                }
                                                NumberAnimation {
                                                    target: successRect
                                                    property: "scale"
                                                    to: 1.0; duration: 200
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // 商品评价区域 - 独立的区域
                    Rectangle {
                        id: ratingSection
                        Layout.fillWidth: true
                        implicitHeight: ratingContent.implicitHeight + ratingContent.anchors.margins * 2
                        Layout.preferredHeight: implicitHeight
                        radius: 15
                        color: "#ffffff"
                        border.color: "#ecf0f1"
                        border.width: 2
                        
                        ColumnLayout {
                            id: ratingContent
                            anchors.fill: parent
                            anchors.margins: 30
                            spacing: 15
                            
                            Text {
                                text: "⭐ 商品评价"
                                font.pixelSize: 20
                                font.bold: true
                                color: "#2c3e50"
                            }
                            
                            // 调试信息 - 显示当前状态
                            Text {
                                text: "调试信息: " + (stateManager ? ("已登录: " + stateManager.isLoggedIn() + ", 用户: " + stateManager.getCurrentUsername()) : "stateManager 为 null")
                                font.pixelSize: 12
                                color: "#666"
                                visible: true  // 临时显示用于调试
                            }
                            
                            // 登录状态提示
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                radius: 8
                                color: (stateManager && stateManager.isLoggedIn()) ? "#d1fae5" : "#fef3c7"
                                border.color: (stateManager && stateManager.isLoggedIn()) ? "#a7f3d0" : "#fde68a"
                                border.width: 1
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 8
                                    
                                    Text {
                                        text: (stateManager && stateManager.isLoggedIn()) ? "✓" : "⚠"
                                        font.pixelSize: 16
                                        color: (stateManager && stateManager.isLoggedIn()) ? "#16a34a" : "#f59e0b"
                                    }
                                    
                                    Text {
                                        text: (stateManager && stateManager.isLoggedIn()) ? 
                                              "已登录，可以评价商品" : "请先登录后再评价商品"
                                        font.pixelSize: 14
                                        color: (stateManager && stateManager.isLoggedIn()) ? "#16a34a" : "#f59e0b"
                                    }
                                    
                                    Item { Layout.fillWidth: true }
                                }
                            }
                            
                            // 当前用户评分显示
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 15
                                visible: stateManager && stateManager.isLoggedIn()
                                
                                Text {
                                    text: "我的评分:"
                                    font.pixelSize: 14
                                    color: "#555"
                                }
                                
                                Text {
                                    id: userRatingText
                                    text: getCurrentUserRating()
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#f39c12"
                                }
                                
                                Item { Layout.fillWidth: true }
                            }
                            
                            // 评分选择器
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                visible: stateManager && stateManager.isLoggedIn()
                                
                                Text {
                                    text: "选择评分 (1-5分):"
                                    font.pixelSize: 14
                                    color: "#555"
                                }
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    
                                    Repeater {
                                        model: 5
                                        
                                        Rectangle {
                                            Layout.preferredWidth: 45
                                            Layout.preferredHeight: 45
                                            radius: 8
                          color: ratingArea.containsMouse ? "#3498db" : 
                              (index + 1 <= selectedRating ? "#f39c12" : "#ecf0f1")
                                            border.color: "#bdc3c7"
                                            border.width: 1
                                            
                                            scale: ratingArea.containsMouse ? 1.1 : 1.0
                                            
                                            Behavior on color { ColorAnimation { duration: 200 } }
                                            Behavior on scale { NumberAnimation { duration: 150 } }
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: index + 1
                                                font.pixelSize: 16
                                                font.bold: true
                                                color: index + 1 <= selectedRating ? "white" : "#7f8c8d"
                                            }
                                            
                                            MouseArea {
                                                id: ratingArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    selectedRating = index + 1
                                                    console.log("选择评分:", selectedRating)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Item { Layout.fillWidth: true }

                                    Rectangle {
                                        Layout.preferredWidth: 180
                                        Layout.preferredHeight: 45
                                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                                        radius: 10
                                        color: submitRatingArea.containsMouse ? "#27ae60" : "#2ecc71"

                                        scale: submitRatingArea.pressed ? 0.98 : 1.0

                                        Behavior on color { ColorAnimation { duration: 200 } }
                                        Behavior on scale { NumberAnimation { duration: 100 } }

                                        enabled: selectedRating >= 1 && stateManager && stateManager.isLoggedIn()
                                        opacity: enabled ? 1.0 : 0.5

                                        RowLayout {
                                            anchors.centerIn: parent
                                            spacing: 8
                                            
                                            Text {
                                                text: "⭐"
                                                font.pixelSize: 16
                                            }
                                            
                                            Text {
                                                text: "提交评价"
                                                color: "white"
                                                font.pixelSize: 14
                                                font.bold: true
                                            }
                                        }

                                        MouseArea {
                                            id: submitRatingArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            enabled: parent.enabled
                                            
                                            onClicked: {
                                                if (currentProduct && stateManager) {
                                                    var currentUser = stateManager.getCurrentUsername()
                                                    if (currentUser) {
                                                        console.log("开始提交评价:")
                                                        console.log("- 商品:", currentProduct.name)
                                                        console.log("- 用户:", currentUser)
                                                        console.log("- 评分:", selectedRating)
                                                    
                                                        // 使用 StateManager 的评价方法
                                                        var success = stateManager.rateProduct(currentProduct.productId, selectedRating)
                                                    
                                                        if (success) {
                                                            console.log("评价提交成功!")
                                                    
                                                            // 重新获取更新后的商品数据
                                                            refreshProductData()
                                                    
                                                            // 显示成功反馈
                                                            ratingSuccessFeedback.start()
                                                    
                                                            // 更新用户评分显示
                                                            updateUserRatingDisplay()
                                                    
                                                        } else {
                                                            console.log("评价提交失败")
                                                        }
                                                    } else {
                                                        console.log("无法获取当前用户名")
                                                    }
                                                } else {
                                                    console.log("缺少必要数据 - currentProduct:", !!currentProduct, "stateManager:", !!stateManager)
                                                }
                                            }
                                        }

                                        // 评价成功反馈动画
                                        Rectangle {
                                            id: ratingSuccessRect
                                            anchors.centerIn: parent
                                            width: 40
                                            height: 40
                                            radius: 20
                                            color: "#ffffff"
                                            opacity: 0
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: "✓"
                                                font.pixelSize: 20
                                                color: "#2ecc71"
                                                font.bold: true
                                            }
                                            
                                            SequentialAnimation {
                                                id: ratingSuccessFeedback
                                            
                                                ParallelAnimation {
                                                    NumberAnimation {
                                                        target: ratingSuccessRect
                                                        property: "opacity"
                                                        from: 0; to: 1; duration: 200
                                                    }
                                                    NumberAnimation {
                                                        target: ratingSuccessRect
                                                        property: "scale"
                                                        from: 0.5; to: 1.2; duration: 200
                                                    }
                                                }
                                            
                                                PauseAnimation { duration: 800 }
                                            
                                                ParallelAnimation {
                                                    NumberAnimation {
                                                        target: ratingSuccessRect
                                                        property: "opacity"
                                                        to: 0; duration: 200
                                                    }
                                                    NumberAnimation {
                                                        target: ratingSuccessRect
                                                        property: "scale"
                                                        to: 1.0; duration: 200
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Item { Layout.fillHeight: true }  // 占位符，确保布局正确
                        }
                    }
                }
            }
        }
    }
    
    // 工具函数
    function getCategoryIcon(category) {
        switch(category) {
            case "食品":
                return "🍎"
            case "日用品":
                return "🧴"
            case "电器":
                return "🔌"
            case "数码产品":
                return "📱"
            case "服装":
                return "👗"
            case "酒水":
                return "🍷"
            default: return "📦"
        }
    }
    
    function getCategoryColor(category) {
        switch(category) {
            case "食品":
                return "#e74c3c"
            case "日用品":
                return "#9b59b6"
            case "电器":
                return "#f39c12"
            case "数码产品":
                return "#2ecc71"
            case "服装":
                return "#34495e"
            case "酒水":
                return "#3498db"
            default:
                return "#95a5a6"
        }
    }
    
    // 获取当前用户对该商品的评分
    function getCurrentUserRating() {
        if (!stateManager || !stateManager.isLoggedIn() || !currentProduct) {
            return "未登录"
        }
        
        var userRating = stateManager.getUserProductRating(currentProduct.productId)
        if (userRating === -1) {
            return "暂无评分"
        } else {
            selectedRating = userRating  // 设置当前选择的评分
            return userRating + "分"
        }
    }
    
    // 刷新商品数据
    function refreshProductData() {
        if (!currentProduct) return
        
        // 重新从 DataManager 获取商品数据
        var updatedProduct = dataManager.findProduct(currentProduct.productId)
        if (updatedProduct && updatedProduct.productId) {
            console.log("刷新商品数据:")
            console.log("- 旧评分:", currentProduct.avgRating, "新评分:", updatedProduct.avgRating)
            console.log("- 旧评价数:", currentProduct.reviewers, "新评价数:", updatedProduct.reviewers)
            
            // 更新商品信息
            currentProduct.avgRating = updatedProduct.avgRating
            currentProduct.reviewers = updatedProduct.reviewers
            
            // 更新显示
            productRatingText.text = currentProduct.avgRating.toFixed(1)
            productReviewersText.text = "(" + currentProduct.reviewers + "评价)"
        }
    }
    
    // 更新用户评分显示
    function updateUserRatingDisplay() {
        userRatingText.text = getCurrentUserRating()
    }

    // 设置当前商品 - 同时记录浏览历史并保存
    function setCurrentProduct(productId) {
        console.log("设置当前商品ID:", productId)
        currentProductId = productId
        
        // 使用DataManager查找商品
        currentProduct = dataManager.findProduct(productId)
        
        if (currentProduct) {
            console.log("找到商品:", currentProduct.name, "价格:", currentProduct.price)
            console.log("商品评分:", currentProduct.avgRating, "评价人数:", currentProduct.reviewers)
            
            selectedQuantity = 1  // 重置数量选择
            selectedRating = -1   // 重置评分选择

            // 添加浏览历史，并立即保存
            if (stateManager && stateManager.getCurrentUsername) {
                var currentUser = stateManager.getCurrentUsername()
                if (currentUser) {
                    var added = dataManager.addViewHistory(currentUser, productId)
                    if (added) {
                        var saved = dataManager.saveUsersToJson()
                        console.log("浏览历史记录", added ? "成功" : "失败", ", 保存到文件", saved ? "成功" : "失败")
                    } else {
                        console.warn("添加浏览历史失败，可能用户或商品不存在")
                    }
                }
            }
            
            // 初始化用户评分显示
            updateUserRatingDisplay()
        } else {
            console.error("未找到商品ID:", productId)
        }
    }
    
    // 修复：在组件完成后确保获取 stateManager 引用
    Component.onCompleted: {
        console.log("商品详情页面初始化完成")
        
        // 如果 stateManager 仍然为 null，尝试从父级获取
        if (stateManager === null) {
            console.log("stateManager 为 null，尝试延迟获取...")
            // 使用定时器延迟获取，给主窗口时间设置引用
            delayedStateManagerCheck.start()
        } else {
            console.log("stateManager 已设置:", stateManager)
            logStateManagerInfo()
        }
    }
    
    // 添加定时器来延迟检查 stateManager
    Timer {
        id: delayedStateManagerCheck
        interval: 100  // 延迟100毫秒
        repeat: false
        onTriggered: {
            console.log("延迟检查 stateManager:", stateManager)
            if (stateManager) {
                logStateManagerInfo()
            } else {
                console.log("stateManager 仍为 null - 这可能是问题所在")
            }
        }
    }
    
    // 记录 stateManager 信息的函数
    function logStateManagerInfo() {
        if (stateManager) {
            console.log("stateManager.isLoggedIn:", stateManager.isLoggedIn())
            console.log("当前用户:", stateManager.getCurrentUsername())
        }
    }
}