#include <QtGui/QGuiApplication>
#include <QtQml>
#include "StateManager.h"
#include "DataManager.h"
#include "UserManager.h"
#include "Login.h"

// 将 C++ 状态管理函数封装为 QML 可调用的类
class StateManagerWrapper : public QObject {
    Q_OBJECT

public:
    // 枚举声明
    enum State {
        STATE_LOGIN = 0,
        STATE_REGISTER = 1,
        STATE_MAIN_MENU = 2,
        STATE_BROWSE = 3,
        STATE_ADMIN = 4,
        STATE_EXIT = 5,
        STATE_USER_INFO = 6,
        STATE_CHANGE_PASSWORD = 7,
        STATE_RECOMMENDATION = 8,
        STATE_USER_MANAGEMENT = 9,
        STATE_PRODUCT_MANAGEMENT = 10,
        STATE_DATA_IMPORT = 11,
        STATE_SHOPPING_CART = 12,
        STATE_PRODUCT_DETAIL = 13
    };

    Q_ENUM(State)

        // 构造函数，初始化数据管理器
        StateManagerWrapper(QObject* parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE bool login(const QString& username, const QString& password) {
        bool result = ::loginWithStateUpdate(username.toStdString(), password.toStdString());
        if (result) {
            emit stateChanged(getCurrentState());
        }
        return result;
    }

    Q_INVOKABLE bool registerUser(const QString& username, const QString& password) {
        return ::registerUser(username.toStdString(), password.toStdString());
    }

    Q_INVOKABLE bool userExists(const QString& username) {
        return ::userExists(username.toStdString());
    }

    Q_INVOKABLE bool changePassword(const QString& oldPassword, const QString& newPassword) {
        QString currentUser = getCurrentUser();
        if (currentUser.isEmpty()) {
            return false;
        }
        return ::changePassword(currentUser.toStdString(), oldPassword.toStdString(), newPassword.toStdString());
    }

    Q_INVOKABLE void logout() {
        ::logout();
        emit stateChanged(getCurrentState());
    }

    Q_INVOKABLE bool isLoggedIn() {
        return ::isUserLoggedIn();
    }

    Q_INVOKABLE QString getCurrentUser() {
        return ::getCurrentUser();
    }

    // 添加新方法以兼容 QML 中的调用
    Q_INVOKABLE QString getCurrentUsername() {
        return getCurrentUser();
    }

    Q_INVOKABLE int getCurrentState() {
        return static_cast<int>(::getCurrentState());
    }

    Q_INVOKABLE void setState(int state) {
        ::setState(static_cast<AppState>(state));
        emit stateChanged(getCurrentState());
    }

    Q_INVOKABLE bool isCurrentUserAdmin() {
        QString currentUser = getCurrentUser();
        if (!currentUser.isEmpty()) {
            return ::isCurrentUserAdmin(currentUser.toStdString());
        }
        return false;
    }

    // 新增：获取用户对商品的评分
    Q_INVOKABLE int getUserProductRating(int productId) {
        QString currentUser = getCurrentUser();
        if (currentUser.isEmpty()) {
            return -1;
        }

        DataManager dataManager;
        UserData* user = dataManager.findUser(currentUser.toStdString());
        if (!user) {
            return -1;
        }

        // 在用户的 favorites 中查找该商品的评分
        // favorites 格式: [[productId, rating], ...]
        for (const auto& entry : user->favorites) {
            if (entry.size() >= 2 && entry[0] == productId) {
                return entry[1]; // 返回评分
            }
        }

        return -1; // 未找到评分
    }

    // 获取用户统计数据 - 修正浏览历史统计逻辑
    Q_INVOKABLE QVariantMap getUserStats() {
        QVariantMap stats;
        QString currentUser = getCurrentUser();

        if (currentUser.isEmpty()) {
            stats["cartItemCount"] = 0;
            stats["historyItemCount"] = 0;
            stats["favoritesCount"] = 0;
            return stats;
        }

        DataManager dataManager;
        UserData* user = dataManager.findUser(currentUser.toStdString());

        if (user) {
            // 计算购物车商品数量（所有商品的数量总和）
            int cartItemCount = 0;
            for (const auto& entry : user->shoppingCart) {
                if (entry.size() >= 2) {
                    cartItemCount += entry[1];  // entry[1] 是数量
                }
            }

            // 计算浏览历史总次数（累加每个商品的浏览次数）
            int historyItemCount = 0;
            for (const auto& entry : user->viewHistory) {
                if (entry.size() >= 2) {
                    historyItemCount += entry[1];  // entry[1] 是浏览次数
                }
            }

            // 计算收藏商品数量
            int favoritesCount = user->favorites.size();

            stats["cartItemCount"] = cartItemCount;
            stats["historyItemCount"] = historyItemCount;
            stats["favoritesCount"] = favoritesCount;
        }
        else {
            stats["cartItemCount"] = 0;
            stats["historyItemCount"] = 0;
            stats["favoritesCount"] = 0;
        }

        return stats;
    }

    // 添加购物车操作方法 - 修改：添加自动保存
    Q_INVOKABLE bool addToCart(int productId, int quantity) {
        QString currentUser = getCurrentUser();
        if (currentUser.isEmpty()) {
            qDebug() << "用户未登录，无法添加到购物车";
            return false;
        }

        DataManager dataManager;
        bool success = dataManager.addToCart(currentUser.toStdString(), productId, quantity);
        
        if (success) {
            // 立即保存用户数据
            bool saved = dataManager.saveUsersToJson();
            qDebug() << "添加购物车成功 - 保存到文件:" << (saved ? "成功" : "失败");
        }
        
        return success;
    }

    Q_INVOKABLE bool removeFromCart(int productId) {
        QString currentUser = getCurrentUser();
        if (currentUser.isEmpty()) {
            qDebug() << "用户未登录，无法从购物车移除";
            return false;
        }

        DataManager dataManager;
        bool success = dataManager.removeFromCart(currentUser.toStdString(), productId);
        
        if (success) {
            // 立即保存用户数据
            bool saved = dataManager.saveUsersToJson();
            qDebug() << "从购物车移除成功 - 保存到文件:" << (saved ? "成功" : "失败");
        }
        
        return success;
    }

    Q_INVOKABLE bool updateCartQuantity(int productId, int newQuantity) {
        QString currentUser = getCurrentUser();
        if (currentUser.isEmpty()) {
            qDebug() << "用户未登录，无法更新购物车数量";
            return false;
        }

        DataManager dataManager;
        bool success = dataManager.updateCartQuantity(currentUser.toStdString(), productId, newQuantity);
        
        if (success) {
            // 立即保存用户数据
            bool saved = dataManager.saveUsersToJson();
            qDebug() << "更新购物车数量成功 - 保存到文件:" << (saved ? "成功" : "失败");
        }
        
        return success;
    }

    // 添加浏览历史 - 修改：添加自动保存
    Q_INVOKABLE bool addViewHistory(int productId) {
        QString currentUser = getCurrentUser();
        if (currentUser.isEmpty()) {
            // 未登录用户也可以浏览，但不记录历史
            qDebug() << "用户未登录，不记录浏览历史";
            return false;
        }

        DataManager dataManager;
        bool success = dataManager.addViewHistory(currentUser.toStdString(), productId);
        
        if (success) {
            // 立即保存用户数据
            bool saved = dataManager.saveUsersToJson();
            qDebug() << "添加浏览历史成功 - 保存到文件:" << (saved ? "成功" : "失败");
        }
        
        return success;
    }

    // 收藏操作 - 修改：添加自动保存
    Q_INVOKABLE bool addToFavorites(int productId, int rating) {
        QString currentUser = getCurrentUser();
        if (currentUser.isEmpty()) {
            qDebug() << "用户未登录，无法添加收藏";
            return false;
        }

        DataManager dataManager;
        bool success = dataManager.addToFavorites(currentUser.toStdString(), productId, rating);
        
        if (success) {
            // 立即保存用户数据
            bool saved = dataManager.saveUsersToJson();
            qDebug() << "添加收藏成功 - 保存到文件:" << (saved ? "成功" : "失败");
        }
        
        return success;
    }

    Q_INVOKABLE bool removeFromFavorites(int productId) {
        QString currentUser = getCurrentUser();
        if (currentUser.isEmpty()) {
            qDebug() << "用户未登录，无法移除收藏";
            return false;
        }

        DataManager dataManager;
        bool success = dataManager.removeFromFavorites(currentUser.toStdString(), productId);
        
        if (success) {
            // 立即保存用户数据
            bool saved = dataManager.saveUsersToJson();
            qDebug() << "移除收藏成功 - 保存到文件:" << (saved ? "成功" : "失败");
        }
        
        return success;
    }

    // 修改：评价商品并保存数据
    Q_INVOKABLE bool rateProduct(int productId, int rating) {
        QString currentUser = getCurrentUser();
        if (currentUser.isEmpty()) {
            qDebug() << "用户未登录，无法评价商品";
            return false;
        }

        if (rating < 0 || rating > 5) {
            qDebug() << "评分无效，必须在0-5之间:" << rating;
            return false;
        }

        DataManager dataManager;
        bool success = dataManager.rateProduct(currentUser.toStdString(), productId, rating);
        
        if (success) {
            // 评价成功后立即保存用户数据和商品数据
            bool userSaved = dataManager.saveUsersToJson();
            bool productSaved = dataManager.saveProductsToJson();
            
            qDebug() << "商品评价成功 - 用户数据保存:" << (userSaved ? "成功" : "失败") 
                     << ", 商品数据保存:" << (productSaved ? "成功" : "失败");
        }
        
        return success;
    }

signals:
    void stateChanged(int newState);
};

// DataManager 的 QML 包装器 - 增强版本，添加自动保存
class DataManagerWrapper : public QObject {
    Q_OBJECT

public:
    explicit DataManagerWrapper(QObject* parent = nullptr) : QObject(parent) {
        m_dataManager.loadUsersFromJson();
        m_dataManager.loadProductsFromJson();
    }

    Q_INVOKABLE QVariantList getProducts() {
        QVariantList productList;
        auto products = m_dataManager.getProducts();

        for (const auto& product : products) {
            QVariantMap productMap;
            productMap["productId"] = product.productId;
            productMap["name"] = QString::fromStdString(product.name);
            productMap["price"] = product.price;
            productMap["stock"] = product.stock;
            productMap["category"] = QString::fromStdString(product.category);
            productMap["avgRating"] = product.avgRating; // 使用修正后的字段名
            productMap["reviewers"] = product.reviewers;
            productList.append(productMap);
        }

        return productList;
    }

    Q_INVOKABLE QVariantMap findProduct(int productId) {
        auto product = m_dataManager.findProduct(productId);
        QVariantMap productMap;

        if (product) {
            productMap["productId"] = product->productId;
            productMap["name"] = QString::fromStdString(product->name);
            productMap["price"] = product->price;
            productMap["stock"] = product->stock;
            productMap["category"] = QString::fromStdString(product->category);
            productMap["avgRating"] = product->avgRating;
            productMap["reviewers"] = product->reviewers;
        }

        return productMap;
    }

    Q_INVOKABLE bool loadProductsFromJson() {
        return m_dataManager.loadProductsFromJson();
    }

    Q_INVOKABLE bool saveUsersToJson() {
        return m_dataManager.saveUsersToJson();
    }

    // 新增：添加浏览历史的包装方法
    Q_INVOKABLE bool addViewHistory(const QString& username, int productId) {
        if (username.isEmpty()) {
            return false;
        }
        
        bool success = m_dataManager.addViewHistory(username.toStdString(), productId);
        
        if (success) {
            // 立即保存用户数据
            bool saved = m_dataManager.saveUsersToJson();
            qDebug() << "DataManager 添加浏览历史 - 保存到文件:" << (saved ? "成功" : "失败");
        }
        
        return success;
    }

    Q_INVOKABLE QVariantMap getShoppingCartDetails(const QString& username) {
        QVariantMap result;
        QVariantList itemList;

        if (username.isEmpty()) {
            result["items"] = itemList;
            result["totalPrice"] = 0.0;
            result["totalQuantity"] = 0;
            return result;
        }

        // 确保用户和商品数据已加载
        m_dataManager.loadUsersFromJson();
        m_dataManager.loadProductsFromJson();

        double totalPrice = 0.0;
        int totalQuantity = 0;
        auto details = m_dataManager.getShoppingCartDetails(username.toStdString(), totalPrice, totalQuantity);

        for (const auto& item : details) {
            QVariantMap itemMap;
            itemMap["productId"] = item.productId;  // 确保包含商品ID
            itemMap["name"] = QString::fromStdString(item.name);
            itemMap["quantity"] = item.quantity;
            itemMap["unitPrice"] = item.unitPrice;
            itemMap["subtotal"] = item.subtotal;
            itemList.append(itemMap);
        }

        result["items"] = itemList;
        result["totalPrice"] = totalPrice;
        result["totalQuantity"] = totalQuantity;

        return result;
    }

    Q_INVOKABLE QStringList getCategories() {
        QStringList categories;
        auto products = m_dataManager.getProducts();
        QSet<QString> categorySet;

        for (const auto& product : products) {
            categorySet.insert(QString::fromStdString(product.category));
        }

        categories = QStringList(categorySet.begin(), categorySet.end());
        categories.prepend("全部");
        return categories;
    }

    Q_INVOKABLE QVariantList searchProducts(const QString& keyword) {
        QVariantList productList;
        auto products = m_dataManager.searchProducts(keyword.toStdString());

        for (const auto& product : products) {
            QVariantMap productMap;
            productMap["productId"] = product.productId;
            productMap["name"] = QString::fromStdString(product.name);
            productMap["price"] = product.price;
            productMap["stock"] = product.stock;
            productMap["category"] = QString::fromStdString(product.category);
            productMap["avgRating"] = product.avgRating;
            productMap["reviewers"] = product.reviewers;
            productList.append(productMap);
        }

        return productList;
    }

    Q_INVOKABLE QVariantList filterByCategory(const QString& category) {
        QVariantList productList;
        auto products = m_dataManager.filterByCategory(category.toStdString());

        for (const auto& product : products) {
            QVariantMap productMap;
            productMap["productId"] = product.productId;
            productMap["name"] = QString::fromStdString(product.name);
            productMap["price"] = product.price;
            productMap["stock"] = product.stock;
            productMap["category"] = QString::fromStdString(product.category);
            productMap["avgRating"] = product.avgRating;
            productMap["reviewers"] = product.reviewers;
            productList.append(productMap);
        }

        return productList;
    }

    Q_INVOKABLE bool updateProductRating(int productId, int newRating, int oldRating = -1) {
        return m_dataManager.updateProductRating(productId, newRating, oldRating);
    }

private:
    DataManager m_dataManager;
};

// UserManager 的 QML 包装器 - 保持原有实现
class UserManagerWrapper : public QObject {
    Q_OBJECT

public:
    explicit UserManagerWrapper(QObject* parent = nullptr) : QObject(parent) {
        // 由于 UserManager 不使用 Qt 信号系统，这里不需要连接信号槽
        qDebug() << "UserManagerWrapper 初始化完成";
    }

    // 获取所有用户列表
    Q_INVOKABLE QVariantList getAllUsers() {
        auto result = m_userManager.getAllUsers();
        emit dataChanged(); // 手动发射信号通知 QML
        return result;
    }

    // 添加用户
    Q_INVOKABLE bool addUser(const QString& username, const QString& password, bool isAdmin = false) {
        bool result = m_userManager.addUser(username, password, isAdmin);
        if (result) {
            qDebug() << "UserManagerWrapper: 用户添加成功，发射信号";
            emit userAdded(username);
            emit dataChanged();
        }
        else {
            emit errorOccurred("添加用户失败: " + username);
        }
        return result;
    }

    // 删除用户
    Q_INVOKABLE bool deleteUser(int userId) {
        bool result = m_userManager.deleteUser(userId);
        if (result) {
            qDebug() << "UserManagerWrapper: 用户删除成功，发射信号";
            emit userDeleted(userId);
            emit dataChanged();
        }
        else {
            emit errorOccurred("删除用户失败，ID: " + QString::number(userId));
        }
        return result;
    }

    // 更新用户信息
    Q_INVOKABLE bool updateUser(int userId, const QString& username, bool isAdmin) {
        bool result = m_userManager.updateUser(userId, username, isAdmin);
        if (result) {
            qDebug() << "UserManagerWrapper: 用户更新成功，发射信号";
            emit userUpdated(userId);
            emit dataChanged();
        }
        else {
            emit errorOccurred("更新用户失败，ID: " + QString::number(userId));
        }
        return result;
    }

    // 根据ID获取用户
    Q_INVOKABLE QVariantMap getUserById(int userId) {
        auto result = m_userManager.getUserById(userId);
        if (result.isEmpty()) {
            emit errorOccurred("未找到用户，ID: " + QString::number(userId));
        }
        return result;
    }

    // 根据用户名获取用户
    Q_INVOKABLE QVariantMap getUserByName(const QString& username) {
        auto result = m_userManager.getUserByName(username);
        if (result.isEmpty()) {
            emit errorOccurred("未找到用户: " + username);
        }
        return result;
    }

    // 获取用户统计信息
    Q_INVOKABLE QVariantMap getUserStatistics() {
        return m_userManager.getUserStatistics();
    }

    // 保存到文件
    Q_INVOKABLE bool saveToFile() {
        bool result = m_userManager.saveToFile();
        if (result) {
            qDebug() << "UserManagerWrapper: 数据保存成功";
            emit dataSaved();
        }
        else {
            emit errorOccurred("保存数据失败");
        }
        return result;
    }

    // 从文件加载
    Q_INVOKABLE bool loadFromFile() {
        bool result = m_userManager.loadFromFile();
        if (result) {
            qDebug() << "UserManagerWrapper: 数据加载成功";
            emit dataChanged();
        }
        else {
            emit errorOccurred("加载数据失败");
        }
        return result;
    }

    // 刷新数据
    Q_INVOKABLE void refreshData() {
        m_userManager.refreshData();
        qDebug() << "UserManagerWrapper: 数据已刷新";
        emit dataChanged();
    }

signals:
    void userAdded(const QString& username);
    void userDeleted(int userId);
    void userUpdated(int userId);
    void dataChanged();
    void dataSaved();
    void errorOccurred(const QString& error);

private:
    UserManager m_userManager;
};

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);

    // 初始化应用程序状态
    initializeApp();

    // 注册类型到 QML
    qmlRegisterType<StateManagerWrapper>("StateManager", 1, 0, "StateManager");
    qmlRegisterType<DataManagerWrapper>("DataManager", 1, 0, "DataManager");
    qmlRegisterType<UserManagerWrapper>("UserManager", 1, 0, "UserManager");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/Qt/mainWindow.qml")));

    return app.exec();
}

#include "main.moc"
/*
                   _ooOoo_
                  o8888888o
                  88" . "88
                  (| -_- |)
                  O\  =  /O
               ____/`---'\____
             .'  \\|     |//  `.
            /  \\|||  :  |||//  \
           /  _||||| -:- |||||-  \
           |   | \\\  -  /// |   |
           | \_|  ''\---/''  |   |
           \  .-\__  `-`  ___/-. /
         ___`. .'  /--.--\  `. . __
      ."" '<  `.___\_<|>_/___.'  >'"".
     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
     \  \ `-.   \_ __\ /__ _/   .-` /  /
======`-.____`-.___\_____/___.-`____.-'======
                   `=---='
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
            佛祖保佑       永无BUG
 */
