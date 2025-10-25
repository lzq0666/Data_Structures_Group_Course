#include "StateManager.h"
#include "Login.h"

// 全局状态变量定义
AppState g_currentState = STATE_LOGIN;
bool g_isLoggedIn = false;
QString g_currentUsername = "";

// 初始化应用程序状态
void initializeApp() {
	loadAppState();
	
	// 如果用户已登录，根据用户权限决定初始状态
	if (g_isLoggedIn && !g_currentUsername.isEmpty()) {
		// 检查用户是否为管理员
		if (isCurrentUserAdmin(g_currentUsername.toStdString())) {
			g_currentState = STATE_ADMIN;
			qDebug() << "管理员" << g_currentUsername << "自动登录到管理页面";
		} else {
			g_currentState = STATE_MAIN_MENU;
			qDebug() << "用户" << g_currentUsername << "自动登录到主菜单";
		}
	} else {
		g_currentState = STATE_LOGIN;
		qDebug() << "未登录，跳转到登录页面";
	}
	
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

// 登录操作（包装器函数，用于更新状态）
bool loginWithStateUpdate(const std::string& username, const std::string& password) {
	if (login(username, password)) {
		g_isLoggedIn = true;
		g_currentUsername = QString::fromStdString(username);

		// 根据用户权限决定跳转页面
		if (isCurrentUserAdmin(username)) {
			setState(STATE_ADMIN);  // 管理员跳转到管理页面
			qDebug() << "管理员" << username << "登录成功";
		}
		else {
			setState(STATE_MAIN_MENU);  // 普通用户跳转到主菜单
			qDebug() << "用户" << username << "登录成功";
		}
		return true;
	}
	else {
		qDebug() << "登录失败";
		return false;
	}
}

// 登出操作
void logout() {
	g_isLoggedIn = false;
	g_currentUsername.clear();	// 清空当前用户名
	setState(STATE_LOGIN);	// 设置为登录状态
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

// 保存应用程序状态到配置文件
void saveAppState() {
	QSettings settings("DataStructure", "CourseDesign");
	settings.setValue("isLoggedIn", g_isLoggedIn);
	settings.setValue("currentUser", g_currentUsername);
	settings.setValue("currentState", static_cast<int>(g_currentState));	// 将枚举值转换为整数进行存储
}

// 从配置文件加载应用程序状态
void loadAppState() {
	QSettings settings("DataStructure", "CourseDesign");
	g_isLoggedIn = settings.value("isLoggedIn", false).toBool();
	g_currentUsername = settings.value("currentUser", "").toString();
	g_currentState = static_cast<AppState>(settings.value("currentState", STATE_LOGIN).toInt()); // 从整数转换回枚举值
}