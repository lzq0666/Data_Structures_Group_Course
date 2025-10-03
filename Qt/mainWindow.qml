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
    }
    
    // 根据状态显示不同内容
    Loader {
        id: contentLoader
        anchors.fill: parent
        
        source: {
            switch(stateManager.getCurrentState()) {
                case StateManager.STATE_LOGIN: return "qrc:/Qt/LoginPage.qml"
                //case StateManager.STATE_MAIN_MENU: return "MainMenu.qml"
                //case StateManager.STATE_BROWSE: return "BrowsePage.qml"
                default: return "qrc:/Qt/LoginPage.qml"
            }
        }
        
        // 处理加载的组件的信号
        onLoaded: {
            if (item && typeof item.loginRequested !== "undefined") {
                // 连接登录页面的信号
                item.loginRequested.connect(handleLogin);
            }
        }
    }
    


    // 登录按钮的处理逻辑
    function handleLogin(username, password) {
        console.log("正在尝试登录:", username);
        if (stateManager.login(username, password)) {
            // 登录成功，直接跳转到主菜单（目前还没有实现，所以暂时保持在登录页）
            console.log("登录成功！欢迎使用商品推荐系统！");
            // TODO: 跳转到主菜单页面
            // stateManager.setState(StateManager.STATE_MAIN_MENU);
        } else {
            // 登录失败，通知登录页面显示错误信息
            if (contentLoader.item && typeof contentLoader.item.showLoginError === "function") {
                contentLoader.item.showLoginError("用户名或密码错误，请重新输入。");
            }
        }
    }
}