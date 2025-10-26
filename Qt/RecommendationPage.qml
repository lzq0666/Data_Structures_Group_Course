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

    /**
     * 协同过滤推荐算法核心接口
     * @param username 目标用户名
     * @returns 推荐商品数组
     * @description 基于用户-商品评分矩阵，找到相似用户，推荐他们喜欢的商品
     * 
     * 协同过滤算法步骤：
     * 1. 获取目标用户的评分历史
     * 2. 获取所有其他用户的评分历史  
     * 3. 计算目标用户与其他用户的相似度（皮尔逊相关系数或余弦相似度）
     * 4. 筛选出相似度超过阈值的用户
     * 5. 基于相似用户的评分预测目标用户对未评分商品的评分
     * 6. 选择预测评分最高的商品作为推荐
     * 
     * 预期返回格式：
     * [
     *   {
     *     productId: 1001,
     *     name: "商品名称",
     *     price: 99.99,
     *     avgRating: 4.5,
     *     reviewers: 100,
     *     category: "分类",
     *     collaborativeScore: 4.2,           // 协同过滤预测评分 (1-5)
     *     recommendationReason: "与您偏好相似的3位用户都给出了高评分",
     *     similarUsers: ["user1", "user2", "user3"],  // 相似用户列表
     *     userSimilarities: [0.85, 0.78, 0.65],      // 对应的相似度值
     *     predictedRating: 4.2,              // 预测评分
     *     confidence: 0.78                   // 推荐置信度
     *   }
     * ]
     */
    function generateCollaborativeRecommendations(username) {
        console.log("TODO: 实现协同过滤推荐算法")
        
        // TODO: 实现步骤
        /*
        1. 调用 getUserRatings(username) 获取目标用户评分历史
        2. 调用 getAllUsersRatings() 获取所有用户评分数据
        3. 调用 calculateUserSimilarity(targetUser, otherUser) 计算用户相似度
        4. 调用 findSimilarUsers(username, threshold) 找到相似用户
        5. 调用 predictRatings(username, similarUsers) 预测商品评分
        6. 调用 selectTopRecommendations(predictions, count) 选择top推荐
        */
        
        return []
    }

    /**
     * 获取用户评分历史
     * @param username 用户名
     * @returns 用户评分数组
     * @description 从DataManager获取用户的评分历史数据
     * 
     * 预期返回格式：
     * [
     *   { productId: 1001, rating: 4.5, timestamp: 1640995200 },
     *   { productId: 1002, rating: 3.8, timestamp: 1641081600 },
     *   ...
     * ]
     */
    function getUserRatings(username) {
        // TODO: 从DataManager获取用户评分数据
        /*
        1. 调用 DataManager.findUser(username) 获取用户对象
        2. 解析用户的 favorites 字段 (格式: [[productId, rating], ...])
        3. 转换为标准格式并返回
        */
        
        console.log("TODO: 获取用户评分历史 -", username)
        return []
    }

    /**
     * 获取所有用户的评分数据
     * @returns 所有用户评分映射
     * @description 获取系统中所有用户的评分数据，用于计算用户相似度
     * 
     * 预期返回格式：
     * {
     *   "user1": [
     *     { productId: 1001, rating: 4.5 },
     *     { productId: 1002, rating: 3.8 }
     *   ],
     *   "user2": [
     *     { productId: 1001, rating: 4.0 },
     *     { productId: 1003, rating: 4.2 }
     *   ],
     *   ...
     * }
     */
    function getAllUsersRatings() {
        // TODO: 从DataManager获取所有用户评分数据
        /*
        1. 调用 DataManager.getUsers() 获取所有用户
        2. 遍历每个用户，提取其评分历史
        3. 构建用户-评分映射表
        */
        
        console.log("TODO: 获取所有用户评分数据")
        return {}
    }

    /**
     * 计算两个用户之间的相似度
     * @param userRatings1 用户1的评分数组
     * @param userRatings2 用户2的评分数组
     * @returns 相似度值 (0-1)
     * @description 使用皮尔逊相关系数计算用户相似度
     * 
     * 算法说明：
     * 1. 找到两个用户都评分过的商品
     * 2. 如果共同评分商品少于最小阈值，返回0
     * 3. 计算皮尔逊相关系数
     * 4. 将相关系数转换为0-1范围的相似度
     */
    function calculateUserSimilarity(userRatings1, userRatings2) {
        // TODO: 实现皮尔逊相关系数计算
        /*
        1. 找到共同评分的商品 commonProducts
        2. 如果 commonProducts.length < collaborativeConfig.minRatingsCount，返回 0
        3. 计算平均评分 mean1, mean2
        4. 计算皮尔逊相关系数 r = Σ((x-μx)(y-μy)) / √(Σ(x-μx)²Σ(y-μy)²)
        5. 返回 (r + 1) / 2 将-1~1转换为0~1
        */
        
        console.log("TODO: 计算用户相似度")
        return 0.0
    }

    /**
     * 找到与目标用户相似的用户
     * @param username 目标用户名
     * @returns 相似用户数组
     * @description 找到相似度超过阈值的用户
     * 
     * 预期返回格式：
     * [
     *   { username: "user1", similarity: 0.85 },
     *   { username: "user2", similarity: 0.78 },
     *   ...
     * ]
     */
    function findSimilarUsers(username) {
        // TODO: 实现相似用户查找
        /*
        1. 获取目标用户评分 targetRatings = getUserRatings(username)
        2. 获取所有用户评分 allUsersRatings = getAllUsersRatings()
        3. 遍历其他用户，计算与目标用户的相似度
        4. 筛选相似度 >= collaborativeConfig.userSimilarityThreshold 的用户
        5. 按相似度降序排序
        6. 返回相似用户列表
        */
        
        console.log("TODO: 查找相似用户 -", username)
        return []
    }

    /**
     * 基于相似用户预测目标用户对商品的评分
     * @param username 目标用户名
     * @param similarUsers 相似用户数组
     * @returns 预测评分数组
     * @description 使用加权平均预测用户对未评分商品的评分
     * 
     * 预测公式：
     * 预测评分 = Σ(相似度 × 相似用户评分) / Σ(相似度)
     * 
     * 预期返回格式：
     * [
     *   { 
     *     productId: 1001, 
     *     predictedRating: 4.2, 
     *     confidence: 0.78, 
     *     contributingUsers: ["user1", "user2"] 
     *   },
     *   ...
     * ]
     */
    function predictUserRatings(username, similarUsers) {
        // TODO: 实现评分预测
        /*
        1. 获取目标用户已评分商品 ratedProducts
        2. 获取所有商品列表 allProducts
        3. 筛选出目标用户未评分的商品 unratedProducts
        4. 对每个未评分商品：
           a. 找到相似用户中对该商品有评分的用户
           b. 使用加权平均计算预测评分
           c. 计算预测置信度
        5. 返回预测结果
        */
        
        console.log("TODO: 预测用户评分 -", username)
        return []
    }

    // ======================== 用户行为记录接口 ========================
    
    /**
     * 记录用户行为
     * @param actionType 行为类型: "view", "add_to_cart", "rate"
     * @param productData 商品数据
     * @param extraData 额外数据(如评分值)
     * @description 记录用户行为，特别是评分行为对协同过滤很重要
     */
    function recordUserBehavior(actionType, productData, extraData = null) {
        if (!stateManager || !stateManager.isLoggedIn() || !productData) {
            console.log("无法记录用户行为：用户未登录或商品数据无效")
            return
        }
        
        var username = stateManager.getCurrentUser()
        var timestamp = Math.floor(Date.now() / 1000)
        
        // TODO: 更新用户行为数据到DataManager
        /*
        根据actionType更新对应的用户数据：
        - "view": 更新viewHistory [[productId, timestamp], ...]
        - "add_to_cart": 更新shoppingCart [[productId, quantity], ...]  
        - "rate": 更新favorites [[productId, rating], ...] (这是评分数据)
        
        特别注意：评分数据对协同过滤算法至关重要
        */
        
        console.log("记录用户行为:", {
            user: username,
            action: actionType,
            productId: productData.productId,
            productName: productData.name,
            extraData: extraData,
            timestamp: timestamp
        })
        
        // 如果是评分行为，可能需要重新生成推荐
        if (actionType === "rate") {
            console.log("用户新增评分，建议重新生成推荐")
        }
    }

    /**
     * 显示评分对话框
     * @param productData 商品数据
     * @description 让用户对商品进行评分，这是协同过滤的重要数据来源
     */
    function showRatingDialog(productData) {
        // TODO: 实现评分对话框
        /*
        1. 创建评分对话框（1-5星评分）
        2. 用户选择评分后，调用 recordUserBehavior("rate", productData, rating)
        3. 更新用户的评分数据到DataManager
        4. 可选：重新生成推荐
        */
        
        console.log("TODO: 显示评分对话框 -", productData ? productData.name : "未知商品")
        
        // 临时实现：直接记录4分评分
        var mockRating = 4.0
        recordUserBehavior("rate", productData, mockRating)
    }

    /**
     * 临时实现：模拟协同过滤推荐
     * @description 在真正的协同过滤算法完成前的模拟实现
     */
    function loadMockCollaborativeRecommendations(username) {
        try {
            var allProducts = dataManager.getProducts()
            
            // 模拟协同过滤推荐逻辑
            var mockRecommendations = []
            var maxRecommendations = Math.min(allProducts.length, collaborativeConfig.maxRecommendations)
            
            for (var i = 0; i < maxRecommendations; i++) {
                var product = allProducts[i]
                
                // 模拟协同过滤数据
                var mockProduct = Object.assign({}, product)
                mockProduct.collaborativeScore = Math.random() * 2 + 3  // 3-5分
                mockProduct.recommendationReason = "模拟：与您偏好相似的用户推荐"
                mockProduct.similarUsers = ["模拟用户1", "模拟用户2", "模拟用户3"]
                mockProduct.userSimilarities = [0.85, 0.78, 0.65]
                mockProduct.predictedRating = mockProduct.collaborativeScore
                mockProduct.confidence = Math.random() * 0.3 + 0.7  // 0.7-1.0
                
                mockRecommendations.push(mockProduct)
            }
            
            // 按协同过滤得分排序
            mockRecommendations.sort(function(a, b) {
                return b.collaborativeScore - a.collaborativeScore
            })
            
            // 添加到界面模型
            for (var j = 0; j < mockRecommendations.length; j++) {
                recommendationsModel.append(mockRecommendations[j])
            }

            console.log("模拟协同过滤推荐加载完成，共", mockRecommendations.length, "个商品")

        } catch (error) {
            console.error("加载模拟协同过滤推荐时发生错误:", error)
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