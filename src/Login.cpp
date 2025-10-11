#include "Login.h"


// 全局数据管理器实例
static std::unique_ptr<DataManager> g_dataManager = nullptr;

// 获取数据管理器实例
static DataManager *getDataManager() {
    if (!g_dataManager) {
        g_dataManager = std::make_unique<DataManager>();
    }
    return g_dataManager.get();
}

// 使用标准库哈希函数对密码进行哈希
std::string hashPassword(const std::string &password, const std::string &salt) {
    std::string input = password + salt;
    std::hash<std::string> hasher;
    size_t hashValue = hasher(input);

    // 将哈希值转换为十六进制字符串
    std::stringstream ss;
    ss << std::hex << hashValue;
    return ss.str();
}

// 生成随机盐值
std::string generateSalt() {
    const std::string charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    const int saltLength = 16;

    std::random_device rd;
    std::mt19937 generator(rd());
    std::uniform_int_distribution<> distribution(0, charset.size() - 1);

    std::string salt;
    for (int i = 0; i < saltLength; ++i) {
        salt += charset[distribution(generator)];
    }

    return salt;
}

// 验证密码
bool verifyPassword(const std::string &password, const std::string &hashedPassword, const std::string &salt) {
    std::string computedHash = hashPassword(password, salt);
    return computedHash == hashedPassword;
}

// 检查用户是否存在
bool userExists(const std::string &username) {
    DataManager *dm = getDataManager();
    UserData *user = dm->findUser(username);
    return user != nullptr;
}

// 用户注册功能
bool registerUser(const std::string &username, const std::string &password) {
    if (username.empty() || password.empty()) {
        qDebug() << "注册失败: 用户名或密码不能为空";
        return false;
    }

    if (userExists(username)) {
        qDebug() << "注册失败: 用户名已存在";
        return false;
    }

    // 生成盐值并哈希密码
    std::string salt = generateSalt();
    std::string hashedPassword = hashPassword(password, salt);

    // 创建用户数据
    UserData newUser;
    newUser.username = username;
    newUser.password = hashedPassword;
    newUser.salt = salt;
    newUser.isAdmin = false; // 默认非管理员

    // 生成用户ID (简单实现：使用当前用户数量 + 1)
    DataManager *dm = getDataManager();
    newUser.userId = dm->getUsers().size() + 1;

    // 初始化购物车、浏览历史和收藏夹
    newUser.shoppingCart = std::vector<std::vector<int> >();
    newUser.viewHistory = std::vector<std::vector<int> >();
    newUser.favorites = std::vector<std::vector<int> >();

    // 添加用户到数据管理器
    if (dm->addUser(newUser)) {
        std::cout << "用户 " << username << " 注册成功" << std::endl;
        return true;
    } else {
        std::cerr << "注册失败: 无法保存用户数据" << std::endl;
        return false;
    }
}

// 登录操作
bool login(const std::string &username, const std::string &password) {
    if (username.empty() || password.empty()) {
        qDebug() << "登录失败: 用户名或密码不能为空";
        return false;
    }

    DataManager *dm = getDataManager();
    UserData *user = dm->findUser(username);

    if (!user) {
        std::cerr << "登录失败: 用户不存在" << std::endl;
        return false;
    }

    // 验证密码
    if (verifyPassword(password, user->password, user->salt)) {
        std::cout << "用户 " << username << " 登录成功" << std::endl;
        return true;
    } else {
        std::cerr << "登录失败: 密码错误" << std::endl;
        return false;
    }
}

// 检查当前用户是否为管理员
bool isCurrentUserAdmin(const std::string& username) {
    DataManager* dm = getDataManager();
    UserData* user = dm->findUser(username);

    if (user) {
        return user->isAdmin;
    }
    return false;
}
