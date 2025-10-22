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
    // 全局变量声明（使用 extern）
    extern std::vector<ProductData *> g_products;
    extern std::vector<UserData *> g_users;
    extern std::unordered_map<int, int> g_productIdToIndex;
    extern std::vector<std::vector<double>> g_coOccurrenceMatrix;
    extern std::vector<std::vector<double>> g_similarityMatrix;

    // 函数声明
    void initMapping();
    std::vector<std::pair<int, double>> calculateInterestScore(UserData *user);
    void buildCoOccurrenceMatrix();
    void buildSimilarityMatrix();
    std::vector<std::pair<int, double>> recommendProducts(int userId, int topK);
}

#endif