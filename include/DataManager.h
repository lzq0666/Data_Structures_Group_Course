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

using json = nlohmann::ordered_json;

//用户数据结构体
struct UserData {
    int userId;
    bool isAdmin;
    std::string username;
    std::string password;
    std::string salt;
    std::vector<std::vector<int> > shoppingCart; // 购物车，二维数组
    std::vector<std::vector<int> > viewHistory; // 浏览历史，二维数组
    std::vector<std::vector<int> > favorites; // 显式评分，二维数组
    //json数据需要以"favorites": [[商品编号，值],...]的形式储存
};

// 商品数据结构体
struct ProductData {
    int productId;
    std::string name;
    double price;
    int stock;
    std::string category;
    double avg_rating; // 平均评分
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

    bool removeUser(const std::string &username);

    UserData *findUser(const std::string &username);

    std::vector<UserData> &getUsers();

    // 商品数据操作
    bool loadProductsFromJson();

    bool saveProductsToJson();

    bool addProduct(const ProductData &product);

    bool removeProduct(int productId);

    ProductData *findProduct(int productId);

    std::vector<ProductData> &getProducts();

    // 购物车相关
    std::vector<CartItemDetails> getShoppingCartDetails(const std::string &username, double &totalPrice,
                                                        int &totalQuantity);

    // 工具函数
    void clearAllData();

private:
    // 数据存储
    std::vector<UserData> users;
    std::vector<ProductData> products;

    // 文件路径
    const std::string USER_DATA_FILE = "./users.json";
    const std::string PRODUCT_DATA_FILE = "./products.json";

    // JSON 转换函数
    json userToJson(const UserData &user);

    UserData jsonToUser(const json &j);

    json productToJson(const ProductData &product);

    ProductData jsonToProduct(const json &j);

    // 文件操作辅助函数
    bool fileExists(const std::string &filename);

    bool createEmptyJsonFile(const std::string &filename);
};

#endif // DATAMANAGER_H