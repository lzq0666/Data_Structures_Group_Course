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
            stateManager.setState(StateManager.STATE_MAIN_MENU);
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
}