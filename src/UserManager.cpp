#include "UserManager.h"

UserManager::UserManager()
    : root(nullptr), dataManager(nullptr), nextUserId(1000)
{
    dataManager = new DataManager();
    loadUsersFromDataManager();
}

UserManager::~UserManager()
{
    saveUsersToDataManager();
    destroyTree(root);
    delete dataManager;
}

// ========== QML 接口函数 ==========

QVariantList UserManager::getAllUsers()
{
    QVariantList userList;
    std::vector<UserData> users;
    collectAllUsers(root, users);

    // 按用户ID排序
    std::sort(users.begin(), users.end(),
        [](const UserData& a, const UserData& b) {
            return a.userId < b.userId;
        });

    for (const auto& user : users) {
        userList.append(userDataToVariantMap(user));
    }

    return userList;
}

bool UserManager::addUser(const QString& username, const QString& password, bool isAdmin)
{
    // 检查用户名是否已存在
    if (searchUserByName(username.toStdString()) != nullptr) {
        qDebug() << "用户名已存在: " << username;
        return false;
    }

    UserData newUser;
    newUser.userId = nextUserId++;
    newUser.username = username.toStdString();
    newUser.salt = generateSalt().toStdString();
    newUser.password = hashPassword(password, QString::fromStdString(newUser.salt)).toStdString();
    newUser.isAdmin = isAdmin;
    newUser.shoppingCart.clear();
    newUser.viewHistory.clear();
    newUser.favorites.clear();

    if (insertUser(newUser)) {
        qDebug() << "成功添加用户: " << username;
        return true;
    }

    qDebug() << "添加用户失败";
    return false;
}

bool UserManager::deleteUser(int userId)
{
    RBNode* user = searchUser(userId);
    if (user == nullptr) {
        qDebug() << "用户不存在，ID: " << userId;
        return false;
    }

    // 不允许删除管理员
    if (user->userData.isAdmin) {
        qDebug() << "不能删除管理员用户";
        return false;
    }

    if (deleteUserNode(userId)) {
        qDebug() << "成功删除用户，ID: " << userId;
        return true;
    }

    qDebug() << "删除用户失败";
    return false;
}

bool UserManager::updateUser(int userId, const QString& username, bool isAdmin)
{
    RBNode* user = searchUser(userId);
    if (user == nullptr) {
        qDebug() << "用户不存在，ID: " << userId;
        return false;
    }

    // 检查新用户名是否与其他用户冲突
    std::string newUsername = username.toStdString();
    if (user->userData.username != newUsername) {
        RBNode* existingUser = searchUserByName(newUsername);
        if (existingUser != nullptr && existingUser->userId != userId) {
            qDebug() << "用户名已被其他用户使用: " << username;
            return false;
        }
    }

    // 更新用户信息
    user->userData.username = newUsername;
    user->userData.isAdmin = isAdmin;

    qDebug() << "成功更新用户，ID: " << userId;
    return true;
}

QVariantMap UserManager::getUserById(int userId)
{
    RBNode* user = searchUser(userId);
    if (user != nullptr) {
        return userDataToVariantMap(user->userData);
    }
    return QVariantMap();
}

QVariantMap UserManager::getUserByName(const QString& username)
{
    RBNode* user = searchUserByName(username.toStdString());
    if (user != nullptr) {
        return userDataToVariantMap(user->userData);
    }
    return QVariantMap();
}

QVariantMap UserManager::getUserStatistics()
{
    int totalUsers = 0;
    int adminUsers = 0;
    int regularUsers = 0;

    calculateStatistics(root, totalUsers, adminUsers, regularUsers);

    QVariantMap stats;
    stats["totalUsers"] = totalUsers;
    stats["adminUsers"] = adminUsers;
    stats["regularUsers"] = regularUsers;

    return stats;
}

bool UserManager::saveToFile()
{
    saveUsersToDataManager();
    return true;
}

bool UserManager::loadFromFile()
{
    loadUsersFromDataManager();
    return true;
}

void UserManager::refreshData()
{
    qDebug() << "刷新用户数据";
}

// ========== 红黑树操作函数 ==========

RBNode* UserManager::newNode(const UserData& userData)
{
    RBNode* node = new RBNode;
    node->userId = userData.userId;
    node->userData = userData;
    node->left = nullptr;
    node->right = nullptr;
    node->parent = nullptr;
    node->color = RED;  // 新节点初始颜色为红色
    return node;
}

void UserManager::leftRotate(RBNode** root, RBNode* x)
{
    RBNode* y = x->right;
    x->right = y->left;

    if (y->left != nullptr)
        y->left->parent = x;

    y->parent = x->parent;

    if (x->parent == nullptr)
        *root = y;
    else if (x == x->parent->left)
        x->parent->left = y;
    else
        x->parent->right = y;

    y->left = x;
    x->parent = y;
}

void UserManager::rightRotate(RBNode** root, RBNode* y)
{
    RBNode* x = y->left;
    y->left = x->right;

    if (x->right != nullptr)
        x->right->parent = y;

    x->parent = y->parent;

    if (y->parent == nullptr)
        *root = x;
    else if (y == y->parent->left)
        y->parent->left = x;
    else
        y->parent->right = x;

    x->right = y;
    y->parent = x;
}

void UserManager::insertFixup(RBNode** root, RBNode* z)
{
    while (z != *root && z->parent != nullptr && z->parent->color == RED) {
        if (z->parent == z->parent->parent->left) {
            RBNode* y = z->parent->parent->right;

            if (y != nullptr && y->color == RED) {
                // 情况1：叔节点为红色
                z->parent->color = BLACK;
                y->color = BLACK;
                z->parent->parent->color = RED;
                z = z->parent->parent;
            } else {
                if (z == z->parent->right) {
                    // 情况2：z是右孩子
                    z = z->parent;
                    leftRotate(root, z);
                }
                // 情况3：z是左孩子
                z->parent->color = BLACK;
                z->parent->parent->color = RED;
                rightRotate(root, z->parent->parent);
            }
        } else {
            // 对称情况
            RBNode *y = z->parent->parent->left;

            if (y != nullptr && y->color == RED) {
                z->parent->color = BLACK;
                y->color = BLACK;
                z->parent->parent->color = RED;
                z = z->parent->parent;
            } else {
                if (z == z->parent->left) {
                    z = z->parent;
                    rightRotate(root, z);
                }
                z->parent->color = BLACK;
                z->parent->parent->color = RED;
                leftRotate(root, z->parent->parent);
            }
        }
    }
    (*root)->color = BLACK; // 根节点始终为黑色
}

bool UserManager::insertUser(const UserData& userData)
{
    // 检查用户是否已存在
    if (searchUser(userData.userId) != nullptr) {
        return false;
    }

    RBNode* z = newNode(userData);
    RBNode* y = nullptr;
    RBNode* x = root;

    // 标准BST插入
    while (x != nullptr) {
        y = x;
        if (z->userId < x->userId)
            x = x->left;
        else
            x = x->right;
    }

    z->parent = y;

    if (y == nullptr) // 插入的结点是根节点
        root = z;
    else if (z->userId < y->userId)
        y->left = z;
    else
        y->right = z;

    // 修复红黑树性质
    insertFixup(&root, z);
    return true;
}

RBNode* UserManager::searchUser(int userId)
{
    RBNode* current = root;
    while (current != nullptr) {
        if (userId == current->userId)
            return current;
        else if (userId < current->userId)
            current = current->left;
        else
            current = current->right;
    }
    return nullptr;
}

RBNode* UserManager::searchUserByName(const std::string& username)
{
    return searchUserByNameHelper(root, username);
}

RBNode* UserManager::searchUserByNameHelper(RBNode* node, const std::string& username)
{
    if (node == nullptr) return nullptr;

    if (node->userData.username == username) {
        return node;
    }

    RBNode* leftResult = searchUserByNameHelper(node->left, username);
    if (leftResult != nullptr) return leftResult;

    return searchUserByNameHelper(node->right, username);
}

RBNode* UserManager::minimum(RBNode* node)
{
    while (node->left != nullptr)
        node = node->left;
    return node;
}

void UserManager::deleteFixup(RBNode** root, RBNode* x, RBNode* xParent)
{
    while (x != *root && (x == nullptr || x->color == BLACK)) {
        if (x == xParent->left) {
            RBNode* w = xParent->right;

            if (w->color == RED) {
                w->color = BLACK;
                xParent->color = RED;
                leftRotate(root, xParent);
                w = xParent->right;
            }

            if ((w->left == nullptr || w->left->color == BLACK) &&
                (w->right == nullptr || w->right->color == BLACK)) {
                w->color = RED;
                x = xParent;
                xParent = x->parent;
            } else {
                if (w->right == nullptr || w->right->color == BLACK) {
                    if (w->left != nullptr)
                        w->left->color = BLACK;
                    w->color = RED;
                    rightRotate(root, w);
                    w = xParent->right;
                }

                w->color = xParent->color;
                xParent->color = BLACK;
                if (w->right != nullptr)
                    w->right->color = BLACK;
                leftRotate(root, xParent);
                x = *root;
                break;
            }
        } else {
            RBNode *w = xParent->left;

            if (w->color == RED) {
                w->color = BLACK;
                xParent->color = RED;
                rightRotate(root, xParent);
                w = xParent->left;
            }

            if ((w->right == nullptr || w->right->color == BLACK) &&
                (w->left == nullptr || w->left->color == BLACK)) {
                w->color = RED;
                x = xParent;
                xParent = x->parent;
            } else {
                if (w->left == nullptr || w->left->color == BLACK) {
                    if (w->right != nullptr)
                        w->right->color = BLACK;
                    w->color = RED;
                    leftRotate(root, w);
                    w = xParent->left;
                }

                w->color = xParent->color;
                xParent->color = BLACK;
                if (w->left != nullptr)
                    w->left->color = BLACK;
                rightRotate(root, xParent);
                x = *root;
                break;
            }
        }
    }

    if (x != nullptr)
        x->color = BLACK;
}

bool UserManager::deleteUserNode(int userId)
{
    RBNode* z = searchUser(userId);
    if (z == nullptr) {
        return false;
    }

    RBNode* y = z;
    RBNode* x = nullptr;
    RBNode* xParent = nullptr;
    Color yOriginalColor = y->color;

    if (z->left == nullptr) {
        x = z->right;
        xParent = z->parent;

        if (z->parent == nullptr)
            root = z->right;
        else if (z == z->parent->left)
            z->parent->left = z->right;
        else
            z->parent->right = z->right;

        if (z->right != nullptr)
            z->right->parent = z->parent;
    } else if (z->right == nullptr) {
        x = z->left;
        xParent = z->parent;

        if (z->parent == nullptr)
            root = z->left;
        else if (z == z->parent->left)
            z->parent->left = z->left;
        else
            z->parent->right = z->left;

        if (z->left != nullptr)
            z->left->parent = z->parent;
    } else {
        y = minimum(z->right);
        yOriginalColor = y->color;
        x = y->right;

        if (y->parent == z) {
            if (x != nullptr)
                x->parent = y;
            xParent = y;
        } else {
            xParent = y->parent;

            if (y->parent != nullptr) {
                if (y == y->parent->left)
                    y->parent->left = y->right;
                else
                    y->parent->right = y->right;
            }

            if (y->right != nullptr)
                y->right->parent = y->parent;

            y->right = z->right;
            if (z->right != nullptr)
                z->right->parent = y;
        }

        if (z->parent == nullptr)
            root = y;
        else if (z == z->parent->left)
            z->parent->left = y;
        else
            z->parent->right = y;

        y->parent = z->parent;
        y->left = z->left;
        if (z->left != nullptr)
            z->left->parent = y;
        y->color = z->color;
    }

    delete z;

    if (yOriginalColor == BLACK)
        deleteFixup(&root, x, xParent);

    return true;
}

void UserManager::collectAllUsers(RBNode* node, std::vector<UserData>& users)
{
    if (node != nullptr) {
        collectAllUsers(node->left, users);
        users.push_back(node->userData);
        collectAllUsers(node->right, users);
    }
}

void UserManager::calculateStatistics(RBNode* node, int& total, int& admin, int& regular)
{
    if (node != nullptr) {
        total++;
        if (node->userData.isAdmin) {
            admin++;
        } else {
            regular++;
        }
        calculateStatistics(node->left, total, admin, regular);
        calculateStatistics(node->right, total, admin, regular);
    }
}

void UserManager::destroyTree(RBNode* node)
{
    if (node) {
        destroyTree(node->left);
        destroyTree(node->right);
        delete node;
    }
}

// ========== 数据管理函数 ==========

void UserManager::loadUsersFromDataManager()
{
    // 清空现有红黑树
    destroyTree(root);
    root = nullptr;

    auto& users = dataManager->getUsers();
    for (const auto& user : users) {
        insertUser(user);
        if (user.userId >= nextUserId) {
            nextUserId = user.userId + 1;
        }
    }

    qDebug() << "已从DataManager加载" << users.size() << "个用户到红黑树";
}

void UserManager::saveUsersToDataManager()
{
    std::vector<UserData> users;
    collectAllUsers(root, users);

    // 清空DataManager中的用户数据并重新添加
    auto& managerUsers = dataManager->getUsers();
    managerUsers.clear();

    for (const auto& user : users) {
        dataManager->addUser(user);
    }

    qDebug() << "已将" << users.size() << "个用户数据保存到DataManager";
}

// ========== 辅助函数 ==========

QVariantMap UserManager::userDataToVariantMap(const UserData& user)
{
    QVariantMap userMap;
    userMap["userId"] = user.userId;
    userMap["username"] = QString::fromStdString(user.username);
    userMap["isAdmin"] = user.isAdmin;
    userMap["userType"] = user.isAdmin ? "管理员" : "普通用户";
    // TODO: 修复购物车和浏览次数统计逻辑
    userMap["cartItemCount"] = static_cast<int>(user.shoppingCart.size());
    userMap["browseCount"] = static_cast<int>(user.viewHistory.size());

    return userMap;
}

QString UserManager::generateSalt()
{
    const QString charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    QString salt;

    for (int i = 0; i < 16; ++i) {
        int index = QRandomGenerator::global()->bounded(charset.length());
        salt.append(charset.at(index));
    }

    return salt;
}

QString UserManager::hashPassword(const QString& password, const QString& salt)
{
    QCryptographicHash hash(QCryptographicHash::Md5);
    hash.addData((password + salt).toUtf8());
    return hash.result().toHex().left(16); // 简化处理，取前16位
}