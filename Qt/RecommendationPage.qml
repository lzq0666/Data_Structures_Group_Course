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
                            cellHeight: 240
                            model: ListModel { id: recommendationsModel }

                            delegate: Rectangle {
                                width: productList.cellWidth - 10
                                height: productList.cellHeight - 10
                                radius: 15
                                color: "white"
                                border.color: cardArea.containsMouse ? "#3498db" : "#e9ecef"
                                border.width: 2

                                property var productData: model

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 8

                                    // 商品名称和协同过滤标签
                                    Row {
                                        width: parent.width
                                        spacing: 8

                                        Text {
                                            width: parent.width - 60
                                            text: productData ? productData.name : "加载中..."
                                            color: "#2c3e50"
                                            font.pixelSize: 16
                                            font.bold: true
                                            wrapMode: Text.WordWrap
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                        }

                                        Rectangle {
                                            width: 50
                                            height: 18
                                            radius: 9
                                            color: "#dc3545"  // 协同过滤标识色

                                            Text {
                                                anchors.centerIn: parent
                                                text: "协同"
                                                color: "white"
                                                font.pixelSize: 8
                                                font.bold: true
                                            }
                                        }
                                    }

                                    // 价格和评分
                                    Row {
                                        spacing: 15

                                        Text {
                                            text: "¥" + (productData ? productData.price.toFixed(2) : "0.00")
                                            color: "#e74c3c"
                                            font.pixelSize: 18
                                            font.bold: true
                                        }

                                        Row {
                                            spacing: 5

                                            Text {
                                                text: "★"
                                                color: "#f39c12"
                                                font.pixelSize: 14
                                            }

                                            Text {
                                                text: productData ? productData.avgRating.toFixed(1) : "0.0"
                                                color: "#f39c12"
                                                font.pixelSize: 14
                                            }

                                            Text {
                                                text: "(" + (productData ? productData.reviewers : 0) + ")"
                                                color: "#95a5a6"
                                                font.pixelSize: 12
                                            }
                                        }
                                    }

                                    // 协同过滤推荐得分
                                    Rectangle {
                                        width: parent.width
                                        height: 25
                                        color: "#ffe8e8"
                                        radius: 12

                                        Rectangle {
                                            width: (productData && productData.collaborativeScore ? 
                                                   (productData.collaborativeScore / 5.0) * parent.width : 0)
                                            height: parent.height
                                            color: "#dc3545"
                                            radius: 12
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "推荐度: " + (productData && productData.collaborativeScore ? 
                                                            productData.collaborativeScore.toFixed(1) + "/5.0" : "0/5.0")
                                            color: "#2c3e50"
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }

                                    // 相似用户信息
                                    Text {
                                        width: parent.width
                                        text: productData && productData.similarUsers ? 
                                              "相似用户数量: " + productData.similarUsers.length : "正在分析相似用户..."
                                        color: "#6c757d"
                                        font.pixelSize: 11
                                        wrapMode: Text.WordWrap
                                    }

                                    // 协同过滤推荐理由
                                    Text {
                                        width: parent.width
                                        text: productData && productData.recommendationReason ? 
                                              productData.recommendationReason : "基于相似用户偏好推荐"
                                        color: "#6c757d"
                                        font.pixelSize: 11
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }

                                    // 分类标签
                                    Rectangle {
                                        width: categoryLabel.implicitWidth + 12
                                        height: 20
                                        color: "#007bff"
                                        radius: 10

                                        Text {
                                            id: categoryLabel
                                            anchors.centerIn: parent
                                            text: productData ? productData.category : ""
                                            color: "white"
                                            font.pixelSize: 10
                                        }
                                    }

                                    // 操作按钮
                                    Row {
                                        width: parent.width
                                        spacing: 8

                                        Rectangle {
                                            width: (parent.width - 16) / 3
                                            height: 25
                                            radius: 12
                                            color: viewArea.containsMouse ? "#17a2b8" : "#20c997"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "查看"
                                                color: "white"
                                                font.pixelSize: 9
                                                font.bold: true
                                            }

                                            MouseArea {
                                                id: viewArea
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

                                        Rectangle {
                                            width: (parent.width - 16) / 3
                                            height: 25
                                            radius: 12
                                            color: cartArea.containsMouse ? "#dc3545" : "#fd7e14"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "购物车"
                                                color: "white"
                                                font.pixelSize: 9
                                                font.bold: true
                                            }

                                            MouseArea {
                                                id: cartArea
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

                                        Rectangle {
                                            width: (parent.width - 16) / 3
                                            height: 25
                                            radius: 12
                                            color: rateArea.containsMouse ? "#6f42c1" : "#8f5bc3"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "评分"
                                                color: "white"
                                                font.pixelSize: 9
                                                font.bold: true
                                            }

                                            MouseArea {
                                                id: rateArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    showRatingDialog(productData)
                                                }
                                            }

                                            Behavior on color {
                                                ColorAnimation { duration: 200 }
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: cardArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                }

                                Behavior on border.color {
                                    ColorAnimation { duration: 200 }
                                }

                                // 添加阴影效果
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: -2
                                    radius: parent.radius + 2
                                    color: "transparent"
                                    border.color: "#00000020"
                                    border.width: 1
                                    z: -1
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

    // ======================== 组件初始化 ========================
    
    Component.onCompleted: {
        console.log("========== 推荐页面已加载 ==========")
        console.log("配置:", JSON.stringify(collaborativeConfig, null, 2))
        
        // 不在这里加载推荐，而是等待 stateManager 设置完成后自动加载
        // 参见 onStateManagerChanged 处理器
    }
}