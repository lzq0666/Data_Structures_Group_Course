#include "Recommender.h"
#include "DataManager.h"
#include <unordered_map>
#include <vector>
#include <utility>
#include <cmath>
#include <algorithm>

/**
 * @brief 初始化商品ID到索引的映射
 */
void initMapping()
{
	productIdToIndex.clear();
	for (int i = 0; i < products.size(); i++)
	{
		productIdToIndex[products[i].productId] = i;
	}
}

/**
 * @brief 计算用户对所有商品的兴趣分数
 * @param user 用户数据指针
 * @return 包含{商品ID, 兴趣值}的pair数组
 * 
 * 兴趣值计算规则：
 * I = 0.6 * f_r + 0.25 * f_c + 0.15 * f_v
 * 
 * - f_r: 用户对商品的评分，f_r = (r - 1) / 4，1 <= r <= 5
 * - f_c: 是否加入购物车，加入购物车则为1，否则为0
 * - f_v: 浏览次数，f_v = 1 - exp(-0.2 * v)
 */
std::vector<std::pair<int, double>> calculateInterestScore(UserData* user) {
    std::vector<std::pair<int, double>> interestScores;
    
    if (user == nullptr) {
        return interestScores;
    }
    
    // 权重设置
    const double RATING_WEIGHT = 0.6;      // 评分权重
    const double CART_WEIGHT = 0.25;       // 购物车权重
    const double VIEW_WEIGHT = 0.15;       // 浏览次数权重
    
    // 为每个商品构建一个映射，记录评分、是否在购物车、浏览次数
    std::unordered_map<int, double> ratings;        // 商品ID -> 评分
    std::unordered_map<int, bool> inCart;           // 商品ID -> 是否在购物车
    std::unordered_map<int, int> viewCounts;        // 商品ID -> 浏览次数
    
    // 1. 处理收藏（favorites）数据，获取评分
    // favorites格式: [[商品ID, 评分], ...]
    for (const auto& favorite : user->favorites) {
        if (favorite.size() >= 2) {
            int productId = favorite[0];
            int rating = favorite[1];
            ratings[productId] = rating;
        }
    }
    
    // 2. 处理购物车（shoppingCart）数据
    // shoppingCart格式: [[商品ID, 数量, ...], ...]
    for (const auto& cartItem : user->shoppingCart) {
        if (!cartItem.empty()) {
            int productId = cartItem[0];
            inCart[productId] = true;
        }
    }
    
    // 3. 处理浏览历史（viewHistory）数据
    // viewHistory格式: [[商品ID, 浏览次数, ...], ...]
    for (const auto& viewItem : user->viewHistory) {
        if (viewItem.size() >= 2) {
            int productId = viewItem[0];
            int views = viewItem[1];
            viewCounts[productId] = views;
        } else if (viewItem.size() == 1) {
            int productId = viewItem[0];
            viewCounts[productId] = 1;  // 默认浏览1次
        }
    }
    
    // 4. 收集所有用户有交互的商品ID
    std::unordered_map<int, bool> interactedProducts;
    for (const auto& pair : ratings) {
		int productId = pair.first;
        interactedProducts[productId] = true;
    }
    for (const auto& pair : inCart) {
		int productId = pair.first;
        interactedProducts[productId] = true;
    }
    for (const auto& pair : viewCounts) {
        int productId = pair.first;
        interactedProducts[productId] = true;
    }
    
    // 5. 为每个有交互的商品计算兴趣值
    for (const auto& pair : interactedProducts) {
		int productId = pair.first;
        // 评分因素 f_r = (r - 1) / 4
        double f_r = 0.0;
        if (ratings.find(productId) != ratings.end()) {
            double r = ratings[productId];
            f_r = (r - 1.0) / 4.0;  // 将[1,5]映射到[0,1]
        }
        
        // 购物车因素 f_c
        double f_c = 0.0;
        if (inCart.find(productId) != inCart.end() && inCart[productId]) {
            f_c = 1.0;
        }
        
        // 浏览次数因素 使用饱和函数 f_v = 1 - exp(-0.2 * v)
        double f_v = 0.0;
        if (viewCounts.find(productId) != viewCounts.end()) {
            int v = viewCounts[productId];
            f_v = 1.0 - std::exp(-0.2 * v);
        }
        
		// 计算加权兴趣值
        double interestValue = RATING_WEIGHT * f_r + CART_WEIGHT * f_c + VIEW_WEIGHT * f_v;
        
        // 确保兴趣值在[0,1]范围内
        interestValue = std::max(0.0, std::min(1.0, interestValue));
        
        // 添加到结果中：{商品ID, 兴趣值}
        interestScores.push_back({productId, interestValue});
    }
    
    return interestScores;
}

/**
 * @brief 构建共现矩阵
 * 
 * 分析用户的行为，统计物品之间的共现次数
 */
void buildCoOccurrenceMatrix() {
	int n = products.size();
	// 为共现矩阵分配空间并初始化为 0
	coOccurrenceMatrix.resize(n, std::vector<double>(n, 0));
	for (const auto& user : users)
	{
		// 计算用户的兴趣分数
		std::vector<std::pair<int, double>> interestScores = calculateInterestScore(user);

        for (size_t i = 0; i < interestScores.size(); i++) {
            for (size_t j = i + 1; j < interestScores.size(); j++) {
                int productAId = interestScores[i].first;
				int productBId = interestScores[j].first;
				double productAInterest = interestScores[i].second;
				double productBInterest = interestScores[j].second;

				// 检查商品ID是否在映射中
                if (productIdToIndex.find(productAId) != productIdToIndex.end() &&
                    productIdToIndex.find(productBId) != productIdToIndex.end()) {
					int indexA = productIdToIndex[productAId];
                    int indexB = productIdToIndex[productBId];
					// 计算加权共现
					double weight = productAInterest * productBInterest;
                    coOccurrenceMatrix[indexA][indexB] += weight;
                    // TODO: 矩阵压缩存储？
					coOccurrenceMatrix[indexB][indexA] += weight;
                }
            }
        }
	}
}

/**
 * @brief 构建相似度矩阵
 * 
 * 使用余弦相似度公式：W_ij = C_ij / sqrt(N_i * N_j)
 * 其中 C_ij 是共现次数，N_i 和 N_j 是各自被收藏的总次数
 */
void buildSimilarityMatrix() {
    // TODO: 实现构建相似度矩阵的逻辑
}

/**
 * @brief 为指定用户推荐物品
 * @param userId 用户ID
 * @param topK 推荐物品的数量
 * @return 推荐结果列表，包含物品ID和推荐分数的对
 */
std::vector<std::pair<int, double>> recommendProducts(int userId, int topK) {
    // TODO: 实现推荐算法逻辑
    std::vector<std::pair<int, double>> recommendations;
    
    return recommendations;
}
