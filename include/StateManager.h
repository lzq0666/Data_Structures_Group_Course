#ifndef STATEMANAGER_H
#define STATEMANAGER_H

#include <QString>
#include <QCryptographicHash>
#include <QRandomGenerator>
#include <QSettings>
#include <QDebug>
#include <QDateTime>

// 程序状态枚举
enum AppState {
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

// 全局状态变量
extern AppState g_currentState;
extern bool g_isLoggedIn;
extern QString g_currentUsername;

// 状态管理函数声明

// 初始化应用（从配置加载状态）
void initializeApp();

// 设置新状态并保存（会触发保存配置）
void setState(AppState newState);

// 获取当前状态
AppState getCurrentState();

// 登录并更新状态（会根据权限跳转到不同页面），使用 std::string 接口
bool loginWithStateUpdate(const std::string &username, const std::string &password);

// 登出并跳回登录页面
void logout();

// 查询是否有已登录用户
bool isUserLoggedIn();

// 获取当前用户名（QString）
QString getCurrentUser();

// 保存/加载应用状态到持久化配置
void saveAppState();

void loadAppState();

//判断是否为管理员
bool isCurrentUserAdmin(const std::string &username);

#endif // !STATEMANAGER_H
