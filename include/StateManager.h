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
    STATE_RECOMMENDATION = 8  
};

// 全局状态变量
extern AppState g_currentState;
extern bool g_isLoggedIn;
extern QString g_currentUsername;

// 状态管理函数声明
void initializeApp();

void setState(AppState newState);

AppState getCurrentState();
bool loginWithStateUpdate(const std::string& username, const std::string& password);

void logout();

bool isUserLoggedIn();

QString getCurrentUser();

void saveAppState();

void loadAppState();

//判断是否为管理员
bool isCurrentUserAdmin(const std::string& username);

#endif // !STATEMANAGER_H