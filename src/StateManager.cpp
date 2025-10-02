#include "StateManager.h"
#include <QSettings>
#include <QDebug>

// 全局状态变量定义
AppState g_currentState = STATE_LOGIN;
bool g_isLoggedIn = false;
QString g_currentUser = "";

void initializeApp() {
	loadAppState();
	g_currentState = g_isLoggedIn ? STATE_MAIN_MENU : STATE_LOGIN;
	qDebug() << "初始化应用程序...";
}

void setState(AppState newState) {
	g_currentState = newState;
	saveAppState();
	qDebug() << "应用程序状态已更改为:" << g_currentState;
}

AppState getCurrentState() {
	return g_currentState;
}

bool login(const QString& username, const QString& password) {
	// 替换为实际登录逻辑
	if(!username.isEmpty() && !password.isEmpty()) {
		g_isLoggedIn = true;
		g_currentUser = username;
		setState(STATE_MAIN_MENU);
		saveAppState();
		qDebug() << "用户" << username << "登录成功";
		return true;
	}
	else {
		qDebug() << "登录失败: 用户名或密码不能为空";
		return false;
	}
}

void logout() {
	g_isLoggedIn = false;
	g_currentUser.clear();
	setState(STATE_LOGIN);
	qDebug() << "用户已退出登录";
}

bool isUserLoggedIn() {
	return g_isLoggedIn;
}

QString getCurrentUser() {
	return g_currentUser;
}

void saveAppState() {
	QSettings settings("DataStructure", "CourseDesign");
	settings.setValue("isLoggedIn", g_isLoggedIn);
	settings.setValue("currentUser", g_currentUser);
	settings.setValue("currentState", static_cast<int>(g_currentState));	// 将枚举值转换为整数进行存储
}

void loadAppState() {
	QSettings settings("DataStructure", "CourseDesign");
	g_isLoggedIn = settings.value("isLoggedIn", false).toBool();
	g_currentUser = settings.value("currentUser", "").toString();
	g_currentState = static_cast<AppState>(settings.value("currentState", STATE_LOGIN).toInt()); // 从整数转换回枚举值
}