# DataManager 集成指南

## 📁 文件结构

```
src/
├── DataManager.h           # 数据管理器头文件
├── DataManager.cpp         # 数据管理器实现
├── DataManagerExample.cpp  # 使用示例（可选）
├── users.json             # 用户数据文件（示例）
├── products.json          # 商品数据文件（示例）
└── CMakeLists.txt         # 已更新的构建配置
```

## 🔧 依赖项

### nlohmann JSON 库

需要安装 nlohmann JSON 库。可以通过以下方式之一：

1. **通过 vcpkg**:
   ```bash
   vcpkg install nlohmann-json
   ```

2. **手动下载**:
    - 下载 `json.hpp` 文件到项目中
    - 或使用 git submodule 添加整个仓库

3. **CMake 配置**:
   ```cmake
   find_package(nlohmann_json REQUIRED)
   target_link_libraries(main nlohmann_json::nlohmann_json)
   ```

## 📊 数据结构

### 用户数据结构 (UserData)

```cpp
struct UserData {
    std::string username;    // 用户名
    std::string password;    // 密码 (TODO: 需要加密)
    std::string email;       // 邮箱
    int userId;             // 用户ID
    bool isAdmin;           // 是否为管理员
    // TODO: 添加更多字段
};
```

### 商品数据结构 (ProductData)

```cpp
struct ProductData {
    int productId;          // 商品ID
    std::string name;       // 商品名称
    std::string description; // 商品描述
    double price;           // 价格
    int stock;              // 库存
    std::string category;   // 分类
    // TODO: 添加更多字段
};
```

## 🚀 使用方法

### 1. 基本初始化

```cpp
#include "DataManager.h"

// 创建数据管理器实例（会自动加载 JSON 文件）
DataManager dataManager;
```

### 2. 用户操作

```cpp
// 添加用户
UserData newUser = {
    "username",
    "password",
    "user@email.com",
    1001,
    false
};
dataManager.addUser(newUser);

// 查找用户
UserData* user = dataManager.findUser("username");
if (user) {
    std::cout << "用户邮箱: " << user->email << std::endl;
}

// 删除用户
dataManager.removeUser("username");

// 获取所有用户
auto& users = dataManager.getUsers();
```

### 3. 商品操作

```cpp
// 添加商品
ProductData newProduct = {
    2001,
    "商品名称",
    "商品描述",
    99.99,
    100,
    "分类"
};
dataManager.addProduct(newProduct);

// 查找商品
ProductData* product = dataManager.findProduct(2001);

// 删除商品
dataManager.removeProduct(2001);

// 获取所有商品
auto& products = dataManager.getProducts();
```

### 4. 数据持久化

```cpp
// 手动保存（通常在析构时自动保存）
dataManager.saveUsersToJson();
dataManager.saveProductsToJson();

// 重新加载数据
dataManager.loadUsersFromJson();
dataManager.loadProductsFromJson();
```

## 🔗 与现有系统集成

### 与 StateManager 集成

可以在 `StateManager.cpp` 中集成 DataManager：

```cpp
#include "DataManager.h"

class StateManagerWrapper {
private:
    DataManager dataManager;  // 添加数据管理器

public:
    bool login(const QString& username, const QString& password) {
        UserData* user = dataManager.findUser(username.toStdString());
        if (user && user->password == password.toStdString()) {
            // 登录成功逻辑
            return true;
        }
        return false;
    }
    
    bool registerUser(const QString& username, const QString& password) {
        UserData newUser = {
            username.toStdString(),
            password.toStdString(),
            "",  // TODO: 添加邮箱输入
            static_cast<int>(dataManager.getUsers().size() + 1),
            false
        };
        return dataManager.addUser(newUser);
    }
};
```

## 📋 TODO 清单

### 🏗️ 结构确定

- [ ] 确定 UserData 的最终字段结构
- [ ] 确定 ProductData 的最终字段结构
- [ ] 设计 JSON 数据格式的最终结构
- [ ] 添加时间戳字段（创建时间、更新时间等）

### 🔒 安全性

- [ ] 实现密码哈希加密（推荐使用 bcrypt 或 Argon2）
- [ ] 添加数据验证和清理
- [ ] 实现文件访问权限控制
- [ ] 添加用户会话管理

### 📈 功能扩展

- [ ] 添加搜索和过滤功能
- [ ] 实现数据分页加载（处理大数据量）
- [ ] 添加数据缓存机制
- [ ] 实现增量保存（只保存修改的数据）
- [ ] 添加数据备份和恢复功能

### 🎯 用户管理功能

- [ ] 用户权限系统
- [ ] 用户活动日志
- [ ] 密码重置功能
- [ ] 用户配置文件管理

### 🛍️ 商品管理功能

- [ ] 商品分类管理
- [ ] 库存管理和警报
- [ ] 商品图片存储
- [ ] 价格历史记录
- [ ] 商品评价系统

### ⚙️ 系统优化

- [ ] 异常处理和错误日志
- [ ] 配置文件管理
- [ ] 多线程安全性
- [ ] 内存优化
- [ ] 单元测试

## 📝 注意事项

1. **文件路径**: JSON 文件存储在 `./src/` 目录下
2. **编码格式**: 确保 JSON 文件使用 UTF-8 编码
3. **错误处理**: 所有操作都有返回值，请检查操作是否成功
4. **内存管理**: DataManager 会自动管理内存，无需手动释放
5. **线程安全**: 当前实现不是线程安全的，多线程使用时需要添加锁