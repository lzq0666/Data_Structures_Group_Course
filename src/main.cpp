#include <QtGui/QGuiApplication>
#include <QtQml>
#include "StateManager.h"
#include "DataManager.h"
#include "Login.h"

// 将 C++ 状态管理函数封装为 QML 可调用的类
class StateManagerWrapper : public QObject {
    Q_OBJECT

public:
    // 枚举声明( QML无法直接访问 C++ 枚举 )
    enum State {
        STATE_LOGIN = 0,
        STATE_REGISTER = 1,  
        STATE_MAIN_MENU = 2, 
        STATE_BROWSE = 3,    
        STATE_ADMIN = 4,     
        STATE_EXIT = 5
    };

    Q_ENUM(State)

    Q_INVOKABLE bool login(const QString &username, const QString &password) {
        bool result = ::loginWithStateUpdate(username.toStdString(), password.toStdString());
        if (result) {
            emit stateChanged(getCurrentState());
        }
        return result;
    }

    Q_INVOKABLE bool registerUser(const QString &username, const QString &password) {
        return ::registerUser(username.toStdString(), password.toStdString());
    }

    Q_INVOKABLE bool userExists(const QString &username) {
        return ::userExists(username.toStdString());
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

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    // 初始化应用程序状态
    initializeApp();

    // 注册 StateManagerWrapper 类型到 QML
    qmlRegisterType<StateManagerWrapper>("StateManager", 1, 0, "StateManager");

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