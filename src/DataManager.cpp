#include "DataManager.h"
#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>

// 构造函数，初始化时加载用户和商品数据
DataManager::DataManager() {
    // 初始化时尝试加载数据
    loadUsersFromJson();
    loadProductsFromJson();
}

// 析构函数，销毁对象时不再自动保存，避免多个实例按退出顺序覆盖文件
DataManager::~DataManager() {
    // 不在析构中保存，统一由显式的 saveUsersToJson/saveProductsToJson 调用持久化
}

// 新增：返回用户/商品 JSON 文件的绝对路径（相对于程序目录）
std::string DataManager::userFile() const {
    QString appDir = QCoreApplication::applicationDirPath();
    // 1) 项目根/bin/users.json（常见目录结构：<root>/cmake-build-*/ 可执行; <root>/bin 数据）
    QString parentBin = QDir(QDir(appDir).filePath("../bin")).absoluteFilePath("users.json");
    // 2) 可执行同目录/bin/users.json（如果可执行和 bin 在同级）
    QString inBinSame = QDir(appDir).filePath("bin/users.json");
    // 3) 可执行同目录/users.json
    QString primary = QDir(appDir).filePath("users.json");

    if (QFileInfo::exists(parentBin)) return parentBin.toStdString();
    if (QFileInfo::exists(inBinSame)) return inBinSame.toStdString();
    if (QFileInfo::exists(primary)) return primary.toStdString();

    // 文件不存在时，优先创建在项目根/bin 下（如果能创建目录）
    return parentBin.toStdString();
}

std::string DataManager::productFile() const {
    QString appDir = QCoreApplication::applicationDirPath();
    QString parentBin = QDir(QDir(appDir).filePath("../bin")).absoluteFilePath("products.json");
    QString inBinSame = QDir(appDir).filePath("bin/products.json");
    QString primary = QDir(appDir).filePath("products.json");

    if (QFileInfo::exists(parentBin)) return parentBin.toStdString();
    if (QFileInfo::exists(inBinSame)) return inBinSame.toStdString();
    if (QFileInfo::exists(primary)) return primary.toStdString();

    return parentBin.toStdString();
}

// ============== 用户数据操作 ==============

// 从 JSON 文件加载用户数据
bool DataManager::loadUsersFromJson() {
    try {
        const std::string path = userFile();
        // 如果用户数据文件不存在，则创建新文件
        if (!fileExists(path)) {
            qDebug() << "用户数据文件不存在，创建新文件: " << QString::fromStdString(path);
            return createEmptyJsonFile(path);
        }

        // 打开用户数据文件
        std::ifstream file(path);
        if (!file.is_open()) {
            std::cerr << "无法打开用户数据文件: " << path << std::endl;
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
        const std::string path = userFile();
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

        // 确保目录存在
        QFileInfo fi(QString::fromStdString(path));
        QDir().mkpath(fi.absolutePath());

        // 打开文件进行写入
        std::ofstream file(path);
        if (!file.is_open()) {
            std::cerr << "无法打开用户数据文件进行写入: " << path << std::endl;
            return false;
        }

        file << j.dump(4); // 格式化输出，缩进4个空格
        file.close();

        qDebug() << "成功保存 " << users.size() << " 个用户数据 => " << QString::fromStdString(path);
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
        std::cerr << "用户已存在: " << user.username << std::endl;
        return false;
    }

    users.push_back(user);
    qDebug() << "成功添加用户: " << user.username;
    return true;
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
        const std::string path = productFile();
        // 如果商品数据文件不存在，则创建新文件
        if (!fileExists(path)) {
            qDebug() << "商品数据文件不存在，创建新文件: " << QString::fromStdString(path);
            return createEmptyJsonFile(path);
        }

        // 打开商品数据文件
        std::ifstream file(path);
        if (!file.is_open()) {
            std::cerr << "无法打开商品数据文件: " << path << std::endl;
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
        const std::string path = productFile();
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

        // 确保目录存在
        QFileInfo fi(QString::fromStdString(path));
        QDir().mkpath(fi.absolutePath());

        // 打开文件进行写入
        std::ofstream file(path);
        if (!file.is_open()) {
            std::cerr << "无法打开商品数据文件进行写入: " << path << std::endl;
            return false;
        }

        file << j.dump(4); // 格式化输出，缩进4个空格
        file.close();

        qDebug() << "成功保存 " << products.size() << " 个商品数据 => " << QString::fromStdString(path);
        return true;
    }
    catch (const std::exception& e) {
        std::cerr << "保存商品数据时发生错误: " << e.what() << std::endl;
        return false;
    }
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

// ============== 商品筛选与搜索功能 ==============

// 关键词搜索
std::vector<ProductData> DataManager::searchProducts(const std::string& keyword) const {
    std::vector<ProductData> results;

    if (keyword.empty()) {
        return products; // 如果没有关键词，返回所有商品
    }

    std::string lowercaseKeyword = toLowercase(keyword);

    for (const auto& product : products) {
        if (containsKeyword(product.name, lowercaseKeyword) ||
            containsKeyword(product.category, lowercaseKeyword)) {
            results.push_back(product);
        }
    }

    qDebug() << "关键词搜索 '" << QString::fromStdString(keyword) << "' 找到 " << results.size() << " 个商品";
    return results;
}

// 按分类筛选
std::vector<ProductData> DataManager::filterByCategory(const std::string& category) const {
    std::vector<ProductData> results;

    if (category.empty() || category == "全部") {
        return products; // 如果没有指定分类或选择全部，返回所有商品
    }

    for (const auto& product : products) {
        if (product.category == category) {
            results.push_back(product);
        }
    }

    qDebug() << "分类筛选 '" << QString::fromStdString(category) << "' 找到 " << results.size() << " 个商品";
    return results;
}

std::vector<CartItemDetails> DataManager::
getShoppingCartDetails(const std::string& username, double& totalPrice, int& totalQuantity) {
    totalPrice = 0.0;
    totalQuantity = 0;
    std::vector<CartItemDetails> items;

    UserData* user = findUser(username);
    if (!user) {
        qDebug() << "未找到用户:" << QString::fromStdString(username);
        return items;
    }

    for (const auto& entry : user->shoppingCart) {
        if (entry.size() < 2) {
            continue;
        }

        int productId = entry[0];
        int quantity = entry[1];
        if (quantity <= 0) {
            continue;
        }

        CartItemDetails item{};
        item.productId = productId;
        item.quantity = quantity;

        ProductData* product = findProduct(productId);
        if (product) {
            item.name = product->name;
            item.unitPrice = product->price;
        }
        else {
            item.name = "未知商品";
            item.unitPrice = 0.0;
            qDebug() << "购物车中存在未找到的商品ID:" << productId;
        }

        item.subtotal = item.unitPrice * static_cast<double>(item.quantity);

        totalPrice += item.subtotal;
        totalQuantity += item.quantity;

        items.push_back(item);
    }

    return items;
}

// ============== 用户行为相关方法 ==============

bool DataManager::addToCart(const std::string& username, int productId, int quantity) {
    UserData* user = findUser(username);
    if (!user) {
        qDebug() << "未找到用户:" << QString::fromStdString(username);
        return false;
    }

    // 检查商品是否存在
    if (!findProduct(productId)) {
        qDebug() << "商品不存在，ID:" << productId;
        return false;
    }

    // 检查购物车中是否已有该商品
    bool found = false;
    for (auto& entry : user->shoppingCart) {
        if (entry.size() >= 2 && entry[0] == productId) {
            entry[1] += quantity; // 累加数量而不是替换
            found = true;
            qDebug() << "更新购物车商品数量，用户:" << QString::fromStdString(username)
                << "商品ID:" << productId << "新数量:" << entry[1];
            break;
        }
    }

    if (!found) {
        // 添加新商品到购物车
        user->shoppingCart.push_back({ productId, quantity });
        qDebug() << "添加商品到购物车，用户:" << QString::fromStdString(username)
            << "商品ID:" << productId << "数量:" << quantity;
    }

    return true;
}

bool DataManager::removeFromCart(const std::string& username, int productId) {
    UserData* user = findUser(username);
    if (!user) {
        qDebug() << "未找到用户:" << QString::fromStdString(username);
        return false;
    }

    if (removeItemFromVector(user->shoppingCart, productId)) {
        qDebug() << "从购物车移除商品，用户:" << QString::fromStdString(username) << "商品ID:" << productId;
        return true;
    }

    qDebug() << "购物车中未找到商品，用户:" << QString::fromStdString(username) << "商品ID:" << productId;
    return false;
}

bool DataManager::updateCartQuantity(const std::string& username, int productId, int newQuantity) {
    if (newQuantity <= 0) {
        return removeFromCart(username, productId);
    }

    UserData* user = findUser(username);
    if (!user) {
        qDebug() << "未找到用户:" << QString::fromStdString(username);
        return false;
    }

    // 检查商品是否存在
    if (!findProduct(productId)) {
        qDebug() << "商品不存在，ID:" << productId;
        return false;
    }

    // 直接设置新数量（不累加）
    if (updateItemInVector(user->shoppingCart, productId, newQuantity)) {
        qDebug() << "更新购物车商品数量（直接设置），用户:" << QString::fromStdString(username)
            << "商品ID:" << productId << "数量:" << newQuantity;
        return true;
    }
    else {
        // 如果商品不在购物车中，添加新商品
        user->shoppingCart.push_back({ productId, newQuantity });
        qDebug() << "添加商品到购物车（通过更新数量），用户:" << QString::fromStdString(username)
            << "商品ID:" << productId << "数量:" << newQuantity;
        return true;
    }
}

bool DataManager::addViewHistory(const std::string& username, int productId) {
    UserData* user = findUser(username);
    if (!user) {
        qDebug() << "未找到用户:" << QString::fromStdString(username);
        return false;
    }

    // 检查商品是否存在
    if (!findProduct(productId)) {
        qDebug() << "商品不存在，ID:" << productId;
        return false;
    }

    // 查找是否已有浏览记录
    bool found = false;
    for (auto& entry : user->viewHistory) {
        if (entry.size() >= 2 && entry[0] == productId) {
            entry[1]++; // 增加浏览次数
            found = true;
            break;
        }
    }

    if (!found) {
        // 添加新的浏览记录
        user->viewHistory.push_back({ productId, 1 });
    }

    qDebug() << "添加浏览历史，用户:" << QString::fromStdString(username) << "商品ID:" << productId;
    return true;
}

bool DataManager::addToFavorites(const std::string& username, int productId, int rating) {
    UserData* user = findUser(username);
    if (!user) {
        qDebug() << "未找到用户:" << QString::fromStdString(username);
        return false;
    }

    // 检查商品是否存在
    if (!findProduct(productId)) {
        qDebug() << "商品不存在，ID:" << productId;
        return false;
    }

    // 检查评分有效性（假设1-5分）
    if (rating < 1 || rating > 5) {
        qDebug() << "评分无效:" << rating;
        return false;
    }

    // 检查收藏中是否已有该商品
    if (updateItemInVector(user->favorites, productId, rating)) {
        qDebug() << "更新收藏商品评分，用户:" << QString::fromStdString(username) << "商品ID:" << productId << "评分:" << rating;
    }
    else {
        // 添加新商品到收藏
        user->favorites.push_back({ productId, rating });
        qDebug() << "添加商品到收藏，用户:" << QString::fromStdString(username) << "商品ID:" << productId << "评分:" << rating;
    }

    return true;
}

bool DataManager::removeFromFavorites(const std::string& username, int productId) {
    UserData* user = findUser(username);
    if (!user) {
        qDebug() << "未找到用户:" << QString::fromStdString(username);
        return false;
    }

    if (removeItemFromVector(user->favorites, productId)) {
        qDebug() << "从收藏移除商品，用户:" << QString::fromStdString(username) << "商品ID:" << productId;
        return true;
    }

    qDebug() << "收藏中未找到商品，用户:" << QString::fromStdString(username) << "商品ID:" << productId;
    return false;
}

// 评价商品并更新用户收藏和商品评分
bool DataManager::rateProduct(const std::string& username, int productId, int rating) {
    // 检查评分有效性
    if (rating < 0 || rating > 5) {
        qDebug() << "评分无效，必须在0-5之间:" << rating;
        return false;
    }

    UserData* user = findUser(username);
    if (!user) {
        qDebug() << "未找到用户:" << QString::fromStdString(username);
        return false;
    }

    ProductData* product = findProduct(productId);
    if (!product) {
        qDebug() << "商品不存在，ID:" << productId;
        return false;
    }

    // 查找用户之前的评分
    int oldRating = -1;
    for (const auto& entry : user->favorites) {
        if (entry.size() >= 2 && entry[0] == productId) {
            oldRating = entry[1];
            break;
        }
    }

    // 更新商品评分
    if (!updateProductRating(productId, rating, oldRating)) {
        return false;
    }

    // 更新用户收藏中的评分
    return addToFavorites(username, productId, rating);
}

// 更新商品评分信息
bool DataManager::updateProductRating(int productId, int newRating, int oldRating) {
    ProductData* product = findProduct(productId);
    if (!product) {
        qDebug() << "商品不存在，ID:" << productId;
        return false;
    }

    // 如果是新评分（oldRating = -1）
    if (oldRating == -1) {
        // 新用户评分：更新平均评分和评价人数
        double totalRating = product->avgRating * product->reviewers + newRating;
        product->reviewers += 1;
        product->avgRating = totalRating / product->reviewers;
    }
    else {
        // 更新已有评分：减去旧评分，加上新评分
        double totalRating = product->avgRating * product->reviewers - oldRating + newRating;
        product->avgRating = totalRating / product->reviewers;
    }

    qDebug() << "更新商品评分，ID:" << productId
        << "新评分:" << newRating
        << "旧评分:" << oldRating
        << "平均分:" << product->avgRating
        << "评价人数:" << product->reviewers;

    return true;
}

// ============== 工具函数 ==============

// 辅助函数：在二维数组中查找并更新项目
bool DataManager::updateItemInVector(std::vector<std::vector<int> >& vec, int productId, int newValue) {
    for (auto& entry : vec) {
        if (entry.size() >= 2 && entry[0] == productId) {
            entry[1] = newValue;
            return true;
        }
    }
    return false;
}

// 辅助函数：从二维数组中移除项目
bool DataManager::removeItemFromVector(std::vector<std::vector<int> >& vec, int productId) {
    auto it = std::find_if(vec.begin(), vec.end(),
        [productId](const std::vector<int>& entry) {
            return entry.size() >= 2 && entry[0] == productId;
        });

    if (it != vec.end()) {
        vec.erase(it);
        return true;
    }
    return false;
}

// ============== 搜索与筛选辅助函数 ==============

// 转换为小写字母
std::string DataManager::toLowercase(const std::string& str) const {
    std::string result = str;
    std::transform(result.begin(), result.end(), result.begin(),
        [](unsigned char c) { return std::tolower(c); });
    return result;
}

// 检查文本是否包含关键词（不区分大小写）
bool DataManager::containsKeyword(const std::string& text, const std::string& keyword) const {
    if (keyword.empty()) {
        return true;
    }

    std::string lowercaseText = toLowercase(text);
    return lowercaseText.find(keyword) != std::string::npos;
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
    user.shoppingCart = j.value("shoppingCart", std::vector<std::vector<int> >());
    user.viewHistory = j.value("viewHistory", std::vector<std::vector<int> >());
    user.favorites = j.value("favorites", std::vector<std::vector<int> >());

    return user;
}

// 商品数据结构体转为 JSON 对象
json DataManager::productToJson(const ProductData& product) {
    // 统一使用 avgRating 字段名与JSON保持一致
    return json{
        {"productId", product.productId},
        {"name", product.name},
        {"price", product.price},
        {"stock", product.stock},
        {"category", product.category},
        {"avgRating", product.avgRating}, // 使用修正后的字段名
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
    // 统一使用 avgRating 字段名
    product.avgRating = j.value("avgRating", 0.0);
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

        QFileInfo fi(QString::fromStdString(filename));
        QString base = fi.fileName();
        if (base.compare("users.json", Qt::CaseInsensitive) == 0) {
            emptyJson = {
                {"users", json::array()},
                {"metadata", {{"version", "1.0"}, {"lastUpdated", t}, {"totalUsers", 0}}}
            };
        }
        else if (base.compare("products.json", Qt::CaseInsensitive) == 0) {
            emptyJson = {
                {"products", json::array()},
                {"metadata", {{"version", "1.0"}, {"lastUpdated", t}, {"totalProducts", 0}}}
            };
        }
        else {
            // 默认按 users 结构
            emptyJson = {
                {"users", json::array()},
                {"metadata", {{"version", "1.0"}, {"lastUpdated", t}, {"totalUsers", 0}}}
            };
        }

        // 确保目录存在
        QDir().mkpath(fi.absolutePath());

        std::ofstream file(filename);
        if (!file.is_open()) {
            std::cerr << "无法创建文件: " << filename << std::endl;
            return false;
        }

        file << emptyJson.dump(4);
        file.close();

        qDebug() << "成功创建空的 JSON 文件: " << QString::fromStdString(filename);
        return true;
    }
    catch (const std::exception& e) {
        std::cerr << "创建 JSON 文件时发生错误: " << e.what() << std::endl;
        return false;
    }
}