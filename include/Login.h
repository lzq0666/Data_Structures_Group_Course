#ifndef LOGIN_H
#define LOGIN_H

#include <random>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <functional>
#include <memory>
#include <algorithm>
#include <QDebug>
#include "stateManager.h"
#include "DataManager.h"

// 使用标准库类型替代 Qt 类型
std::string hashPassword(const std::string &password, const std::string &salt = "");

std::string generateSalt();

bool verifyPassword(const std::string &password, const std::string &hashedPassword, const std::string &salt);

bool registerUser(const std::string &username, const std::string &password);

bool userExists(const std::string &username);

bool login(const std::string &username, const std::string &password);

bool changePassword(const std::string &username, const std::string &oldPassword, const std::string &newPassword);

#endif //LOGIN_H