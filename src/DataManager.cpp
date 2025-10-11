#include "DataManager.h"

// 构造函数，初始化时加载用户和商品数据
DataManager::DataManager() {
    // 初始化时尝试加载数据
    loadUsersFromJson();
    loadProductsFromJson();
}

// 析构函数，销毁对象时保存用户和商品数据
DataManager::~DataManager() {
    // 析构时保存数据
    saveUsersToJson();
    saveProductsToJson();
}

// ============== 用户数据操作 ==============

// 从 JSON 文件加载用户数据
bool DataManager::loadUsersFromJson() {
    try {
        // 如果用户数据文件不存在，则创建新文件
        if (!fileExists(USER_DATA_FILE)) {
            qDebug() << "用户数据文件不存在，创建新文件: " << USER_DATA_FILE;
            return createEmptyJsonFile(USER_DATA_FILE);
        }

        // 打开用户数据文件
        std::ifstream file(USER_DATA_FILE);
        if (!file.is_open()) {
            std::cerr << "无法打开用户数据文件: " << USER_DATA_FILE << std::endl;
            return false;
        }

        json j;
        file >> j; // 读取 JSON 数据
        file.close();

        users.clear(); // 清空当前用户列表

        // 把数据存到users容器
        if (j.contains("users") && j["users"].is_array()) {
            for (const auto &userJson: j["users"]) {
                users.push_back(jsonToUser(userJson));
            }
        }

        qDebug() << "成功加载 " << users.size() << " 个用户数据";
        return true;
    } catch (const std::exception &e) {
        qDebug() << "加载用户数据时发生错误: " << e.what();
        return false;
    }
}

// 保存用户数据到 JSON 文件
bool DataManager::saveUsersToJson() {
    try {
        json j;
        json usersArray = json::array();

        // 把users容器的数据序列化为json对象
        for (const auto &user: users) {
            usersArray.push_back(userToJson(user));
        }

        j["users"] = usersArray;
        std::time_t t = std::time(nullptr); // 获取当前时间
        j["metadata"] = {
            {"version", "1.0"},
            {"lastUpdated", t},
            {"totalUsers", users.size()}
        };

        // 打开文件进行写入
        std::ofstream file(USER_DATA_FILE);
        if (!file.is_open()) {
            std::cerr << "无法打开用户数据文件进行写入: " << USER_DATA_FILE << std::endl;
            return false;
        }

        file << j.dump(4); // 格式化输出，缩进4个空格
        file.close();

        qDebug() << "成功保存 " << users.size() << " 个用户数据";
        return true;
    } catch (const std::exception &e) {
        std::cerr << "保存用户数据时发生错误: " << e.what() << std::endl;
        return false;
    }
}

// 添加用户
bool DataManager::addUser(const UserData &user) {
    // 检查用户是否已存在
    if (findUser(user.username) != nullptr) {
        std::cerr << "用户已存在: " << user.username << std::endl;
        return false;
    }

    users.push_back(user);
    qDebug() << "成功添加用户: " << user.username;
    return true;
}

// 删除用户
bool DataManager::removeUser(const std::string &username) {
    auto it = std::find_if(users.begin(), users.end(),
                           [&username](const UserData &user) {
                               return user.username == username;
                           });

    if (it != users.end()) {
        users.erase(it);
        qDebug() << "成功删除用户: " << username;
        return true;
    }

    std::cerr << "未找到用户: " << username << std::endl;
    return false;
}

// 查找用户
UserData *DataManager::findUser(const std::string &username) {
    auto it = std::find_if(users.begin(), users.end(),
                           [&username](const UserData &user) {
                               return user.username == username;
                           });

    return (it != users.end()) ? &(*it) : nullptr;
}

// 获取所有用户
std::vector<UserData> &DataManager::getUsers() {
    return users;
}

// ============== 商品数据操作 ==============

bool DataManager::loadProductsFromJson() {
    try {
        // 如果商品数据文件不存在，则创建新文件
        if (!fileExists(PRODUCT_DATA_FILE)) {
            qDebug() << "商品数据文件不存在，创建新文件: " << PRODUCT_DATA_FILE;
            return createEmptyJsonFile(PRODUCT_DATA_FILE);
        }

        // 打开商品数据文件
        std::ifstream file(PRODUCT_DATA_FILE);
        if (!file.is_open()) {
            std::cerr << "无法打开商品数据文件: " << PRODUCT_DATA_FILE << std::endl;
            return false;
        }

        json j;
        file >> j; // 读取 JSON 数据
        file.close();

        products.clear(); // 清空当前商品列表

        // 把数据存到products容器
        if (j.contains("products") && j["products"].is_array()) {
            for (const auto &productJson: j["products"]) {
                products.push_back(jsonToProduct(productJson));
            }
        }

        qDebug() << "成功加载 " << products.size() << " 个商品数据";
        return true;
    } catch (const std::exception &e) {
        std::cerr << "加载商品数据时发生错误: " << e.what() << std::endl;
        return false;
    }
}

bool DataManager::saveProductsToJson() {
    try {
        json j;
        json productsArray = json::array();

        // JSON 结构序列化逻辑
        for (const auto &product: products) {
            productsArray.push_back(productToJson(product));
        }

        j["products"] = productsArray;
        std::time_t t = std::time(nullptr); // 获取当前时间
        j["metadata"] = {
            {"version", "1.0"},
            {"lastUpdated", t},
            {"totalProducts", products.size()}
        };

        // 打开文件进行写入
        std::ofstream file(PRODUCT_DATA_FILE);
        if (!file.is_open()) {
            std::cerr << "无法打开商品数据文件进行写入: " << PRODUCT_DATA_FILE << std::endl;
            return false;
        }

        file << j.dump(4); // 格式化输出，缩进4个空格
        file.close();

        qDebug() << "成功保存 " << products.size() << " 个商品数据";
        return true;
    } catch (const std::exception &e) {
        std::cerr << "保存商品数据时发生错误: " << e.what() << std::endl;
        return false;
    }
}

bool DataManager::addProduct(const ProductData &product) {
    // 检查商品是否已存在
    if (findProduct(product.productId) != nullptr) {
        std::cerr << "商品已存在，ID: " << product.productId << std::endl;
        return false;
    }

    products.push_back(product);
    qDebug() << "成功添加商品: " << product.name << " (ID: " << product.productId << ")";
    return true;
}

bool DataManager::removeProduct(int productId) {
    auto it = std::find_if(products.begin(), products.end(),
                           [productId](const ProductData &product) {
                               return product.productId == productId;
                           });

    if (it != products.end()) {
        qDebug() << "成功删除商品: " << it->name << " (ID: " << productId << ")";
        products.erase(it);
        return true;
    }

    std::cerr << "未找到商品，ID: " << productId << std::endl;
    return false;
}

ProductData *DataManager::findProduct(int productId) {
    auto it = std::find_if(products.begin(), products.end(),
                           [productId](const ProductData &product) {
                               return product.productId == productId;
                           });

    return (it != products.end()) ? &(*it) : nullptr;
}

std::vector<ProductData> &DataManager::getProducts() {
    return products;
}

// ============== 工具函数 ==============

// 清空所有数据（用户和商品）
void DataManager::clearAllData() {
    users.clear(); // 清空用户列表
    products.clear(); // 清空商品列表
    qDebug() << "已清空所有数据";
}

// ============== 私有函数 ==============

// 用户数据结构体序列化为 JSON 对象
json DataManager::userToJson(const UserData &user) {
    return json{
        {"userId", user.userId},
        {"username", user.username},
        {"password", user.password},
        {"salt", user.salt},
        {"isAdmin", user.isAdmin},
        {"shoppingCart", user.shoppingCart},
        {"viewHistory", user.viewHistory},
        {"favorites", user.favorites}
    };
}

// JSON 对象转为用户数据结构体
UserData DataManager::jsonToUser(const json &j) {
    UserData user;

    // 使用 value() 方法提供默认值，避免字段不存在时的错误
    user.username = j.value("username", "");
    user.password = j.value("password", "");
    user.userId = j.value("userId", 0);
    user.isAdmin = j.value("isAdmin", false);
    user.salt = j.value("salt", "");
    user.shoppingCart = j.at("shoppingCart").get<std::vector<std::vector<int> > >();
    user.viewHistory = j.at("viewHistory").get<std::vector<std::vector<int> > >();
    user.favorites = j.at("favorites").get<std::vector<std::vector<int> > >();
    //json数据需要以"favorites": [[商品编号，值],...]的形式储存
    return user;
}

// 商品数据结构体转为 JSON 对象
json DataManager::productToJson(const ProductData &product) {
    //商品结构体调整 JSON 序列化
    return json{
        {"productId", product.productId},
        {"name", product.name},
        {"price", product.price},
        {"stock", product.stock},
        {"category", product.category},
        {"avg_rating", product.avg_rating},
        {"reviewers", product.reviewers}
    };
}

// JSON 对象转为商品数据结构体
ProductData DataManager::jsonToProduct(const json &j) {
    ProductData product;

    // 使用 value() 方法提供默认值，避免字段不存在时的错误
    product.productId = j.value("productId", 0);
    product.name = j.value("name", "");
    product.price = j.value("price", 0.0);
    product.stock = j.value("stock", 0);
    product.category = j.value("category", "");
    product.avg_rating = j.value("avg_rating", 0.0);
    product.reviewers = j.value("reviewers", 0);

    return product;
}

// 判断文件是否存在
bool DataManager::fileExists(const std::string &filename) {
    std::ifstream file(filename);
    return file.good();
}

// 创建空的 JSON 文件（用户或商品）
bool DataManager::createEmptyJsonFile(const std::string &filename) {
    try {
        json emptyJson;
        std::time_t t = std::time(nullptr); // 获取当前时间
        if (filename == USER_DATA_FILE) {
            emptyJson = {
                {"users", json::array()},
                {
                    "metadata", {
                        {"version", "1.0"},
                        {"lastUpdated", t},
                        {"totalUsers", 0}
                    }
                }
            };
        } else if (filename == PRODUCT_DATA_FILE) {
            emptyJson = {
                {"products", json::array()},
                {
                    "metadata", {
                        {"version", "1.0"},
                        {"lastUpdated", t},
                        {"totalProducts", 0}
                    }
                }
            };
        }

        std::ofstream file(filename);
        if (!file.is_open()) {
            std::cerr << "无法创建文件: " << filename << std::endl;
            return false;
        }

        file << emptyJson.dump(4);
        file.close();

        qDebug() << "成功创建空的 JSON 文件: " << filename;
        return true;
    } catch (const std::exception &e) {
        std::cerr << "创建 JSON 文件时发生错误: " << e.what() << std::endl;
        return false;
    }
}