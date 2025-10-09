#include "StateManager.h"
#include <QCryptographicHash>
#include <QRandomGenerator>
#include <QDebug>
#include <QDateTime>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <nlohmann/json.hpp>
using json = nlohmann::json;

// 全局状态变量定义
AppState g_currentState = STATE_LOGIN;
bool g_isLoggedIn = false;
QString g_currentUsername = "";

// JSON 文件路径
QString getDataFilePath() {
    QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(dataDir);
    if (!dir.exists()) {
        dir.mkpath(dataDir);
    }
    return dataDir + "/userdata.json";
}

// 读取 JSON 数据
json loadJsonData() {  //此函数未声明
    QString filePath = getDataFilePath();
    QFile file(filePath);

    if (!file.exists()) {
        // 如果文件不存在，返回空的 JSON 对象
        return json::object();
    }

    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << "无法打开文件进行读取:" << filePath;
        return json::object();
    }

    QByteArray data = file.readAll();
    file.close();

    try {
        return json::parse(data.toStdString());
    }
    catch (const json::exception& e) {
        qDebug() << "JSON 解析错误:" << e.what();
        return json::object();
    }
}

// 保存 JSON 数据
bool saveJsonData(const json& data) {
    QString filePath = getDataFilePath();
    QFile file(filePath);

    if (!file.open(QIODevice::WriteOnly)) {
        qDebug() << "无法打开文件进行写入:" << filePath;
        return false;
    }

    std::string jsonString = data.dump(4); // 格式化输出，缩进4个空格
    file.write(jsonString.c_str());
    file.close();

    return true;
}

// 初始化应用程序状态
void initializeApp() {
    loadAppState();
    g_currentState = g_isLoggedIn ? STATE_MAIN_MENU : STATE_LOGIN;
    qDebug() << "初始化应用程序...";
}

// 设置当前状态
void setState(AppState newState) {
    g_currentState = newState;
    saveAppState();
    qDebug() << "应用程序状态已更改为:" << g_currentState;
}

// 获取当前状态，返回一个 AppState 类型枚举值
AppState getCurrentState() {
    return g_currentState;
}

// 生成随机盐值
QString generateSalt() {
    const QString characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    QString salt;
    for (int i = 0; i < 16; ++i) {
        int index = QRandomGenerator::global()->bounded(characters.length());
        salt.append(characters.at(index));
    }
    return salt;
}

// 使用SHA-256对密码进行哈希处理
QString hashPassword(const QString& password, const QString& salt) {
    QString saltedPassword = password + salt;
    QByteArray hash = QCryptographicHash::hash(saltedPassword.toUtf8(), QCryptographicHash::Sha256);
    return hash.toHex();
}

// 验证密码
bool verifyPassword(const QString& password, const QString& hashedPassword, const QString& salt) {
    QString computedHash = hashPassword(password, salt);
    return computedHash == hashedPassword;
}

// 检查用户是否存在
bool userExists(const QString& username) {
    json data = loadJsonData();

    if (data.contains("users") && data["users"].contains(username.toStdString())) {
        return true;
    }

    return false;
}

// 用户注册功能
bool registerUser(const QString& username, const QString& password) {
    if (username.isEmpty() || password.isEmpty()) {
        qDebug() << "注册失败: 用户名或密码不能为空";
        return false;
    }

    if (userExists(username)) {
        qDebug() << "注册失败: 用户名已存在";
        return false;
    }

    // 生成盐值并哈希密码
    QString salt = generateSalt();
    QString hashedPassword = hashPassword(password, salt);

    // 读取现有数据
    json data = loadJsonData();

    // 确保 users 对象存在
    if (!data.contains("users")) {
        data["users"] = json::object();
    }

    // 保存用户信息
    data["users"][username.toStdString()] = {
        {"passwordHash", hashedPassword.toStdString()},
        {"salt", salt.toStdString()},
        {"registrationTime", QDateTime::currentDateTime().toString(Qt::ISODate).toStdString()}
    };

    // 保存到文件
    if (saveJsonData(data)) {
        qDebug() << "用户" << username << "注册成功";
        return true;
    }
    else {
        qDebug() << "注册失败: 无法保存用户数据";
        return false;
    }
}

// 登录操作
bool login(const QString& username, const QString& password) {
    if (username.isEmpty() || password.isEmpty()) {
        qDebug() << "登录失败: 用户名或密码不能为空";
        return false;
    }

    if (!userExists(username)) {
        qDebug() << "登录失败: 用户不存在";
        return false;
    }

    // 从 JSON 数据中获取用户信息
    json data = loadJsonData();
    json userInfo = data["users"][username.toStdString()];

    QString storedHash = QString::fromStdString(userInfo["passwordHash"]);
    QString salt = QString::fromStdString(userInfo["salt"]);

    // 验证密码
    if (verifyPassword(password, storedHash, salt)) {
        g_isLoggedIn = true;
        g_currentUsername = username;
        setState(STATE_MAIN_MENU);
        qDebug() << "用户" << username << "登录成功";
        return true;
    }
    else {
        qDebug() << "登录失败: 密码错误";
        return false;
    }
}

// 登出操作
void logout() {
    g_isLoggedIn = false;
    g_currentUsername.clear();
    setState(STATE_LOGIN);
    qDebug() << "用户已退出登录";
}

// 获取当前登录状态
bool isUserLoggedIn() {
    return g_isLoggedIn;
}

// 获取当前用户名
QString getCurrentUser() {
    return g_currentUsername;
}

// 保存应用程序状态到 JSON 文件
void saveAppState() {
    json data = loadJsonData();

    // 保存应用状态
    data["appState"] = {
        {"isLoggedIn", g_isLoggedIn},
        {"currentUser", g_currentUsername.toStdString()},
        {"currentState", static_cast<int>(g_currentState)}
    };

    saveJsonData(data);
}

// 从 JSON 文件加载应用程序状态
void loadAppState() {
    json data = loadJsonData();

    if (data.contains("appState")) {
        json appState = data["appState"];
        g_isLoggedIn = appState.value("isLoggedIn", false);
        g_currentUsername = QString::fromStdString(appState.value("currentUser", std::string("")));
        g_currentState = static_cast<AppState>(appState.value("currentState", STATE_LOGIN));
    }
    else {
        // 默认值
        g_isLoggedIn = false;
        g_currentUsername = "";
        g_currentState = STATE_LOGIN;
    }
}