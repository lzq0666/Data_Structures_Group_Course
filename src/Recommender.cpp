#include "Recommender.h"
#include "DataManager.h"
#include <unordered_map>
#include <vector>
#include <utility>
#include <cmath>
#include <algorithm>

// ���������ռ��ڵ�ȫ�ֱ���
namespace Recommender
{
    std::vector<ProductData *> g_products;
    std::vector<UserData *> g_users;
    std::unordered_map<int, int> g_productIdToIndex;
    std::vector<std::vector<double>> g_coOccurrenceMatrix;
    std::vector<std::vector<double>> g_similarityMatrix;

    /**
     * @brief ��ʼ����ƷID��������ӳ��
     */
    void initMapping()
    {
        g_productIdToIndex.clear();
        for (int i = 0; i < g_products.size(); i++)
        {
            g_productIdToIndex[g_products[i]->productId] = i;
        }
    }

    /**
     * @brief �����û���������Ʒ����Ȥ����
     * @param user �û�����ָ��
     * @return ����{��ƷID, ��Ȥֵ}��pair����
     *
     * ��Ȥֵ�������
     * I = 0.6 * f_r + 0.25 * f_c + 0.15 * f_v
     *
     * - f_r: �û�����Ʒ�����֣�f_r = (r - 1) / 4��1 <= r <= 5
     * - f_c: �Ƿ���빺�ﳵ�����빺�ﳵ��Ϊ1������Ϊ0
     * - f_v: ���������f_v = 1 - exp(-0.2 * v)
     */
    std::vector<std::pair<int, double>> calculateInterestScore(UserData *user)
    {
        std::vector<std::pair<int, double>> interestScores;

        if (user == nullptr)
        {
            return interestScores;
        }

        // Ȩ������
        const double RATING_WEIGHT = 0.6; // ����Ȩ��
        const double CART_WEIGHT = 0.25;  // ���ﳵȨ��
        const double VIEW_WEIGHT = 0.15;  // �������Ȩ��

        // Ϊÿ����Ʒ����һ��ӳ�䣬��¼���֡��Ƿ��ڹ��ﳵ���������
        std::unordered_map<int, double> ratings; // ��ƷID -> ����
        std::unordered_map<int, bool> inCart;    // ��ƷID -> �Ƿ��ڹ��ﳵ
        std::unordered_map<int, int> viewCounts; // ��ƷID -> �������

        // 1. �����ղأ�favorites�����ݣ���ȡ����
        // favorites��ʽ: [[��ƷID, ����], ...]
        for (const auto &favorite : user->favorites)
        {
            if (favorite.size() >= 2)
            {
                int productId = favorite[0];
                int rating = favorite[1];
                ratings[productId] = rating;
            }
        }

        // 2. �����ﳵ��shoppingCart������
        // shoppingCart��ʽ: [[��ƷID, ����, ...], ...]
        for (const auto &cartItem : user->shoppingCart)
        {
            if (!cartItem.empty())
            {
                int productId = cartItem[0];
                inCart[productId] = true;
            }
        }

        // 3. ���������ʷ��viewHistory������
        // viewHistory��ʽ: [[��ƷID, �������, ...], ...]
        for (const auto &viewItem : user->viewHistory)
        {
            if (viewItem.size() >= 2)
            {
                int productId = viewItem[0];
                int views = viewItem[1];
                viewCounts[productId] = views;
            }
            else if (viewItem.size() == 1)
            {
                int productId = viewItem[0];
                viewCounts[productId] = 1; // Ĭ�����1��
            }
        }

        // 4. �ռ������û��н�������ƷID
        std::unordered_map<int, bool> interactedProducts;
        for (const auto &pair : ratings)
        {
            int productId = pair.first;
            interactedProducts[productId] = true;
        }
        for (const auto &pair : inCart)
        {
            int productId = pair.first;
            interactedProducts[productId] = true;
        }
        for (const auto &pair : viewCounts)
        {
            int productId = pair.first;
            interactedProducts[productId] = true;
        }

        // 5. Ϊÿ���н�������Ʒ������Ȥֵ
        for (const auto &pair : interactedProducts)
        {
            int productId = pair.first;
            // �������� f_r = (r - 1) / 4
            double f_r = 0.0;
            if (ratings.find(productId) != ratings.end())
            {
                double r = ratings[productId];
                f_r = (r - 1.0) / 4.0; // ��[1,5]ӳ�䵽[0,1]
            }

            // ���ﳵ���� f_c
            double f_c = 0.0;
            if (inCart.find(productId) != inCart.end() && inCart[productId])
            {
                f_c = 1.0;
            }

            // ����������� ʹ�ñ��ͺ��� f_v = 1 - exp(-0.2 * v)
            double f_v = 0.0;
            if (viewCounts.find(productId) != viewCounts.end())
            {
                int v = viewCounts[productId];
                f_v = 1.0 - std::exp(-0.2 * v);
            }

            // �����Ȩ��Ȥֵ
            double interestValue = RATING_WEIGHT * f_r + CART_WEIGHT * f_c + VIEW_WEIGHT * f_v;

            // ȷ����Ȥֵ��[0,1]��Χ��
            interestValue = std::max(0.0, std::min(1.0, interestValue));

            // ��ӵ�����У�{��ƷID, ��Ȥֵ}
            interestScores.push_back({productId, interestValue});
        }

        return interestScores;
    }

    /**
     * @brief �������־���
     *
     * �����û�����Ϊ��ͳ����Ʒ֮��Ĺ��ִ���
     */
    void buildCoOccurrenceMatrix()
    {
        int n = g_products.size();
        // Ϊ���־������ռ䲢��ʼ��Ϊ 0
        g_coOccurrenceMatrix.resize(n, std::vector<double>(n, 0));
        for (const auto &user : g_users)
        {
            // �����û�����Ȥ����
            std::vector<std::pair<int, double>> interestScores = calculateInterestScore(user);

            for (size_t i = 0; i < interestScores.size(); i++)
            {
                for (size_t j = i; j < interestScores.size(); j++)
                { // j �� i ��ʼ�������Խ���
                    int productAId = interestScores[i].first;
                    int productBId = interestScores[j].first;
                    double productAInterest = interestScores[i].second;
                    double productBInterest = interestScores[j].second;

                    // �����ƷID�Ƿ���ӳ����
                    if (g_productIdToIndex.find(productAId) != g_productIdToIndex.end() &&
                        g_productIdToIndex.find(productBId) != g_productIdToIndex.end())
                    {
                        int indexA = g_productIdToIndex[productAId];
                        int indexB = g_productIdToIndex[productBId];
                        // �����Ȩ����
                        double weight = productAInterest * productBInterest;
                        g_coOccurrenceMatrix[indexA][indexB] += weight;

                        // ֻ�ԷǶԽ���Ԫ�ؽ��жԳ����
                        if (indexA != indexB)
                        {
                            // TODO: ����ѹ���洢��
                            g_coOccurrenceMatrix[indexB][indexA] += weight;
                        }
                    }
                }
            }
        }
    }

    /**
     * @brief �������ƶȾ���
     *
     * ʹ���������ƶȹ�ʽ��W_ij = C_ij / sqrt(N_i * N_j)
     * ���� C_ij �ǹ��ִ�����N_i �� N_j �Ǹ��Ա��ղص��ܴ���
     */
    void buildSimilarityMatrix()
    {
        int n = g_products.size();

        // ��ʼ�����ƶȾ���
        g_similarityMatrix.resize(n, std::vector<double>(n, 0.0));

        // �������ƶȾ���
        // �Խ���ֵ�Ѿ��� g_coOccurrenceMatrix �м������
        for (int i = 0; i < n; i++)
        {
            for (int j = i; j < n; j++)
            {
                double similarity = 0.0;

                // ֻ�е�������Ʒ���н�����¼ʱ�ż������ƶ�
                // ʹ�ù��־���ĶԽ���ֵ��Ϊ��һ������
                double D_i = g_coOccurrenceMatrix[i][i]; // ��Ʒi��"�Թ���"ǿ��
                double D_j = g_coOccurrenceMatrix[j][j]; // ��Ʒj��"�Թ���"ǿ��

                if (D_i > 0 && D_j > 0)
                {
                    double denominator = std::sqrt(D_i * D_j);

                    if (i == j)
                    {
                        // �Խ���Ԫ�أ���Ʒ���Լ����������ƶ���Զ��1
                        // D_i / sqrt(D_i * D_i) = D_i / D_i = 1
                        similarity = 1.0;
                    }
                    else
                    {
                        // �ǶԽ���Ԫ�أ�ʹ���������ƶȹ�ʽ
                        // W_ij = C_ij / sqrt(D_i * D_j)
                        double C_ij = g_coOccurrenceMatrix[i][j];
                        similarity = C_ij / denominator;
                    }
                }

                // ���þ���Ԫ�أ����öԳ��ԣ�
                g_similarityMatrix[i][j] = similarity;
                if (i != j)
                {
                    g_similarityMatrix[j][i] = similarity;
                }
            }
        }
    }

    /**
     * @brief Ϊָ���û��Ƽ���Ʒ
     * @param userId �û�ID
     * @param topK �Ƽ���Ʒ������
     * @return �Ƽ�����б�������ƷID���Ƽ������Ķ�
     */
    std::vector<std::pair<int, double>> recommendProducts(int userId, int topK)
    {
        // TODO: ʵ���Ƽ��㷨�߼�
        std::vector<std::pair<int, double>> recommendations;

        return recommendations;
    }

} // namespace Recommender
