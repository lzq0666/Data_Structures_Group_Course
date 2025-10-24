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
        STATE_PRODUCT_MANAGEMENT = 10
    };

    Q_ENUM(State)

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

signals:
    void stateChanged(int newState);
};

// DataManager 的 QML 包装器
class DataManagerWrapper : public QObject {
    Q_OBJECT

public:
    explicit DataManagerWrapper(QObject* parent = nullptr) : QObject(parent) {
        loadProductsFromJson();
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
            productMap["avgRating"] = product.avg_rating;
            productMap["reviewers"] = product.reviewers;
            productList.append(productMap);
        }

        return productList;
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

    Q_INVOKABLE bool loadProductsFromJson() {
        if (!m_dataManager.loadProductsFromJson()) {
            // 如果加载失败，创建示例数据
            createSampleProducts();
            return true;
        }
        return true;
    }

private:
    DataManager m_dataManager;

    void createSampleProducts() {
        std::vector<ProductData> sampleProducts = {
            {1, "iPhone 15 Pro", 7999.0, 50, "手机", 4.8, 1200},
            {2, "MacBook Pro M3", 12999.0, 30, "电脑", 4.9, 800},
            {3, "AirPods Pro", 1899.0, 100, "耳机", 4.7, 2500},
            {4, "iPad Air", 4399.0, 80, "平板", 4.6, 1800},
            {5, "Apple Watch Series 9", 2899.0, 60, "手表", 4.5, 1500},
            {6, "Samsung Galaxy S24", 6999.0, 45, "手机", 4.6, 900},
        };

        for (const auto& product : sampleProducts) {
            m_dataManager.addProduct(product);
        }

        m_dataManager.saveProductsToJson();
    }
};

// UserManager 的 QML 包装器
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
        } else {
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
        } else {
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
        } else {
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
        } else {
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
        } else {
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