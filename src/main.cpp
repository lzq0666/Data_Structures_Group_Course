#include <QtGui/QGuiApplication>
#include <QtQml>
#include "StateManager.h"
#include "DataManager.h"
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

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);

    // 初始化应用程序状态
    initializeApp();

    // 注册类型到 QML
    qmlRegisterType<StateManagerWrapper>("StateManager", 1, 0, "StateManager");
    qmlRegisterType<DataManagerWrapper>("DataManager", 1, 0, "DataManager");

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