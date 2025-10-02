#ifndef STATEMANAGER_H
#define STATEMANAGER_H

#include <QString>

// 程序状态枚举
enum AppState {
	STATE_LOGIN,
	STATE_MAIN_MENU,
	STATE_EXIT
};

// 全局状态变量
extern AppState g_current_state;
extern bool g_is_logged_in;
extern QString g_current_username;

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

#endif // !STATEMANAGER_H
