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
    
    // StateManager 引用
    property var stateManager: null
    
    // 重新启用DataManager实例
    DataManager {
        id: dataManager
    }
    
    // 商品模型 - 用于显示商品数据
    ListModel {
        id: productModel
    }
    
    // 搜索和分类相关属性（暂时保留，但不使用筛选功能）
    property string currentSearchText: ""
    property string currentCategory: "全部"
    
    // 背景渐变
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#f8f9fa" }
            GradientStop { position: 1.0; color: "#e9ecef" }
        }
    }
    
    // 主布局
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        // 顶部栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "white"
            radius: 12
            border.color: "#dee2e6"
            border.width: 1
            
            // 简单阴影效果（不使用 QtGraphicalEffects）
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 2
                anchors.leftMargin: 2
                color: "#20000000"
                radius: parent.radius
                z: -1
            }
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 4
                anchors.leftMargin: 4
                color: "#10000000"
                radius: parent.radius
                z: -2
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                
                // 返回按钮
                Button {
                    id: backButton
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 40
                    text: "← 返回"
                    
                    background: Rectangle {
                        color: backButton.pressed ? "#e9ecef" : (backButton.hovered ? "#f8f9fa" : "transparent")
                        radius: 8
                        border.color: "#6c757d"
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: backButton.text
                        color: "#495057"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: backToMainMenuRequested()
                }
                
                // 标题
                Text {
                    Layout.fillWidth: true
                    text: "商品浏览"
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    color: "#212529"
                    horizontalAlignment: Text.AlignHCenter
                }
                
                // 搜索框 - 保留UI，暂时不实现筛选功能
                Rectangle {
                    Layout.preferredWidth: 250
                    Layout.preferredHeight: 40
                    color: "#f8f9fa"
                    radius: 20
                    border.color: searchField.activeFocus ? "#007bff" : "#ced4da"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8
                        
                        Text {
                            text: "🔍"
                            font.pixelSize: 16
                            color: "#6c757d"
                        }
                        
                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            placeholderText: "搜索商品..."
                            font.pixelSize: 14
                            color: "#495057"
                            background: Item {}
                            
                            // 暂时不实现筛选功能，只记录搜索文本
                            onTextChanged: {
                                currentSearchText = text
                                console.log("搜索文本变更:", text, "- 筛选功能暂未实现")
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
            
            // 左侧分类筛选 - 保留UI，暂时不实现筛选功能
            Rectangle {
                Layout.preferredWidth: 200
                Layout.fillHeight: true
                color: "white"
                radius: 12
                border.color: "#dee2e6"
                border.width: 1
                
                // 简单阴影效果
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: 2
                    anchors.leftMargin: 2
                    color: "#20000000"
                    radius: parent.radius
                    z: -1
                }
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: 4
                    anchors.leftMargin: 4
                    color: "#10000000"
                    radius: parent.radius
                    z: -2
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "商品分类"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: "#212529"
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: "#dee2e6"
                    }
                    
                    // 分类按钮组 - 保留UI结构
                    ButtonGroup {
                        id: categoryGroup
                    }
                    
                    // 动态生成分类按钮 - 暂时不实现筛选功能
                    Repeater {
                        model: ["全部", "手机", "电脑", "耳机", "平板", "手表"]
                        
                        RadioButton {
                            id: categoryBtn
                            text: modelData
                            checked: index === 0
                            ButtonGroup.group: categoryGroup
                            
                            // 暂时不实现筛选功能，只记录选择的分类
                            onCheckedChanged: {
                                if (checked) {
                                    currentCategory = text
                                    console.log("分类选择:", text, "- 筛选功能暂未实现")
                                }
                            }
                            
                            indicator: Rectangle {
                                implicitWidth: 18
                                implicitHeight: 18
                                x: categoryBtn.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 9
                                border.color: categoryBtn.checked ? "#007bff" : "#ced4da"
                                color: categoryBtn.checked ? "#007bff" : "transparent"
                                
                                Rectangle {
                                    width: 8
                                    height: 8
                                    anchors.centerIn: parent
                                    radius: 4
                                    color: "white"
                                    visible: categoryBtn.checked
                                }
                            }
                            
                            contentItem: Text {
                                text: categoryBtn.text
                                font.pixelSize: 14
                                color: "#495057"
                                leftPadding: categoryBtn.indicator.width + categoryBtn.spacing
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                    
                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
            
            // 右侧商品展示区域 - 显示所有商品
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                radius: 12
                border.color: "#dee2e6"
                border.width: 1
                
                // 简单阴影效果
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: 2
                    anchors.leftMargin: 2
                    color: "#20000000"
                    radius: parent.radius
                    z: -1
                }
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: 4
                    anchors.leftMargin: 4
                    color: "#10000000"
                    radius: parent.radius
                    z: -2
                }
                
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 20
                    clip: true
                    
                    GridView {
                        id: productGrid
                        cellWidth: 280
                        cellHeight: 400
                        model: productModel
                        
                        delegate: Item {
                            width: productGrid.cellWidth - 10
                            height: productGrid.cellHeight - 10
                            
                            Rectangle {
                                id: productCard
                                anchors.fill: parent
                                color: "white"
                                radius: 12
                                border.color: cardMouseArea.containsMouse ? "#007bff" : "#e9ecef"
                                border.width: cardMouseArea.containsMouse ? 2 : 1
                                
                                // 鼠标悬停时的简单阴影效果
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.topMargin: cardMouseArea.containsMouse ? 4 : 2
                                    anchors.leftMargin: cardMouseArea.containsMouse ? 4 : 2
                                    color: cardMouseArea.containsMouse ? "#30000000" : "#20000000"
                                    radius: parent.radius
                                    z: -1
                                }
                                
                                Behavior on border.color {
                                    ColorAnimation { duration: 200 }
                                }
                                
                                Behavior on border.width {
                                    NumberAnimation { duration: 200 }
                                }
                                
                                // 鼠标悬停效果
                                MouseArea {
                                    id: cardMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    
                                    onClicked: {
                                        console.log("点击了商品:", model.name, "ID:", model.productId)
                                    }
                                }
                                
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 10
                                    
                                    // 商品图片占位
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 180
                                        color: "#f8f9fa"
                                        radius: 8
                                        border.color: "#dee2e6"
                                        border.width: 1
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "🖼️"
                                            font.pixelSize: 48
                                            color: "#6c757d"
                                        }
                                    }
                                    
                                    // 商品名称
                                    Text {
                                        Layout.fillWidth: true
                                        text: model.name || "未知商品"
                                        font.pixelSize: 16
                                        font.weight: Font.Medium
                                        color: "#212529"
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }
                                    
                                    // 商品分类
                                    Text {
                                        Layout.fillWidth: true
                                        text: "分类：" + (model.category || "未分类")
                                        font.pixelSize: 12
                                        color: "#6c757d"
                                    }
                                    
                                    // 评分和库存信息
                                    RowLayout {
                                        Layout.fillWidth: true
                                        
                                        // 评分
                                        Row {
                                            spacing: 5
                                            
                                            Text {
                                                text: "★"
                                                color: "#ffc107"
                                                font.pixelSize: 14
                                            }
                            
                                            Text {
                                                text: (model.avgRating || 0).toFixed(1) + " (" + (model.reviewers || 0) + ")"
                                                font.pixelSize: 12
                                                color: "#6c757d"
                                            }
                                        }
                                        
                                        Item { Layout.fillWidth: true }
                                        
                                        // 库存信息
                                        Text {
                                            text: "库存：" + (model.stock || 0)
                                            font.pixelSize: 12
                                            color: (model.stock || 0) > 0 ? "#28a745" : "#dc3545"
                                        }
                                    }
                                    
                                    Item {
                                        Layout.fillHeight: true
                                    }
                                    
                                    // 底部价格和按钮
                                    RowLayout {
                                        Layout.fillWidth: true
                                        
                                        Text {
                                            Layout.fillWidth: true
                                            text: "¥" + (model.price || 0).toFixed(2)
                                            font.pixelSize: 18
                                            font.weight: Font.Bold
                                            color: "#dc3545"
                                        }
                                        
                                        Button {
                                            Layout.preferredWidth: 80
                                            Layout.preferredHeight: 32
                                            text: "查看"
                                            
                                            background: Rectangle {
                                                color: parent.pressed ? "#0056b3" : (parent.hovered ? "#0069d9" : "#007bff")
                                                radius: 6
                                            }
                                            
                                            contentItem: Text {
                                                text: parent.text
                                                color: "white"
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            
                                            onClicked: {
                                                console.log("查看商品详情:", model.name, "ID:", model.productId)
                                                // TODO: 跳转到商品详情页面
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
                    anchors.centerIn: parent
                    text: "未找到相关商品"
                    font.pixelSize: 16
                    color: "#6c757d"
                    visible: productModel.count === 0
                }
            }
        }
    }
    
    // 从DataManager加载商品数据并填充到模型中
    function loadAllProducts() {
        console.log("开始加载商品数据...")
        
        // 清空当前模型
        productModel.clear()
        
        // 确保DataManager已经加载了数据
        dataManager.loadProductsFromJson()
        
        // 获取所有商品数据
        var products = dataManager.getProducts()
        
        console.log("从DataManager获取到", products.length, "个商品")
        
        // 将商品数据添加到模型中
        for (var i = 0; i < products.length; i++) {
            var product = products[i]
            productModel.append({
                "productId": product.productId,
                "name": product.name,
                "price": product.price,
                "stock": product.stock,
                "category": product.category,
                "avgRating": product.avgRating,  // 注意：DataManager中使用avgRating字段
                "reviewers": product.reviewers
            })
        }
        
        console.log("商品数据加载完成，共", productModel.count, "个商品显示在界面上")
    }
    
    // 刷新商品列表
    function refreshProductList() {
        console.log("刷新商品列表...")
        loadAllProducts()
    }
    
    // 清空商品列表
    function clearProductList() {
        console.log("清空商品列表")
        productModel.clear()
    }
    
    Component.onCompleted: {
        console.log("商品浏览页面初始化...")
        
        // 页面加载完成后立即加载商品数据
        loadAllProducts()
        
        console.log("商品浏览页面初始化完成")
    }
}