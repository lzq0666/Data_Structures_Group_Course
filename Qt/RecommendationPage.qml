import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StateManager 1.0
import DataManager 1.0
import Recommender 1.0

Item {
    id: recommendationPage

    // 定义信号
    signal backToMainMenuRequested()

    property StateManager stateManager: null
    
    // 当 stateManager 设置完成后，自动加载推荐
    onStateManagerChanged: {
        if (stateManager) {
            console.log("stateManager 已设置，开始加载推荐")
            loadCollaborativeRecommendations()
        }
    }

    // 推荐器 - 只提供一个方法：getRecommendations()
    Recommender {
        id: recommender
    }

    // DataManager 实例（用于其他功能）
    DataManager {
        id: dataManager
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { color: "#667eea"; position: 0.0 }
            GradientStop { color: "#764ba2"; position: 1.0 }
        }

        // 主容器
        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.95, 1200)
            height: Math.min(parent.height * 0.95, 800)
            radius: 20
            color: "white"
            opacity: 0.98
            border.color: "#e0e0e0"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                // 顶部区域：标题和返回按钮
                Rectangle {
                    width: parent.width
                    height: 60
                    color: "transparent"

                    Row {
                        anchors.fill: parent
                        spacing: 20

                        // 返回按钮
                        Rectangle {
                            id: backButton
                            width: 100
                            height: 40
                            radius: 8
                            color: backArea.containsMouse ? "#3498db" : "#ecf0f1"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "← 返回"
                                color: backArea.containsMouse ? "white" : "#2c3e50"
                                font.pixelSize: 14
                                font.bold: true
                            }

                            MouseArea {
                                id: backArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: backToMainMenuRequested()
                            }

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }

                        // 标题区域
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 5

                            Text {
                                text: "智能推荐"
                                color: "#2c3e50"
                                font.pixelSize: 28
                                font.bold: true
                            }

                            Text {
                                text: "基于协同过滤算法的智能推荐系统"
                                color: "#7f8c8d"
                                font.pixelSize: 14
                            }
                        }

                        // 用户信息
                        Item {
                            width: parent.width - backButton.width - 300
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "当前用户: " + (stateManager ? stateManager.getCurrentUser() : "未知")
                            color: "#34495e"
                            font.pixelSize: 14
                        }
                    }
                }

                // 商品推荐列表
                Rectangle {
                    width: parent.width
                    height: parent.height - 100
                    color: "transparent"

                    ScrollView {
                        anchors.fill: parent
                        clip: true

                        GridView {
                            id: productList
                            anchors.fill: parent
                            cellWidth: 300
                            cellHeight: 380
                            model: ListModel { id: recommendationsModel }

                            delegate: Rectangle {
                                width: productList.cellWidth - 10
                                height: productList.cellHeight - 10
                                radius: 12
                                color: "#ffffff"
                                border.color: "#ecf0f1"
                                border.width: 1

                                property var productData: model

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
                                    onClicked: {
                                        recordUserBehavior("view", productData)
                                        console.log("查看商品详情:", productData ? productData.name : "")
                                    }
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
                                                text: getCategoryIcon(productData.category)
                                                font.pixelSize: 45
                                                color: getCategoryColor(productData.category)
                                            }

                                            Rectangle {
                                                Layout.preferredWidth: 80
                                                Layout.preferredHeight: 22
                                                Layout.alignment: Qt.AlignHCenter
                                                radius: 11
                                                color: getCategoryColor(productData.category)

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: productData.category || "未分类"
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
                                            text: productData.name || "未知商品"
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
                                                    text: (productData.avgRating || 0).toFixed(1)
                                                    font.pixelSize: 13
                                                    color: "#f39c12"
                                                    font.bold: true
                                                }

                                                Text {
                                                    text: "(" + (productData.reviewers || 0) + ")"
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
                                                color: (productData.stock || 0) > 0 ? "#2ecc71" : "#e74c3c"

                                                Text {
                                                    id: stockLabel
                                                    anchors.centerIn: parent
                                                    text: "库存 " + (productData.stock || 0)
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
                                            text: "¥" + (productData.price || 0).toFixed(2)
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
                                                color: viewBtnArea.containsMouse ? "#34495e" : "#2c3e50"

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "查看详情"
                                                    color: "white"
                                                    font.pixelSize: 13
                                                    font.bold: true
                                                }

                                                MouseArea {
                                                    id: viewBtnArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        recordUserBehavior("view", productData)
                                                        console.log("查看商品详情:", productData ? productData.name : "")
                                                    }
                                                }

                                                Behavior on color {
                                                    ColorAnimation { duration: 200 }
                                                }
                                            }

                                            // 加入购物车按钮
                                            Rectangle {
                                                id: cartButton
                                                Layout.preferredWidth: 45
                                                Layout.preferredHeight: 36
                                                radius: 8
                                                color: cartBtnArea.containsMouse ? "#27ae60" : "#2ecc71"

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "🛒"
                                                    font.pixelSize: 16
                                                }

                                                MouseArea {
                                                    id: cartBtnArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        recordUserBehavior("add_to_cart", productData)
                                                        console.log("加入购物车:", productData ? productData.name : "")
                                                    }
                                                }

                                                Behavior on color {
                                                    ColorAnimation { duration: 200 }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // 空状态提示
                    Rectangle {
                        anchors.centerIn: parent
                        width: 400
                        height: 120
                        color: "transparent"
                        visible: productList.count === 0

                        Column {
                            anchors.centerIn: parent
                            spacing: 15

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "暂无推荐商品"
                                color: "#6c757d"
                                font.pixelSize: 20
                                font.bold: true
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "建议多浏览和评分商品，以便为您提供更精准的推荐"
                                color: "#95a5a6"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                width: 380
                            }
                        }
                    }
                }
            }
        }
    }

    // ======================== 属性定义 ========================
    
    // 协同过滤算法参数配置
    property var collaborativeConfig: ({
        userSimilarityThreshold: 0.5,    // 用户相似度阈值 (0-1)
        minRatingsCount: 3,              // 用户最少评分数量
        maxRecommendations: 12,          // 最大推荐数量
        minSimilarUsers: 2,              // 最少相似用户数量
        weightDecay: 0.95                // 时间权重衰减因子
    })

    // ======================== 协同过滤核心算法接口 ========================
    
    /**
     * 主推荐函数 - 直接调用 C++ 的 getRecommendations 方法
     * @description 所有逻辑（加载数据、构建矩阵、计算推荐）都在 C++ 中完成
     */
    function loadCollaborativeRecommendations() {
        console.log("========== 请求生成推荐 ==========")

        if (!stateManager || !stateManager.isLoggedIn()) {
            console.log("用户未登录，无法生成推荐")
            return
        }

        var username = stateManager.getCurrentUser()
        console.log("当前用户:", username)
        
        // 清空现有列表
        recommendationsModel.clear()
        
        // 调用 C++ 方法获取推荐（一行代码搞定！）
        var recommendations = recommender.getRecommendations(username, collaborativeConfig.maxRecommendations)
        
        console.log("收到推荐结果:", recommendations.length, "个商品")
        
        // 添加到模型
        for (var i = 0; i < recommendations.length; i++) {
            var product = recommendations[i]
            
            // 添加额外的 UI 字段
            product.similarUsers = []
            product.userSimilarities = []
            
            recommendationsModel.append(product)
        }
        
        console.log("========== 推荐加载完成 ==========")
    }

    // ======================== 用户行为记录接口 ========================
    
    /**
     * 记录用户行为
     * @param actionType 行为类型: "view", "add_to_cart", "rate"
     * @param productData 商品数据
     * @param extraData 额外数据(如评分值)
     */
    function recordUserBehavior(actionType, productData, extraData = null) {
        if (!stateManager || !stateManager.isLoggedIn() || !productData) {
            console.log("无法记录用户行为：用户未登录或商品数据无效")
            return
        }
        
        var username = stateManager.getCurrentUser()
        
        console.log("记录用户行为:", {
            user: username,
            action: actionType,
            productId: productData.productId,
            productName: productData.name,
            extraData: extraData
        })
    }

    /**
     * 显示评分对话框
     * @param productData 商品数据
     */
    function showRatingDialog(productData) {
        console.log("TODO: 显示评分对话框 -", productData ? productData.name : "未知商品")
        
        // 临时实现：直接记录4分评分
        var mockRating = 4.0
        recordUserBehavior("rate", productData, mockRating)
    }

    // ======================== 辅助函数 ========================
    
    /**
     * 根据分类获取图标
     */
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
    
    /**
     * 根据分类获取颜色
     */
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

    // ======================== 组件初始化 ========================
    
    Component.onCompleted: {
        console.log("========== 推荐页面已加载 ==========")
        console.log("配置:", JSON.stringify(collaborativeConfig, null, 2))
        
        // 不在这里加载推荐，而是等待 stateManager 设置完成后自动加载
        // 参见 onStateManagerChanged 处理器
    }
}