#ifndef RECOMMENDER_H
#define RECOMMENDER_H

#include <vector>
#include <unordered_map>
#include <utility>

// 前向声明
struct UserData;
struct ProductData;

namespace Recommender
{
    // 全局变量声明（使用 extern），由实现文件初始化
    // g_products: 指向所有商品数据的指针数组
    // g_users: 指向所有用户数据的指针数组
    // g_productIdToIndex: 商品ID -> 在 g_products 中的索引映射
    // g_coOccurrenceMatrix: 共现矩阵（基于用户行为计算）
    // g_similarityMatrix: 相似度矩阵（从共现矩阵归一化得到）
    extern std::vector<ProductData *> g_products;
    extern std::vector<UserData *> g_users;
    extern std::unordered_map<int, int> g_productIdToIndex;
    extern std::vector<std::vector<double>> g_coOccurrenceMatrix;
    extern std::vector<std::vector<double>> g_similarityMatrix;

    // 初始化商品ID到索引的映射（必须在设置 g_products 后调用）
    void initMapping();

    // 计算单个用户对各商品的兴趣分数
    // 返回值: vector of {productId, score}，score 在 [0,1] 之间
    std::vector<std::pair<int, double>> calculateInterestScore(UserData *user);

    // 基于所有用户的兴趣分数构建共现矩阵（C_ij）
    void buildCoOccurrenceMatrix();

    // 基于共现矩阵计算相似度矩阵（例如余弦/归一化方法）
    void buildSimilarityMatrix();

    // 为指定用户推荐商品，返回 topK 个 {productId, score}
    std::vector<std::pair<int, double>> recommendProducts(int userId, int topK);
}

#endif