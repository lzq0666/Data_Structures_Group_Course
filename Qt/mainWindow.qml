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
        if (stateManager.login(username, password)) {
            // 登录成功，直接跳转到主菜单
            console.log("登录成功！欢迎使用商品推荐系统！");
            // TODO: 跳转到主菜单页面
            stateManager.setState(StateManager.STATE_MAIN_MENU);
        } else {
            // 登录失败，通知登录页面显示错误信息
            if (contentLoader.item && typeof contentLoader.item.showLoginError === "function") {
                contentLoader.item.showLoginError("用户名或密码错误，请重新输入。");
            }
        }
    }

    // 退出登录处理逻辑
    function handleLogout() {
        console.log("用户退出登录");
        stateManager.logout();  
    }

}