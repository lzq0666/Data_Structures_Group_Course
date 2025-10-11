import QtQuick 2.12
import QtQuick.Controls.Fusion 2.12
import QtQuick.Dialogs
import StateManager 1.0

ApplicationWindow {
    id: appWindow
    width: 1280
    height: 800
    title: "商品推荐系统"
    visible: true
    
    StateManager {
        id: stateManager
        
        // 监听状态变化信号
        onStateChanged: {
            console.log("状态变化信号接收到，新状态:", newState)
            contentLoader.updateSource()
        }
    }
    
    // 根据状态显示不同内容
    Loader {
        id: contentLoader
        anchors.fill: parent
        
        function updateSource() {
            var currentState = stateManager.getCurrentState()
            console.log("更新界面，当前状态:", currentState)
            
            switch(currentState) {
                case StateManager.STATE_LOGIN: 
                    source = "qrc:/Qt/LoginPage.qml"
                    break
                case StateManager.STATE_REGISTER:
                    source = "qrc:/Qt/RegisterPage.qml"
                    break
                case StateManager.STATE_MAIN_MENU: 
                    source = "qrc:/Qt/MainMenu.qml"
                    break
                case StateManager.STATE_ADMIN: 
                    source = "qrc:/Qt/adminPage.qml"
                    break
                case StateManager.STATE_USER_INFO:
                    source = "qrc:/Qt/UserInfoPage.qml"
                    break
                case StateManager.STATE_CHANGE_PASSWORD:  
                    source = "qrc:/Qt/ChangePasswordPage.qml"
                    break
                //case StateManager.STATE_BROWSE: 
                //    source = "qrc:/Qt/BrowsePage.qml"
                //    break
                default: 
                    source = "qrc:/Qt/LoginPage.qml"
                    break
            }
        }
        
        Component.onCompleted: {
            updateSource()
        }
        
        // 处理加载的组件的信号
        onLoaded: {
            if (item) {
                // 为加载的组件设置 stateManager 引用
                if (typeof item.stateManager !== "undefined") {
                    item.stateManager = stateManager;
                }
                
                // 连接登录页面的信号
                if (typeof item.loginRequested !== "undefined") {
                    item.loginRequested.connect(handleLogin);
                }
                
                // 连接登录页面跳转到注册页面的信号（简化处理）
                if (typeof item.registerRequested !== "undefined") {
                    item.registerRequested.connect(function() {
                        if (arguments.length === 0) {
                            // 无参数，说明是从登录页面跳转到注册页面
                            handleGoToRegister();
                        } else if (arguments.length === 3) {
                            // 有三个参数，说明是注册操作
                            handleRegister(arguments[0], arguments[1], arguments[2]);
                        }
                    });
                }
                
                // 连接返回登录页面的信号
                if (typeof item.backToLoginRequested !== "undefined") {
                    item.backToLoginRequested.connect(handleBackToLogin);
                }
                
                // 连接主菜单退出信号
                if (typeof item.logoutRequested !== "undefined") {
                    item.logoutRequested.connect(handleLogout);
                }
                
                // 连接主菜单的用户信息信号
                if (typeof item.userInfoRequested !== "undefined") {
                    item.userInfoRequested.connect(handleUserInfo);
                }
                
                // 连接用户信息页面的返回主菜单信号
                if (typeof item.backToMainMenuRequested !== "undefined") {
                    item.backToMainMenuRequested.connect(handleBackToMainMenu);
                }
                
                // 连接用户信息页面的修改密码信号
                if (typeof item.changePasswordRequested !== "undefined") {
                    item.changePasswordRequested.connect(handleChangePassword);
                }
                
                // 连接修改密码页面的返回用户信息信号
                if (typeof item.backToUserInfoRequested !== "undefined") {
                    item.backToUserInfoRequested.connect(handleBackToUserInfo);
                }
                
                // 连接修改密码页面的修改密码信号 - 修复这里的重复绑定
                var currentStateValue = stateManager.getCurrentState();
                if (typeof item.changePasswordRequested !== "undefined" && currentStateValue === StateManager.STATE_CHANGE_PASSWORD) {
                    item.changePasswordRequested.connect(handleChangePasswordSubmit);
                }
                
                // 连接管理员页面的信号
                if (typeof item.userManagementRequested !== "undefined") {
                    item.userManagementRequested.connect(handleUserManagement);
                }
                
                if (typeof item.productManagementRequested !== "undefined") {
                    item.productManagementRequested.connect(handleProductManagement);
                }
                
                if (typeof item.orderManagementRequested !== "undefined") {
                    item.orderManagementRequested.connect(handleOrderManagement);
                }
                
                if (typeof item.systemSettingsRequested !== "undefined") {
                    item.systemSettingsRequested.connect(handleSystemSettings);
                }
            }
        }
    }
    
    // 登录按钮的处理逻辑
    function handleLogin(username, password) {
        console.log("正在尝试登录:", username);
        
        // 验证输入
        if (!username || !password) {
            if (contentLoader.item && typeof contentLoader.item.showLoginError === "function") {
                contentLoader.item.showLoginError("请输入用户名和密码");
            }
            return;
        }
        
        if (stateManager.login(username, password)) {
            // 登录成功，直接跳转到主菜单
            console.log("登录成功！欢迎使用商品推荐系统！");
        } else {
            // 登录失败，通知登录页面显示错误信息
            if (contentLoader.item && typeof contentLoader.item.showLoginError === "function") {
                contentLoader.item.showLoginError("用户名或密码错误，请重新输入。");
            }
        }
    }

    // 跳转到注册页面
    function handleGoToRegister() {
        console.log("跳转到注册页面");
        stateManager.setState(StateManager.STATE_REGISTER);
    }

    // 注册处理逻辑（从注册页面调用）
    function handleRegister(username, password, confirmPassword) {
        console.log("正在尝试注册:", username);
        
        // 验证输入
        if (!username || !password || !confirmPassword) {
            if (contentLoader.item && typeof contentLoader.item.showRegisterError === "function") {
                contentLoader.item.showRegisterError("请填写完整的注册信息");
            }
            return;
        }
        
        // 验证用户名长度
        if (username.length < 3 || username.length > 20) {
            if (contentLoader.item && typeof contentLoader.item.showRegisterError === "function") {
                contentLoader.item.showRegisterError("用户名长度应在3-20个字符之间");
            }
            return;
        }
        
        // 验证密码长度
        if (password.length < 6) {
            if (contentLoader.item && typeof contentLoader.item.showRegisterError === "function") {
                contentLoader.item.showRegisterError("密码长度至少需要6位字符");
            }
            return;
        }
        
        // 验证密码确认
        if (password !== confirmPassword) {
            if (contentLoader.item && typeof contentLoader.item.showRegisterError === "function") {
                contentLoader.item.showRegisterError("两次输入的密码不一致");
            }
            return;
        }
        
        // 检查用户是否已存在
        if (stateManager.userExists(username)) {
            if (contentLoader.item && typeof contentLoader.item.showRegisterError === "function") {
                contentLoader.item.showRegisterError("用户名已存在，请选择其他用户名");
            }
            return;
        }
        
        // 尝试注册
        if (stateManager.registerUser(username, password)) {
            console.log("注册成功！正在自动登录...");
            
            // 注册成功后自动登录
            if (stateManager.login(username, password)) {
                stateManager.setState(StateManager.STATE_MAIN_MENU);
                console.log("自动登录成功，欢迎使用商品推荐系统！");
            } else {
                if (contentLoader.item && typeof contentLoader.item.showRegisterError === "function") {
                    contentLoader.item.showRegisterError("注册成功，但自动登录失败，请返回登录页面手动登录");
                }
            }
        } else {
            // 注册失败
            if (contentLoader.item && typeof contentLoader.item.showRegisterError === "function") {
                contentLoader.item.showRegisterError("注册失败，请重试");
            }
        }
    }

    // 返回登录页面
    function handleBackToLogin() {
        console.log("返回登录页面");
        stateManager.setState(StateManager.STATE_LOGIN);
    }

    // 退出登录处理逻辑
    function handleLogout() {
        console.log("用户退出登录");
        stateManager.logout();  
    }
    
    // 跳转到用户信息页面
    function handleUserInfo() {
        console.log("跳转到用户信息页面");
        stateManager.setState(StateManager.STATE_USER_INFO);
    }
    
    // 从用户信息页面返回主菜单
    function handleBackToMainMenu() {
        console.log("返回主菜单");
        stateManager.setState(StateManager.STATE_MAIN_MENU);
    }
    
    // 跳转到修改密码页面
    function handleChangePassword() {
        console.log("跳转到修改密码页面");
        stateManager.setState(StateManager.STATE_CHANGE_PASSWORD);
    }
    
    // 从修改密码页面返回用户信息页面
    function handleBackToUserInfo() {
        console.log("返回用户信息页面");
        stateManager.setState(StateManager.STATE_USER_INFO);
    }
    
    // 处理修改密码提交
    function handleChangePasswordSubmit(oldPassword, newPassword, confirmPassword) {
        console.log("正在尝试修改密码");
        
        // 验证输入
        if (!oldPassword || !newPassword || !confirmPassword) {
            if (contentLoader.item && typeof contentLoader.item.showChangePasswordError === "function") {
                contentLoader.item.showChangePasswordError("请填写完整的密码信息");
            }
            return;
        }
        
        // 验证新密码长度
        if (newPassword.length < 6) {
            if (contentLoader.item && typeof contentLoader.item.showChangePasswordError === "function") {
                contentLoader.item.showChangePasswordError("新密码长度至少需要6位字符");
            }
            return;
        }
        
        // 验证两次新密码是否一致
        if (newPassword !== confirmPassword) {
            if (contentLoader.item && typeof contentLoader.item.showChangePasswordError === "function") {
                contentLoader.item.showChangePasswordError("两次输入的新密码不一致");
            }
            return;
        }
        
        // 验证新密码与旧密码是否相同
        if (oldPassword === newPassword) {
            if (contentLoader.item && typeof contentLoader.item.showChangePasswordError === "function") {
                contentLoader.item.showChangePasswordError("新密码不能与原密码相同");
            }
            return;
        }
        
        // 尝试修改密码
        if (stateManager.changePassword(oldPassword, newPassword)) {
            console.log("密码修改成功");
            if (contentLoader.item && typeof contentLoader.item.showChangePasswordSuccess === "function") {
                contentLoader.item.showChangePasswordSuccess("密码修改成功！即将返回用户信息页面...");
            }
        } else {
            console.log("密码修改失败");
            if (contentLoader.item && typeof contentLoader.item.showChangePasswordError === "function") {
                contentLoader.item.showChangePasswordError("密码修改失败，请检查原密码是否正确");
            }
        }
    }
    
    // 管理员页面功能处理函数
    function handleUserManagement() {
        console.log("打开用户管理");
        // TODO: 实现用户管理功能
        // 可以切换到用户管理页面或打开对话框
    }
    
    function handleProductManagement() {
        console.log("打开商品管理");
        // TODO: 实现商品管理功能
    }
    
    function handleOrderManagement() {
        console.log("打开订单管理");
        // TODO: 实现订单管理功能
    }
    
    function handleSystemSettings() {
        console.log("打开系统设置");
        // TODO: 实现系统设置功能
    }
}