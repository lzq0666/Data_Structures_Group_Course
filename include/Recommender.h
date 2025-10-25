#ifndef RECOMMENDER_H
#define RECOMMENDER_H

#include <vector>
#include <unordered_map>
#include <utility>

// Forward declarations
struct ProductData;
struct UserData;

namespace Recommender
{
    extern std::vector<ProductData*> g_products;					// 存储商品结构体指针
    extern std::vector<UserData*> g_users;						    // 存储用户结构体指针
    extern std::unordered_map<int, int> g_productIdToIndex;		// 商品ID -> 数组索引映射
    extern std::vector<std::vector<double>> g_coOccurrenceMatrix;   // 共现矩阵
    extern std::vector<std::vector<double>> g_similarityMatrix;	    // 相似度矩阵

    void initMapping();									// 初始化商品ID到索引的映射
    std::vector<std::pair<int, double>> calculateInterestScore(UserData* user);	// 计算用户对所有商品的兴趣分数，返回{商品ID, 兴趣值}
    void buildCoOccurrenceMatrix();						// 构建共现矩阵
    void buildSimilarityMatrix();						// 构建相似度矩阵
    std::vector<std::pair<int, double>> recommendProducts(int userId, int topK);	// 为指定用户推荐物品
}

#endif // !RECOMMENDER_H