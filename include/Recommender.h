#ifndef RECOMMENDER_H
#define RECOMMENDER_H

#include <vector>
#include <unordered_map>
#include <utility>
#include <QObject>
#include <QVariantList>
#include <QString>

// 前置声明
struct ProductData;
struct UserData;

namespace Recommender
{
    extern std::vector<ProductData> g_products;					// 存储商品结构体
    extern std::vector<UserData> g_users;				    // 存储用户结构体
    extern std::unordered_map<int, int> g_productIdToIndex;		// 商品ID -> 数组索引映射
    extern std::vector<std::vector<double>> g_coOccurrenceMatrix;   // 共现矩阵
    extern std::vector<std::vector<double>> g_similarityMatrix;	    // 相似度矩阵

    void initMapping();									// 初始化商品ID到索引的映射
    std::vector<std::pair<int, double>> calculateInterestScore(const UserData& user);	// 计算用户对所有商品的兴趣分数，返回{商品ID, 兴趣值}
    void buildCoOccurrenceMatrix();						// 构建共现矩阵
    void buildSimilarityMatrix();						// 构建相似度矩阵
    std::vector<std::pair<int, double>> recommendProducts(int userId, int topK);	// 为指定用户推荐物品
}

/**
 * @brief RecommenderWrapper - QML 包装类
 * 
 * 提供简单的接口给 QML 使用：
 * - 自动加载数据
 * - 自动构建矩阵
 * - 只暴露一个方法：getRecommendations(username, topK)
 */
class RecommenderWrapper : public QObject {
    Q_OBJECT

public:
    explicit RecommenderWrapper(QObject* parent = nullptr);

    /**
     * @brief 获取推荐列表
     * @param username 用户名
     * @param topK 推荐数量（默认12）
     * @return 推荐商品列表（QVariantList）
     * 
     * 此方法会自动完成以下操作：
     * 1. 加载用户和商品数据（如果未加载）
     * 2. 构建推荐矩阵（如果未构建）
     * 3. 调用推荐算法
     * 4. 返回格式化的推荐结果
     */
    Q_INVOKABLE QVariantList getRecommendations(const QString& username, int topK = 12);

private:
    bool m_initialized;  // 是否已初始化
    
    // 内部方法：确保系统已初始化
    bool ensureInitialized();
};

#endif // !RECOMMENDER_H