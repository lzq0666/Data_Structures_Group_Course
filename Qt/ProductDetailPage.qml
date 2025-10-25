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
    
    // StateManager 引用
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
    
    // 使用与主界面相同的渐变背景
    Rectangle {
        anchors.fill: parent
        
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                color: "#4158d0"
                position: 0.0
            }
            GradientStop {
                color: "#c850c0"
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
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                        spacing: 4
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "📋 商品详情"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#2c3e50"
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "详细了解您感兴趣的商品"
                            font.pixelSize: 13
                            color: "#7f8c8d"
                        }
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
                
                Rectangle {
                    width: productDetailPage.width * 0.85
                    height: Math.max(800, contentColumn.implicitHeight + 40)
                    color: "transparent"
                    
                    ColumnLayout {
                        id: contentColumn
                        width: parent.width
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
                                                    text: (currentProduct ? currentProduct.avgRating.toFixed(1) : "0.0")
                                                    font.pixelSize: 18
                                                    font.bold: true
                                                    color: "#f39c12"
                                                }
                                                
                                                Text {
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
                        
                        // 商品详细描述区域（可扩展）
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 150
                            radius: 15
                            color: "#ffffff"
                            border.color: "#ecf0f1"
                            border.width: 2
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 30
                                spacing: 15
                                
                                Text {
                                    text: "📄 商品描述"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "#2c3e50"
                                }
                                
                                Text {
                                    Layout.fillWidth: true
                                    text: getProductDescription(currentProduct)
                                    font.pixelSize: 14
                                    color: "#555"
                                    wrapMode: Text.WordWrap
                                }
                            }
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
    
    function getProductDescription(product) {
        if (!product) return "暂无商品描述信息。"
        
        var descriptions = {
            "iPhone 15 Pro": "全新iPhone 15 Pro，搭载A17 Pro芯片，钛金属机身设计，Pro级摄像头系统，支持USB-C接口。",
            "小米14 Ultra": "小米14 Ultra旗舰手机，搭载骁龙8 Gen 3处理器，徕卡专业影像系统，2K曲面屏。",
            "华为Mate60 Pro": "华为Mate60 Pro，麒麟9000s芯片，卫星通话功能，50MP超感知摄像头。",
            "OPPO Find X7": "OPPO Find X7，天玑9300处理器，哈苏影像系统，120Hz AMOLED显示屏。",
            "MacBook Pro M3": "全新MacBook Pro，搭载M3芯片，14英寸Liquid Retina XDR显示屏，专业级性能。",
            "ThinkPad X1 Carbon": "ThinkPad X1 Carbon商务笔记本，英特尔第13代处理器，碳纤维机身，14英寸2.8K屏幕。",
            "Surface Laptop 5": "微软Surface Laptop 5，第12代英特尔处理器，13.5英寸PixelSense触摸屏。",
            "华为MateBook X Pro": "华为MateBook X Pro，第12代英特尔处理器，3K LTPS触控屏，超薄设计。",
            "AirPods Pro": "Apple AirPods Pro，主动降噪，空间音频，H2芯片，MagSafe充电盒。",
            "Sony WH-1000XM5": "索尼WH-1000XM5头戴式耳机，业界领先降噪技术，30小时续航。",
            "Bose QC45": "Bose QuietComfort 45，舒适降噪耳机，24小时电池续航，优质音质。",
            "森海塞尔 HD660S": "森海塞尔HD660S开放式耳机，专业监听级音质，适合音乐制作和欣赏。"
        }
        
        return descriptions[product.name] || "这是一款优质的" + product.category + "产品，具有出色的性能和设计。"
    }
    
    // 设置当前商品 - 修正版本，确保保存浏览历史
    function setCurrentProduct(productId) {
        console.log("设置当前商品ID:", productId)
        currentProductId = productId
        
        // 使用DataManager查找商品
        currentProduct = dataManager.findProduct(productId)
        
        if (currentProduct) {
            console.log("找到商品:", currentProduct.name, "价格:", currentProduct.price)
            selectedQuantity = 1  // 重置数量选择
            
            // 添加浏览历史
            if (stateManager && stateManager.getCurrentUsername) {
                var currentUser = stateManager.getCurrentUsername()
                if (currentUser) {
                    console.log("正在为用户添加浏览历史:", currentUser, "商品ID:", productId)
                    var success = dataManager.addViewHistory(currentUser, productId)
                    if (success) {
                        console.log("浏览历史添加成功")
                        // 重要：保存用户数据到JSON文件
                        var saveSuccess = dataManager.saveUsersToJson()
                        if (saveSuccess) {
                            console.log("用户数据（包含浏览历史）已保存到文件")
                        } else {
                            console.error("保存用户数据失败")
                        }
                    } else {
                        console.error("添加浏览历史失败")
                    }
                }
            }
        } else {
            console.error("未找到商品ID:", productId)
        }
    }
    
    Component.onCompleted: {
        console.log("商品详情页面初始化完成")
    }
}