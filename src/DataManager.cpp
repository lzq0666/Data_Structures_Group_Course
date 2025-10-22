#include "DataManager.h"

// 构造函数，初始化时加载用户和商品数据
DataManager::DataManager() {
    // 初始化时尝试加载数据
    loadUsersFromJson();
    loadProductsFromJson();

    // 如果商品数据为空，创建示例数据
    if (products.empty()) {
        createSampleProducts();
    }
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
            qDebug() << "无法打开用户数据文件: " << USER_DATA_FILE;
            return false;
        }

        json j;
        file >> j; // 读取 JSON 数据
        file.close();

        users.clear(); // 清空当前用户列表

        // 把数据存到users容器
        if (j.contains("users") && j["users"].is_array()) {
            for (const auto& userJson : j["users"]) {
                users.push_back(jsonToUser(userJson));
            }
        }

        qDebug() << "成功加载 " << users.size() << " 个用户数据";
        return true;
    }
    catch (const std::exception& e) {
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
        for (const auto& user : users) {
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
            qDebug() << "无法打开用户数据文件进行写入: " << USER_DATA_FILE;
            return false;
        }

        file << j.dump(4); // 格式化输出，缩进4个空格
        file.close();

        qDebug() << "成功保存 " << users.size() << " 个用户数据";
        return true;
    }
    catch (const std::exception& e) {
        std::cerr << "保存用户数据时发生错误: " << e.what() << std::endl;
        return false;
    }
}

// 添加用户
bool DataManager::addUser(const UserData& user) {
    // 检查用户是否已存在
    if (findUser(user.username) != nullptr) {
        qDebug() << "用户已存在: " << user.username;
        return false;
    }

    users.push_back(user);
    qDebug() << "成功添加用户: " << user.username;
    return true;
}

// 删除用户
bool DataManager::removeUser(const std::string& username) {
    auto it = std::find_if(users.begin(), users.end(),
        [&username](const UserData& user) {
            return user.username == username;
        });

    if (it != users.end()) {
        users.erase(it);
        qDebug() << "成功删除用户: " << username;
        return true;
    }

    qDebug() << "未找到用户: " << username;
    return false;
}

// 查找用户
UserData* DataManager::findUser(const std::string& username) {
    auto it = std::find_if(users.begin(), users.end(),
        [&username](const UserData& user) {
            return user.username == username;
        });

    return (it != users.end()) ? &(*it) : nullptr;
}

// 获取所有用户
std::vector<UserData>& DataManager::getUsers() {
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
            qDebug() << "无法打开商品数据文件: " << PRODUCT_DATA_FILE;
            return false;
        }

        json j;
        file >> j; // 读取 JSON 数据
        file.close();

        products.clear(); // 清空当前商品列表

        // 把数据存到products容器
        if (j.contains("products") && j["products"].is_array()) {
            for (const auto& productJson : j["products"]) {
                products.push_back(jsonToProduct(productJson));
            }
        }

        qDebug() << "成功加载 " << products.size() << " 个商品数据";
        return true;
    }
    catch (const std::exception& e) {
        std::cerr << "加载商品数据时发生错误: " << e.what() << std::endl;
        return false;
    }
}

bool DataManager::saveProductsToJson() {
    try {
        json j;
        json productsArray = json::array();

        // JSON 结构序列化逻辑
        for (const auto& product : products) {
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
            qDebug() << "无法打开商品数据文件进行写入: " << PRODUCT_DATA_FILE;
            return false;
        }

        file << j.dump(4); // 格式化输出，缩进4个空格
        file.close();

        qDebug() << "成功保存 " << products.size() << " 个商品数据";
        return true;
    }
    catch (const std::exception& e) {
        std::cerr << "保存商品数据时发生错误: " << e.what() << std::endl;
        return false;
    }
}

bool DataManager::addProduct(const ProductData& product) {
    // 检查商品是否已存在
    if (findProduct(product.productId) != nullptr) {
        qDebug() << "商品已存在，ID: " << product.productId;
        return false;
    }

    products.push_back(product);
    qDebug() << "成功添加商品: " << product.name << " (ID: " << product.productId << ")";
    return true;
}

bool DataManager::removeProduct(int productId) {
    auto it = std::find_if(products.begin(), products.end(),
        [productId](const ProductData& product) {
            return product.productId == productId;
        });

    if (it != products.end()) {
        qDebug() << "成功删除商品: " << it->name << " (ID: " << productId << ")";
        products.erase(it);
        return true;
    }

    qDebug() << "未找到商品，ID: " << productId;
    return false;
}

ProductData* DataManager::findProduct(int productId) {
    auto it = std::find_if(products.begin(), products.end(),
        [productId](const ProductData& product) {
            return product.productId == productId;
        });

    return (it != products.end()) ? &(*it) : nullptr;
}

std::vector<ProductData>& DataManager::getProducts() {
    return products;
}

// ============== 工具函数 ==============

// 清空所有数据（用户和商品）
void DataManager::clearAllData() {
    users.clear(); // 清空用户列表
    products.clear(); // 清空商品列表
    qDebug() << "已清空所有数据";
}

// 创建示例商品数据
void DataManager::createSampleProducts() {
    qDebug() << "创建示例商品数据...";

    std::vector<ProductData> sampleProducts = {
        {1001, "iPhone 15 Pro", 8999.00, 50, "手机", 4.8, 156},
        {1002, "小米14 Ultra", 5999.00, 80, "手机", 4.6, 89},
        {1003, "华为Mate60 Pro", 6999.00, 35, "手机", 4.7, 234},
        {1004, "OPPO Find X7", 4599.00, 60, "手机", 4.5, 67},

        {2001, "MacBook Pro M3", 16999.00, 25, "电脑", 4.9, 78},
        {2002, "ThinkPad X1 Carbon", 12999.00, 40, "电脑", 4.6, 92},
        {2003, "Surface Laptop 5", 9999.00, 30, "电脑", 4.4, 45},
        {2004, "华为MateBook X Pro", 8999.00, 20, "电脑", 4.5, 56},

        {3001, "AirPods Pro", 1999.00, 100, "耳机", 4.7, 289},
        {3002, "Sony WH-1000XM5", 2399.00, 75, "耳机", 4.8, 167},
        {3003, "Bose QC45", 2299.00, 60, "耳机", 4.6, 123},
        {3004, "森海塞尔 HD660S", 3299.00, 25, "耳机", 4.9, 34},

        {4001, "iPad Pro 12.9", 8599.00, 45, "平板", 4.8, 145},
        {4002, "华为MatePad Pro", 3999.00, 55, "平板", 4.5, 78},
        {4003, "小米平板6", 1999.00, 80, "平板", 4.4, 156},
        {4004, "Surface Pro 9", 7999.00, 30, "平板", 4.6, 67},

        {5001, "Apple Watch Ultra 2", 6299.00, 35, "手表", 4.7, 234},
        {5002, "华为Watch GT 4", 1688.00, 70, "手表", 4.5, 189},
        {5003, "小米Watch S1", 999.00, 90, "手表", 4.3, 267},
        {5004, "OPPO Watch 3", 1299.00, 50, "手表", 4.4, 98}
    };

    for (const auto& product : sampleProducts) {
        products.push_back(product);
    }

    qDebug() << "成功创建 " << sampleProducts.size() << " 个示例商品";

    // 保存到文件
    saveProductsToJson();
}

// ============== 私有函数 ==============

// 用户数据结构体序列化为 JSON 对象
json DataManager::userToJson(const UserData& user) {
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
UserData DataManager::jsonToUser(const json& j) {
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
json DataManager::productToJson(const ProductData& product) {
    //商品结构体调整 JSON 序列化
    return json{
        {"productId", product.productId},
        {"name", product.name},
        {"price", product.price},
        {"stock", product.stock},
        {"category", product.category},
        {"avgRating", product.avg_rating},  // 统一使用 avgRating 字段名
        {"reviewers", product.reviewers}
    };
}

// JSON 对象转为商品数据结构体
ProductData DataManager::jsonToProduct(const json& j) {
    ProductData product;

    // 使用 value() 方法提供默认值，避免字段不存在时的错误
    product.productId = j.value("productId", 0);
    product.name = j.value("name", "");
    product.price = j.value("price", 0.0);
    product.stock = j.value("stock", 0);
    product.category = j.value("category", "");
    // 支持两种字段名：avgRating (新) 和 avg_rating (旧)
    if (j.contains("avgRating")) {
        product.avg_rating = j.value("avgRating", 0.0);
    }
    else {
        product.avg_rating = j.value("avg_rating", 0.0);
    }
    product.reviewers = j.value("reviewers", 0);

    return product;
}

// 判断文件是否存在
bool DataManager::fileExists(const std::string& filename) {
    std::ifstream file(filename);
    return file.good();
}

// 创建空的 JSON 文件（用户或商品）
bool DataManager::createEmptyJsonFile(const std::string& filename) {
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
        }
        else if (filename == PRODUCT_DATA_FILE) {
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
            qDebug() << "无法创建文件: " << filename;
            return false;
        }

        file << emptyJson.dump(4);
        file.close();

        qDebug() << "成功创建空的 JSON 文件: " << filename;
        return true;
    }
    catch (const std::exception& e) {
        std::cerr << "创建 JSON 文件时发生错误: " << e.what() << std::endl;
        return false;
    }
}
