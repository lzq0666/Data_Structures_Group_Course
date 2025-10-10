#include "StateManager.h"


// 全局状态变量定义
AppState g_currentState = STATE_LOGIN;
bool g_isLoggedIn = false;
QString g_currentUsername = "";

// 初始化应用程序状态
void initializeApp() {
	loadAppState();
	g_currentState = g_isLoggedIn ? STATE_MAIN_MENU : STATE_LOGIN;	// 根据是否已登录设置初始状态
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
	QSettings settings("DataStructure", "CourseDesign");
	settings.beginGroup("Users");
	bool exists = settings.contains(username + "/passwordHash");
	settings.endGroup();
	return exists;
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

	// 保存用户信息
	QSettings settings("DataStructure", "CourseDesign");
	settings.beginGroup("Users");
	settings.setValue(username + "/passwordHash", hashedPassword);
	settings.setValue(username + "/salt", salt);
	settings.setValue(username + "/registrationTime", QDateTime::currentDateTime());
	settings.endGroup();

	qDebug() << "用户" << username << "注册成功";
	return true;
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

	// 从设置中获取存储的密码哈希和盐值
	QSettings settings("DataStructure", "CourseDesign");
	settings.beginGroup("Users");
	QString storedHash = settings.value(username + "/passwordHash").toString();
	QString salt = settings.value(username + "/salt").toString();
	settings.endGroup();

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