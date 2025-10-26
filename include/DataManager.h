#ifndef DATAMANAGER_H
#define DATAMANAGER_H

#include <ctime>
#include <vector>
#include <QDebug>
#include <qlogging.h>
#include <string>
#include <fstream>
#include <iostream>
#include <QString>
#include <nlohmann/json.hpp>
#include <algorithm>
#include <cctype>

using json = nlohmann::ordered_json;

//用户数据结构体
struct UserData {
    int userId;
    bool isAdmin;
    std::string username;
    std::string password;
    std::string salt;
    std::vector<std::vector<int> > shoppingCart; // 购物车，二维数组 [[商品ID, 数量], ...]
    std::vector<std::vector<int> > viewHistory; // 浏览历史，二维数组 [[商品ID, 浏览次数], ...]
    std::vector<std::vector<int> > favorites; // 收藏/评分，二维数组 [[商品ID, 评分值], ...]
    // JSON数据需要以"favorites": [[商品编号，评分值],...]的形式储存
    // viewHistory 记录用户浏览商品的次数，用于推荐算法
    // shoppingCart 记录用户购物车中的商品和数量
};

// 商品数据结构体
struct ProductData {
    int productId;
    std::string name;
    double price;
    int stock;
    std::string category;
    double avgRating; // 平均评分 - 与JSON字段名保持一致
    int reviewers; // 评分人数
};

// 购物车展示项结构体
struct CartItemDetails {
    int productId;
    std::string name;
    int quantity;
    double unitPrice;
    double subtotal;
};

class DataManager {
public:
    // 构造函数
    DataManager();

    // 析构函数
    ~DataManager();

    // 用户数据操作
    bool loadUsersFromJson();
    bool saveUsersToJson();
    bool addUser(const UserData &user);
    UserData *findUser(const std::string &username);
    std::vector<UserData> &getUsers();

    // 商品数据操作
    bool loadProductsFromJson();
    bool saveProductsToJson();
    ProductData *findProduct(int productId);
    std::vector<ProductData> &getProducts();

    // 商品筛选与搜索功能（保留常用的）
    [[nodiscard]] std::vector<ProductData> searchProducts(const std::string &keyword) const;
    [[nodiscard]] std::vector<ProductData> filterByCategory(const std::string &category) const;

    // 购物车相关
    std::vector<CartItemDetails> getShoppingCartDetails(const std::string &username, double &totalPrice,
                                                        int &totalQuantity);

    // 用户行为相关方法
    bool addToCart(const std::string &username, int productId, int quantity);
    bool removeFromCart(const std::string &username, int productId);
    bool updateCartQuantity(const std::string &username, int productId, int newQuantity);
    bool addViewHistory(const std::string &username, int productId);
    bool addToFavorites(const std::string &username, int productId, int rating);
    bool removeFromFavorites(const std::string &username, int productId);

    // 评价相关方法
    bool rateProduct(const std::string& username, int productId, int rating);
    bool updateProductRating(int productId, int newRating, int oldRating = -1);

private:
    // 数据存储
    std::vector<UserData> users;
    std::vector<ProductData> products;

    // JSON 文件路径解析（统一定位到程序目录或上级 bin 目录）
    [[nodiscard]] std::string userFile() const;
    [[nodiscard]] std::string productFile() const;

    // JSON 转换函数
    json userToJson(const UserData &user);
    UserData jsonToUser(const json &j);
    json productToJson(const ProductData &product);
    ProductData jsonToProduct(const json &j);

    // 文件操作辅助函数
    bool fileExists(const std::string &filename);
    bool createEmptyJsonFile(const std::string &filename);

    // 辅助函数：在二维数组中查找并更新项目
    bool updateItemInVector(std::vector<std::vector<int> > &vec, int productId, int newValue);
    bool removeItemFromVector(std::vector<std::vector<int> > &vec, int productId);

    // 搜索与筛选辅助函数
    [[nodiscard]] std::string toLowercase(const std::string &str) const;
    [[nodiscard]] bool containsKeyword(const std::string &text, const std::string &keyword) const;
};

#endif // DATAMANAGER_H