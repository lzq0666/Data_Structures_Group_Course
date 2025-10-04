#ifndef STATEMANAGER_H
#define STATEMANAGER_H

#include <QString>

// 程序状态枚举
enum AppState {
	STATE_LOGIN,
	STATE_REGISTER,
	STATE_MAIN_MENU,
	STATE_BROWSE,
	STATE_EXIT
};

// 全局状态变量
extern AppState g_currentState;
extern bool g_isLoggedIn;
extern QString g_currentUsername;

// 状态管理函数声明
void initializeApp();
void setState(AppState newState);
AppState getCurrentState();
bool login(const QString& username, const QString& password);
void logout();
bool isUserLoggedIn();
QString getCurrentUser();
void saveAppState();
void loadAppState();

// 密码相关函数声明
QString hashPassword(const QString& password, const QString& salt = QString());
QString generateSalt();
bool verifyPassword(const QString& password, const QString& hashedPassword, const QString& salt);
bool registerUser(const QString& username, const QString& password);
bool userExists(const QString& username);

#endif // !STATEMANAGER_H
