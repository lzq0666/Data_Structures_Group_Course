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
    
    // DataManager实例
    DataManager {
        id: dataManager
    }
    
    // 商品模型
    ListModel {
        id: productModel
    }
    
    // 筛选和搜索相关属性
    property string currentSearchText: ""
    property string currentCategory: "全部"
    
    // 渐变背景
    Rectangle {
        anchors.fill: parent
        
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { color: "#4158d0"; position: 0.0 }
            GradientStop { color: "#c850c0"; position: 1.0 }
        }
    }
    
    // 主容器
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
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 25
                    
                    // 返回按钮
                    Rectangle {
                        Layout.preferredWidth: 110
                        Layout.preferredHeight: 40
                        radius: 10
                        color: backArea.containsMouse ? "#3498db" : "#2c3e50"
                        
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
                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                        text: "🛍️ 商品浏览"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#2c3e50"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // 搜索框
                    Rectangle {
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: 40
                        radius: 10
                        color: "#ffffff"
                        border.color: searchField.activeFocus ? "#3498db" : "#ecf0f1"
                        border.width: searchField.activeFocus ? 2 : 1
                        
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
                                placeholderText: "搜索商品名称..."
                                font.pixelSize: 13
                                color: "#2c3e50"
                                placeholderTextColor: "#bdc3c7"
                                background: Item {}
                                verticalAlignment: TextInput.AlignVCenter
                                
                                onTextChanged: {
                                    currentSearchText = text
                                    searchTimer.restart()
                                }
                                
                                Keys.onPressed: {
                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        applyFilters()
                                        event.accepted = true
                                    }
                                }
                            }
                            
                            // 清空搜索按钮
                            Rectangle {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                radius: 10
                                color: clearSearchArea.containsMouse ? "#e74c3c" : "transparent"
                                visible: searchField.text.length > 0
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    font.pixelSize: 12
                                    color: clearSearchArea.containsMouse ? "white" : "#7f8c8d"
                                }
                                
                                MouseArea {
                                    id: clearSearchArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        searchField.text = ""
                                        searchField.focus = false
                                    }
                                }
                            }
                        }
                        
                        // 搜索延迟定时器
                        Timer {
                            id: searchTimer
                            interval: 500
                            repeat: false
                            onTriggered: applyFilters()
                        }
                    }
                }
            }
            
            // 中间内容区域
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 20

                // 左侧分类面板
                Rectangle {
                    Layout.preferredWidth: 250
                    Layout.fillHeight: true
                    radius: 15
                    color: "#ffffff"
                    border.color: "#ecf0f1"
                    border.width: 2
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20
                        
                        // 分类标题和重置按钮
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "📂 商品分类"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#2c3e50"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            // 重置按钮
                            Rectangle {
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 30
                                radius: 8
                                color: {
                                    if (currentCategory !== "全部") {
                                        return resetArea.containsMouse ? "#e67e22" : "#e74c3c"
                                    } else {
                                        return resetArea.containsMouse ? "#95a5a6" : "#bdc3c7"
                                    }
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "重置"
                                    font.pixelSize: 12
                                    color: "white"
                                    font.bold: true
                                }
                                
                                MouseArea {
                                    id: resetArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: resetFilters()
                                }
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 2
                            radius: 1
                            color: "#e74c3c"
                        }
                        
                        // 商品分类筛选
                        ButtonGroup { id: categoryGroup }
                        
                        Repeater {
                            model: [
                                {text: "全部", icon: "🏪", color: "#3498db"},
                                {text: "食品", icon: "🍎", color: "#e74c3c"},
                                {text: "日用品", icon: "🧴", color: "#9b59b6"},
                                {text: "电器", icon: "🔌", color: "#f39c12"},
                                {text: "数码产品", icon: "📱", color: "#2ecc71"},
                                {text: "服装", icon: "👗", color: "#34495e"},
                                {text: "酒水", icon: "🍷", color: "#3498db"}
                            ]
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 10
                                
                                property bool isSelected: categoryBtn.checked
                                
                                color: isSelected ? modelData.color : "#ffffff"
                                border.color: isSelected ? modelData.color : "#ecf0f1"
                                border.width: 2
                                
                                RadioButton {
                                    id: categoryBtn
                                    anchors.fill: parent
                                    text: modelData.text
                                    checked: index === 0
                                    ButtonGroup.group: categoryGroup
                                    
                                    indicator: Item {}
                                    
                                    contentItem: RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 10
                                        
                                        Text {
                                            text: modelData.icon
                                            font.pixelSize: 20
                                            Layout.alignment: Qt.AlignVCenter   // 图标垂直居中
                                        }
                                        
                                        Text {
                                            text: categoryBtn.text
                                            font.pixelSize: 16
                                            font.bold: categoryBtn.checked
                                            color: categoryBtn.checked ? "white" : "#2c3e50"
                                            Layout.alignment: Qt.AlignVCenter   // 文本垂直居中
                                            Layout.fillWidth: true  // 文本区域填充剩余宽度
                                            horizontalAlignment: Text.AlignLeft // 文本左对齐
                                            verticalAlignment: Text.AlignVCenter    // 文本垂直居中
                                        }
                                    }
                                    
                                    onCheckedChanged: {
                                        if (checked) {
                                            currentCategory = text
                                            applyFilters()
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
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
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15
                        
                        // 商品区域标题和统计信息
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: "🎁 " + getDisplayTitle()
                                font.pixelSize: 18
                                font.bold: true
                                color: "#2c3e50"
                            }
                            
                            Text {
                                text: "共找到 " + productModel.count + " 件商品"
                                font.pixelSize: 13
                                color: "#7f8c8d"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            // 筛选状态指示器
                            Rectangle {
                                Layout.preferredWidth: filterIndicator.implicitWidth + 16
                                Layout.preferredHeight: 30
                                radius: 15
                                color: "#e74c3c"
                                visible: hasActiveFilters()
                                
                                Text {
                                    id: filterIndicator
                                    anchors.centerIn: parent
                                    text: "筛选已应用"
                                    font.pixelSize: 12
                                    color: "white"
                                    font.bold: true
                                }
                            }
                        }
                        
                        // 商品网格
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            
                            GridView {
                                id: productGrid
                                
                                cellWidth: 280
                                cellHeight: 380
                                model: productModel
                                
                                delegate: Rectangle {
                                    width: productGrid.cellWidth - 10
                                    height: productGrid.cellHeight - 10
                                    radius: 12
                                    color: "#ffffff"
                                    border.color: "#ecf0f1"
                                    border.width: 1
                                    
                                    // 阴影效果
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.topMargin: 3
                                        anchors.leftMargin: 3
                                        color: "#06000000"
                                        radius: parent.radius
                                        z: -1
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: showProductDetailRequested(model.productId)
                                    }
                                    
                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 12
                                        
                                        // 商品图片区域
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 140
                                            radius: 10
                                            color: "#f8f9fa"
                                            border.color: "#e9ecef"
                                            border.width: 1
                                            
                                            ColumnLayout {
                                                anchors.centerIn: parent
                                                spacing: 8
                                                
                                                Text {
                                                    Layout.alignment: Qt.AlignHCenter
                                                    text: getCategoryIcon(model.category)
                                                    font.pixelSize: 45
                                                    color: getCategoryColor(model.category)
                                                }
                                                
                                                Rectangle {
                                                    Layout.preferredWidth: 80
                                                    Layout.preferredHeight: 22
                                                    Layout.alignment: Qt.AlignHCenter
                                                    radius: 11
                                                    color: getCategoryColor(model.category)
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: model.category || "未分类"
                                                        font.pixelSize: 11
                                                        color: "white"
                                                        font.bold: true
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // 商品信息区域
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 8
                                            
                                            // 商品名称
                                            Text {
                                                Layout.fillWidth: true
                                                text: model.name || "未知商品"
                                                font.pixelSize: 15
                                                font.bold: true
                                                color: "#2c3e50"
                                                wrapMode: Text.WordWrap
                                                maximumLineCount: 2
                                                elide: Text.ElideRight
                                            }
                                            
                                            // 评分和库存信息
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 10
                                                
                                                // 评分信息
                                                RowLayout {
                                                    spacing: 4
                                                    
                                                    Text {
                                                        text: "⭐"
                                                        font.pixelSize: 14
                                                    }
                                                    
                                                    Text {
                                                        text: (model.avgRating || 0).toFixed(1)
                                                        font.pixelSize: 13
                                                        color: "#f39c12"
                                                        font.bold: true
                                                    }
                                                    
                                                    Text {
                                                        text: "(" + (model.reviewers || 0) + ")"
                                                        font.pixelSize: 11
                                                        color: "#95a5a6"
                                                    }
                                                }
                                                
                                                Item { Layout.fillWidth: true }
                                                
                                                // 库存标签
                                                Rectangle {
                                                    Layout.preferredWidth: stockLabel.implicitWidth + 10
                                                    Layout.preferredHeight: 20
                                                    radius: 10
                                                    color: (model.stock || 0) > 0 ? "#2ecc71" : "#e74c3c"
                                                    
                                                    Text {
                                                        id: stockLabel
                                                        anchors.centerIn: parent
                                                        text: "库存 " + (model.stock || 0)
                                                        font.pixelSize: 10
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
                                            spacing: 12
                                            
                                            // 价格显示
                                            Text {
                                                Layout.alignment: Qt.AlignHCenter
                                                text: "¥" + (model.price || 0).toFixed(2)
                                                font.pixelSize: 20
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
                                                    Layout.preferredHeight: 36
                                                    radius: 8
                                                    color: "#2c3e50"
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "查看详情"
                                                        color: "white"
                                                        font.pixelSize: 13
                                                        font.bold: true
                                                    }
                                                    
                                                    MouseArea {
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: showProductDetailRequested(model.productId)
                                                    }
                                                }
                                                
                                                // 加入购物车按钮 - 恢复动画反馈
                                                Rectangle {
                                                    id: cartButton
                                                    Layout.preferredWidth: 45
                                                    Layout.preferredHeight: 36
                                                    radius: 8
                                                    color: "#2ecc71"
                                                    enabled: (model.stock || 0) > 0
                                                    opacity: enabled ? 1.0 : 0.5
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "🛒"
                                                        font.pixelSize: 16
                                                    }
                                                    
                                                    MouseArea {
                                                        id: cartArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        enabled: parent.enabled
                                                        
                                                        onClicked: {
                                                            console.log("添加到购物车:", model.name, "ID:", model.productId, "价格:", model.price)
                                                            addToCartRequested(model.productId, model.name, model.price, 1)
                                                            cartFeedback.start()
                                                        }
                                                    }
                                                    
                                                    // 购物车反馈动画 - 恢复
                                                    Rectangle {
                                                        id: cartFeedbackRect
                                                        anchors.centerIn: parent
                                                        width: 20
                                                        height: 20
                                                        radius: 10
                                                        color: "#ffffff"
                                                        opacity: 0
                                                        scale: 1.0
                                                        
                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: "✓"
                                                            font.pixelSize: 12
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
                                                                    from: 0.5; to: 1.2; duration: 150
                                                                }
                                                            }
                                                            
                                                            PauseAnimation { duration: 400 }
                                                            
                                                            ParallelAnimation {
                                                                NumberAnimation {
                                                                    target: cartFeedbackRect
                                                                    property: "opacity"
                                                                    to: 0; duration: 200
                                                                }
                                                                NumberAnimation {
                                                                    target: cartFeedbackRect
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
                                }
                            }
                        }
                        
                        // 空状态提示
                        ColumnLayout {
                            Layout.alignment: Qt.AlignCenter
                            spacing: 15
                            visible: productModel.count === 0
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "🔍"
                                font.pixelSize: 48
                                color: "#bdc3c7"
                            }
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: getEmptyStateMessage()
                                font.pixelSize: 16
                                color: "#7f8c8d"
                                font.bold: true
                            }
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "尝试调整分类筛选或搜索关键词"
                                font.pixelSize: 14
                                color: "#95a5a6"
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
            case "食品": return "🍎"
            case "日用品": return "🧴"
            case "电器": return "🔌"
            case "数码产品": return "📱"
            case "服装": return "👗"
            case "酒水": return "🍷"
            default: return "📦"
        }
    }
    
    function getCategoryColor(category) {
        switch(category) {
            case "食品": return "#e74c3c"
            case "日用品": return "#9b59b6"
            case "电器": return "#f39c12"
            case "数码产品": return "#2ecc71"
            case "服装": return "#34495e"
            case "酒水": return "#3498db"
            default: return "#3498db"
        }
    }
    
    function getDisplayTitle() {
        if (currentCategory !== "全部") {
            return currentCategory + " - 商品列表"
        }
        if (currentSearchText) {
            return "搜索结果: " + currentSearchText
        }
        return "全部商品"
    }
    
    function getEmptyStateMessage() {
        if (hasActiveFilters()) {
            return "没有找到符合条件的商品"
        }
        return "暂无商品数据"
    }
    
    function hasActiveFilters() {
        return currentSearchText !== "" || currentCategory !== "全部"
    }
    
    // 数据操作函数
    function applyFilters() {
        try {
            productModel.clear()
            
            var filteredProducts = []
            
            if (currentSearchText === "" && currentCategory === "全部") {
                filteredProducts = dataManager.getProducts()
            } else if (currentSearchText !== "" && currentCategory === "全部") {
                filteredProducts = dataManager.searchProducts(currentSearchText)
            } else if (currentSearchText === "" && currentCategory !== "全部") {
                filteredProducts = dataManager.filterByCategory(currentCategory)
            } else {
                var searchResults = dataManager.searchProducts(currentSearchText)
                var categoryResults = dataManager.filterByCategory(currentCategory)
                
                var searchMap = {}
                for (var i = 0; i < searchResults.length; i++) {
                    var product = searchResults[i]
                    searchMap[product.productId] = product
                }
                
                for (var j = 0; j < categoryResults.length; j++) {
                    var catProduct = categoryResults[j]
                    if (searchMap[catProduct.productId]) {
                        filteredProducts.push(catProduct)
                    }
                }
            }
            
            for (var k = 0; k < filteredProducts.length; k++) {
                var finalProduct = filteredProducts[k]
                productModel.append({
                    "productId": finalProduct.productId,
                    "name": finalProduct.name,
                    "price": finalProduct.price,
                    "stock": finalProduct.stock,
                    "category": finalProduct.category,
                    "avgRating": finalProduct.avgRating,
                    "reviewers": finalProduct.reviewers
                })
            }
            
        } catch (error) {
            console.error("应用筛选条件时发生错误:", error)
            loadAllProducts()
        }
    }
    
    function resetFilters() {
        searchField.text = ""
        currentSearchText = ""
        
        for (var i = 0; i < categoryGroup.buttons.length; i++) {
            if (i === 0) {
                categoryGroup.buttons[i].checked = true
                break
            }
        }
        currentCategory = "全部"
        
        loadAllProducts()
    }
    
    function loadAllProducts() {
        try {
            productModel.clear()
            
            var loadSuccess = dataManager.loadProductsFromJson()
            if (!loadSuccess) {
                console.error("从JSON文件加载商品数据失败")
                return false
            }
            
            var products = dataManager.getProducts()
            
            for (var i = 0; i < products.length; i++) {
                var product = products[i]
                productModel.append({
                    "productId": product.productId,
                    "name": product.name,
                    "price": product.price,
                    "stock": product.stock,
                    "category": product.category,
                    "avgRating": product.avgRating,
                    "reviewers": product.reviewers
                })
            }
            
            return true
            
        } catch (error) {
            console.error("加载商品数据时发生错误:", error)
            return false
        }
    }
    
    Component.onCompleted: {
        loadAllProducts()
    }
}
