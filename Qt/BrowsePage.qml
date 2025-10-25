import QtQuick 2.12
import QtQuick.Controls.Fusion 2.12
import QtQuick.Layouts 1.12
import StateManager 1.0
import DataManager 1.0

Item {
    id: browsePage
    anchors.fill: parent
    
    // 与主窗口通信的信号
    signal backToMainMenuRequested()
    signal addToCartRequested(int productId, string productName, real price, int quantity)
    signal showProductDetailRequested(int productId)
    
    // StateManager 引用
    property var stateManager: null
    
    // DataManager实例 - 用于商品数据操作
    DataManager {
        id: dataManager
    }
    
    // 商品模型 - 用于显示商品数据
    ListModel {
        id: productModel
    }
    
    // 搜索和分类相关属性（暂时不实现功能）
    property string currentSearchText: ""
    property string currentCategory: "全部"
    
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
    
    // 主容器 - 与其他界面保持一致的设计
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.98, 1600)
        height: Math.min(parent.height * 0.98, 1000)
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
                Layout.preferredHeight: 75
                radius: 15
                color: "#ffffff"
                border.color: "#ecf0f1"
                border.width: 2
                
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
                            onClicked: backToMainMenuRequested()
                        }
                    }
                    
                    // 标题区域
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                        spacing: 4
                        
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 8
                            
                            Text {
                                text: "🛍️"
                                font.pixelSize: 24
                            }
                            
                            Text {
                                text: "商品浏览"
                                font.pixelSize: 24
                                font.bold: true
                                color: "#2c3e50"
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "发现您喜欢的商品"
                            font.pixelSize: 13
                            color: "#7f8c8d"
                        }
                    }

                    // TODO：搜索框（暂时不实现搜索功能）
                    Rectangle {
                        Layout.preferredWidth: 280
                        Layout.preferredHeight: 40
                        radius: 10
                        color: "#ffffff"
                        border.color: searchField.activeFocus ? "#3498db" : "#ecf0f1"
                        border.width: searchField.activeFocus ? 2 : 1
                        
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            
                            Text {
                                text: "🔍"
                                font.pixelSize: 16
                                color: "#3498db"
                            }
                            
                            TextField {
                                id: searchField
                                Layout.fillWidth: true
                                placeholderText: "搜索您想要的商品... (功能暂未开放)"
                                font.pixelSize: 13
                                color: "#2c3e50"
                                placeholderTextColor: "#bdc3c7"
                                background: Item {}
                                verticalAlignment: TextInput.AlignVCenter
                                enabled: false  // 暂时禁用搜索功能
                                
                                onTextChanged: {
                                    currentSearchText = text
                                    console.log("搜索文本变更:", text, "- 搜索功能暂未实现")
                                }
                            }
                        }
                    }
                }
            }
            
            // 中间内容区域
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 20

                // TODO：左侧分类面板（暂时不实现筛选功能）
                Rectangle {
                    Layout.preferredWidth: 220
                    Layout.fillHeight: true
                    radius: 15
                    color: "#ffffff"
                    border.color: "#ecf0f1"
                    border.width: 2
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 2
                        anchors.leftMargin: 2
                        color: "#08000000"
                        radius: parent.radius
                        z: -1
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15
                        
                        // 分类标题
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 8
                                
                                Rectangle {
                                    Layout.preferredWidth: 35
                                    Layout.preferredHeight: 35
                                    radius: 17
                                    color: "#e74c3c"
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "📂"
                                        font.pixelSize: 18
                                    }
                                }
                                
                                Text {
                                    text: "商品分类"
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "#2c3e50"
                                }
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 2
                                Layout.leftMargin: 20
                                Layout.rightMargin: 20
                                radius: 1
                                color: "#e74c3c"
                            }
                        }
                        
                        ButtonGroup { id: categoryGroup }

                        // TODO：分类按钮（暂时不实现筛选功能）
                        Repeater {
                            model: [
                                {text: "全部", icon: "🏪", color: "#3498db"},
                                {text: "手机", icon: "📱", color: "#e74c3c"},
                                {text: "电脑", icon: "💻", color: "#9b59b6"},
                                {text: "耳机", icon: "🎧", color: "#f39c12"},
                                {text: "平板", icon: "📲", color: "#2ecc71"},
                                {text: "手表", icon: "⌚", color: "#34495e"}
                            ]
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 10
                                
                                property bool isSelected: categoryBtn.checked
                                
                                color: isSelected ? modelData.color : "#ffffff"
                                border.color: isSelected ? modelData.color : "#ecf0f1"
                                border.width: 2
                                
                                scale: categoryArea.containsMouse ? 1.02 : 1.0
                                
                                Behavior on color { ColorAnimation { duration: 200 } }
                                Behavior on scale { NumberAnimation { duration: 150 } }
                                
                                RadioButton {
                                    id: categoryBtn
                                    anchors.fill: parent
                                    text: modelData.text
                                    checked: index === 0
                                    ButtonGroup.group: categoryGroup
                                    enabled: false  // 暂时禁用分类功能
                                    
                                    indicator: Item {}
                                    
                                    contentItem: RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 10
                                        
                                        Text {
                                            text: modelData.icon
                                            font.pixelSize: 18
                                        }
                                        
                                        Text {
                                            text: categoryBtn.text
                                            font.pixelSize: 15
                                            font.bold: categoryBtn.checked
                                            color: categoryBtn.checked ? "white" : "#2c3e50"
                                        }
                                    }
                                    
                                    onCheckedChanged: {
                                        if (checked) {
                                            currentCategory = text
                                            console.log("分类选择:", text, "- 筛选功能暂未实现")
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    id: categoryArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    enabled: false  // 暂时禁用分类功能
                                    onClicked: categoryBtn.checked = true
                                }
                            }
                        }
                        
                        Item { Layout.fillHeight: true }
                    }
                }
                
                // 右侧商品展示区域
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 15
                    color: "#ffffff"
                    border.color: "#ecf0f1"
                    border.width: 2
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 2
                        anchors.leftMargin: 2
                        color: "#08000000"
                        radius: parent.radius
                        z: -1
                    }
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15
                        
                        // 商品区域标题 
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Rectangle {
                                Layout.preferredWidth: 35
                                Layout.preferredHeight: 35
                                radius: 17
                                color: "#f39c12"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "🎁"
                                    font.pixelSize: 18
                                }
                            }
                            
                            ColumnLayout {
                                spacing: 2
                                
                                Text {
                                    text: "精选商品"
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "#2c3e50"
                                }
                                
                                Text {
                                    text: "共 " + productModel.count + " 件商品"
                                    font.pixelSize: 13
                                    color: "#7f8c8d"
                                }
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                        }
                        
                        // 商品网格
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
                            
                            GridView {
                                id: productGrid
                                
                                cellWidth: 300
                                cellHeight: 400
                                model: productModel
                                
                                delegate: Item {
                                    width: productGrid.cellWidth - 12
                                    height: productGrid.cellHeight - 12
                                    
                                    Rectangle {
                                        id: productCard
                                        anchors.fill: parent
                                        radius: 14
                                        color: "#ffffff"
                                        border.color: "#ecf0f1"  // 固定边框颜色，不再变化
                                        border.width: 1  // 固定边框宽度
                                        
                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.topMargin: 2  // 固定阴影位置
                                            anchors.leftMargin: 2  // 固定阴影位置
                                            color: "#06000000"  // 固定阴影颜色
                                            radius: parent.radius
                                            z: -1
                                          
                                        }
                                        
                                        MouseArea {
                                            id: cardArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            
                                            onClicked: {
                                                console.log("点击了商品:", model.name, "ID:", model.productId)
                                                showProductDetailRequested(model.productId)
                                            }
                                        }
                                        
                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 16
                                            spacing: 12
                                            
                                            // 商品图片区域
                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 150
                                                radius: 10
                                                color: "#f8f9fa"
                                                border.color: "#e9ecef"
                                                border.width: 1
                                                
                                                ColumnLayout {
                                                    anchors.centerIn: parent
                                                    spacing: 6
                                                    
                                                    Text {
                                                        Layout.alignment: Qt.AlignHCenter
                                                        text: getCategoryIcon(model.category)
                                                        font.pixelSize: 40
                                                        color: getCategoryColor(model.category)
                                                    }
                                                    
                                                    Rectangle {
                                                        Layout.preferredWidth: 70
                                                        Layout.preferredHeight: 20
                                                        Layout.alignment: Qt.AlignHCenter
                                                        radius: 10
                                                        color: getCategoryColor(model.category)
                                                        
                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: model.category || "未分类"
                                                            font.pixelSize: 10
                                                            color: "white"
                                                            font.bold: true
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            // 商品信息区域
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 6
                                                
                                                // 商品名称
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 36
                                                    color: "transparent"
                                                    
                                                    Text {
                                                        anchors.fill: parent
                                                        text: model.name || "未知商品"
                                                        font.pixelSize: 14
                                                        font.bold: true
                                                        color: "#2c3e50"
                                                        wrapMode: Text.WordWrap
                                                        maximumLineCount: 2
                                                        elide: Text.ElideRight
                                                        verticalAlignment: Text.AlignTop
                                                    }
                                                }
                                                
                                                // 评分和库存信息
                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 8
                                                    
                                                    // 评分信息
                                                    RowLayout {
                                                        spacing: 3
                                                        
                                                        Text {
                                                            text: "⭐"
                                                            font.pixelSize: 12
                                                        }
                                                        
                                                        Text {
                                                            text: (model.avgRating || 0).toFixed(1)
                                                            font.pixelSize: 11
                                                            color: "#7f8c8d"
                                                            font.bold: true
                                                        }
                                                        
                                                        Text {
                                                            text: "(" + (model.reviewers || 0) + ")"
                                                            font.pixelSize: 10
                                                            color: "#95a5a6"
                                                        }
                                                    }
                                                    
                                                    Item { Layout.fillWidth: true }
                                                    
                                                    // 库存标签
                                                    Rectangle {
                                                        Layout.preferredWidth: stockText.implicitWidth + 8
                                                        Layout.preferredHeight: 16
                                                        radius: 8
                                                        color: (model.stock || 0) > 0 ? "#2ecc71" : "#e74c3c"
                                                        
                                                        Text {
                                                            id: stockText
                                                            anchors.centerIn: parent
                                                            text: "库存 " + (model.stock || 0)
                                                            font.pixelSize: 8
                                                            color: "white"
                                                            font.bold: true
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            Item { Layout.fillHeight: true }
                                            
                                            // 价格和按钮区域
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 10
                                                
                                                // 价格显示
                                                Text {
                                                    Layout.alignment: Qt.AlignHCenter
                                                    text: "¥" + (model.price || 0).toFixed(2)
                                                    font.pixelSize: 18
                                                    font.bold: true
                                                    color: "#e74c3c"
                                                }
                                                
                                                // 操作按钮
                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 8
                                                    
                                                    // 查看详情按钮 
                                                    Rectangle {
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: 34
                                                        radius: 8
                                                        color: detailArea.containsMouse ? "#3498db" : "#2c3e50"
                                                        
                                                        scale: detailArea.pressed ? 0.96 : 1.0
                                                        
                                                        Behavior on color { ColorAnimation { duration: 200 } }
                                                        Behavior on scale { NumberAnimation { duration: 100 } }
                                                        
                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: "查看"  
                                                            color: "white"
                                                            font.pixelSize: 12
                                                            font.bold: true
                                                        }
                                                        
                                                        MouseArea {
                                                            id: detailArea
                                                            anchors.fill: parent
                                                            hoverEnabled: true
                                                            cursorShape: Qt.PointingHandCursor
                                                            
                                                            onClicked: {
                                                                console.log("查看商品详情:", model.name, "ID:", model.productId)
                                                                showProductDetailRequested(model.productId)
                                                            }
                                                        }
                                                    }
                                                    
                                                    // 加入购物车按钮
                                                    Rectangle {
                                                        Layout.preferredWidth: 42
                                                        Layout.preferredHeight: 34
                                                        radius: 8
                                                        color: cartArea.containsMouse ? "#27ae60" : "#2ecc71"
                                                        
                                                        scale: cartArea.pressed ? 0.96 : 1.0
                                                        
                                                        Behavior on color { ColorAnimation { duration: 200 } }
                                                        Behavior on scale { NumberAnimation { duration: 100 } }
                                                        
                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: "🛒"
                                                            font.pixelSize: 15
                                                        }
                                                        
                                                        MouseArea {
                                                            id: cartArea
                                                            anchors.fill: parent
                                                            hoverEnabled: true
                                                            cursorShape: Qt.PointingHandCursor
                                                            
                                                            onClicked: {
                                                                console.log("添加到购物车:", model.name, "ID:", model.productId, "价格:", model.price)
                                                                addToCartRequested(model.productId, model.name, model.price, 1)
                                                                cartFeedback.start()
                                                            }
                                                        }
                                                        
                                                        // 购物车反馈动画
                                                        Rectangle {
                                                            id: cartFeedbackRect
                                                            anchors.centerIn: parent
                                                            width: 16
                                                            height: 16
                                                            radius: 8
                                                            color: "#ffffff"
                                                            opacity: 0
                                                            
                                                            Text {
                                                                anchors.centerIn: parent
                                                                text: "✓"
                                                                font.pixelSize: 10
                                                                color: "#2ecc71"
                                                                font.bold: true
                                                            }
                                                            
                                                            SequentialAnimation {
                                                                id: cartFeedback
                                                                
                                                                ParallelAnimation {
                                                                    NumberAnimation {
                                                                        target: cartFeedbackRect
                                                                        property: "opacity"
                                                                        from: 0; to: 1; duration: 150
                                                                    }
                                                                    NumberAnimation {
                                                                        target: cartFeedbackRect
                                                                        property: "scale"
                                                                        from: 0.5; to: 1.1; duration: 150
                                                                    }
                                                                }
                                                                
                                                                PauseAnimation { duration: 250 }
                                                                
                                                                ParallelAnimation {
                                                                    NumberAnimation {
                                                                        target: cartFeedbackRect
                                                                        property: "opacity"
                                                                        to: 0; duration: 150
                                                                    }
                                                                    NumberAnimation {
                                                                        target: cartFeedbackRect
                                                                        property: "scale"
                                                                        to: 1.0; duration: 150
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
                        
                        // 空状态提示
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "暂无商品数据"
                            font.pixelSize: 16
                            color: "#7f8c8d"
                            visible: productModel.count === 0
                        }
                    }
                }
            }
        }
    }
    
    // 工具函数 - 获取分类图标
    function getCategoryIcon(category) {
        switch(category) {
            case "手机": return "📱"
            case "电脑": return "💻"
            case "耳机": return "🎧"
            case "平板": return "📲"
            case "手表": return "⌚"
            default: return "📦"
        }
    }
    
    // 工具函数 - 获取分类颜色
    function getCategoryColor(category) {
        switch(category) {
            case "手机": return "#e74c3c"
            case "电脑": return "#9b59b6"
            case "耳机": return "#f39c12"
            case "平板": return "#2ecc71"
            case "手表": return "#34495e"
            default: return "#3498db"
        }
    }
    
    // === 使用 DataManager 的商品数据操作函数 ===
    
    // 从DataManager加载商品数据并填充到模型中
    function loadAllProducts() {
        console.log("开始使用DataManager加载商品数据...")
        
        try {
            // 清空当前模型
            productModel.clear()
            
            // 调用DataManager的loadProductsFromJson()函数从JSON文件加载数据
            var loadSuccess = dataManager.loadProductsFromJson()
            if (!loadSuccess) {
                console.error("从JSON文件加载商品数据失败")
                return false
            }
            
            // 调用DataManager的getProducts()函数获取所有商品数据
            var products = dataManager.getProducts()
            
            console.log("从DataManager获取到", products.length, "个商品")
            
            // 将商品数据添加到QML模型中，注意字段名映射
            for (var i = 0; i < products.length; i++) {
                var product = products[i]
                productModel.append({
                    "productId": product.productId,
                    "name": product.name,
                    "price": product.price,
                    "stock": product.stock,
                    "category": product.category,
                    "avgRating": product.avgRating,  // 使用统一的字段名
                    "reviewers": product.reviewers
                })
            }
            
            console.log("商品数据加载完成，共", productModel.count, "个商品显示在界面上")
            return true
            
        } catch (error) {
            console.error("加载商品数据时发生错误:", error)
            return false
        }
    }
    
    // 清空商品列表
    function clearProductList() {
        console.log("清空商品列表")
        productModel.clear()
    }
    
    // 获取商品总数 - 使用DataManager
    function getProductCount() {
        var products = dataManager.getProducts()
        return products.length
    }
    
    // 根据ID查找商品 - 使用DataManager的findProduct函数
    function findProductById(productId) {
        try {
            var product = dataManager.findProduct(productId)
            if (product) {
                console.log("找到商品:", product.name, "价格:", product.price)
                return product
            } else {
                console.log("未找到ID为", productId, "的商品")
                return null
            }
        } catch (error) {
            console.error("查找商品时发生错误:", error)
            return null
        }
    }
    
    // 页面组件完成初始化后的处理
    Component.onCompleted: {
        console.log("商品浏览页面初始化...")
        console.log("DataManager实例已创建，开始加载商品数据")
        
        // 页面加载完成后立即使用DataManager函数加载商品数据
        var success = loadAllProducts()
        
        if (success) {
            console.log("商品浏览页面初始化完成，商品数据加载成功")
        } else {
            console.error("商品浏览页面初始化完成，但商品数据加载失败")
        }
    }
}