#ifndef USERMANAGER_H
#define USERMANAGER_H

#include <QVariantList>
#include <QVariantMap>
#include <QString>
#include <QDebug>
#include <QCryptographicHash>
#include <QRandomGenerator>
#include <vector>
#include <string>
#include <algorithm>
#include "DataManager.h"

// 红黑树节点颜色
enum Color { RED, BLACK };

// 红黑树节点结构
struct RBNode {
    int userId;
    UserData userData;
    RBNode* left;
    RBNode* right;
    RBNode* parent;
    Color color;
};

class UserManager {
public:
    explicit UserManager();
    ~UserManager();

    // ========== QML 接口函数 ==========
    QVariantList getAllUsers();

    bool addUser(const QString &username, const QString &password, bool isAdmin = false);

    bool deleteUser(int userId);

    bool updateUser(int userId, const QString &username, bool isAdmin);

    QVariantMap getUserById(int userId);

    QVariantMap getUserByName(const QString &username);

    QVariantMap getUserStatistics();

    bool saveToFile();

    bool loadFromFile();

    void refreshData();

private:
    // ========== 红黑树操作函数 ==========
    RBNode *newNode(const UserData &userData);

    void leftRotate(RBNode **root, RBNode *x);

    void rightRotate(RBNode **root, RBNode *y);

    void insertFixup(RBNode **root, RBNode *z);

    bool insertUser(const UserData &userData);

    RBNode *searchUser(int userId);

    RBNode *searchUserByName(const std::string &username);

    RBNode *searchUserByNameHelper(RBNode *node, const std::string &username);

    RBNode *minimum(RBNode *node);

    void deleteFixup(RBNode **root, RBNode *x, RBNode *xParent);

    bool deleteUserNode(int userId);

    void collectAllUsers(RBNode *node, std::vector<UserData> &users);

    void calculateStatistics(RBNode *node, int &total, int &admin, int &regular);

    void destroyTree(RBNode *node);

    // ========== 数据管理函数 ==========
    void loadUsersFromDataManager();

    void saveUsersToDataManager();

    // ========== 辅助函数 ==========
    QVariantMap userDataToVariantMap(const UserData &user);

    QString generateSalt();

    QString hashPassword(const QString &password, const QString &salt);

    // ========== 成员变量 ==========
    RBNode *root; // 红黑树根节点
    DataManager *dataManager; // 数据管理器
    int nextUserId; // 下一个用户ID
};

#endif // USERMANAGER_H