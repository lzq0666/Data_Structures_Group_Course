import QtQuick 2.12
import QtQuick.Controls.Fusion 2.12
import QtQuick.Layouts 1.12
import StateManager 1.0
import DataManager 1.0

Item {
    id: cartPage
    anchors.fill: parent

    signal backToMainMenuRequested()

    property var stateManager: null
    property string currentUserName: ""
    property real totalPrice: 0
    property int totalQuantity: 0
    property string totalPriceText: "\u00A50.00"

    DataManager {
        id: dataManager
    }

    ListModel {
        id: cartModel
    }

    function refreshCart() {
        console.log("开始刷新购物车数据...")
        
        // 检查 StateManager 是否注入
        if (!cartPage.stateManager) {
            console.log("StateManager 未注入，无法加载购物车")
            // 尝试清空数据显示
            cartModel.clear()
            cartPage.totalPrice = 0
            cartPage.totalQuantity = 0
            cartPage.totalPriceText = cartPage.formatPrice(0)
            cartPage.currentUserName = ""
            return
        }

        // 获取当前用户名
        cartPage.currentUserName = cartPage.stateManager.getCurrentUser()
        console.log("当前用户:", cartPage.currentUserName)
        
        if (!cartPage.currentUserName || cartPage.currentUserName.length === 0) {
            console.log("用户未登录，清空购物车显示")
            cartModel.clear()
            cartPage.totalPrice = 0
            cartPage.totalQuantity = 0
            cartPage.totalPriceText = cartPage.formatPrice(0)
            return
        }

        // 调用 DataManager 获取购物车详情
        var result = dataManager.getShoppingCartDetails(cartPage.currentUserName)
        console.log("购物车数据获取结果:", JSON.stringify(result))
        
        cartModel.clear()

        if (result && result.items && result.items.length > 0) {
            console.log("找到购物车商品:", result.items.length, "个")
            
            for (var i = 0; i < result.items.length; ++i) {
                var item = result.items[i] || {}
                console.log("添加商品:", item.name, "数量:", item.quantity, "单价:", item.unitPrice)
                
                cartModel.append({
                    name: item.name || "未知商品",
                    quantity: item.quantity || 0,
                    unitPrice: item.unitPrice || 0,
                    subtotal: item.subtotal || 0,
                    displayUnitPrice: cartPage.formatPrice(item.unitPrice || 0),
                    displaySubtotal: cartPage.formatPrice(item.subtotal || 0)
                })
            }
            
            cartPage.totalPrice = result.totalPrice || 0
            cartPage.totalQuantity = result.totalQuantity || 0
            cartPage.totalPriceText = cartPage.formatPrice(cartPage.totalPrice)
            
            console.log("购物车总计: 商品数量", cartPage.totalQuantity, "总价", cartPage.totalPrice)
        } else {
            console.log("购物车为空或无有效数据")
            cartPage.totalPrice = 0
            cartPage.totalQuantity = 0
            cartPage.totalPriceText = cartPage.formatPrice(0)
        }
    }

    function formatPrice(value) {
        return "\u00A5" + Number(value || 0).toFixed(2)
    }

    // 监听状态管理器的状态变化
    Connections {
        target: cartPage.stateManager
        enabled: cartPage.stateManager !== null

        function onStateChanged() {
            console.log("购物车页面接收到状态变化信号")
            if (!cartPage.stateManager) {
                return
            }
            
            var currentState = cartPage.stateManager.getCurrentState()
            console.log("当前状态:", currentState, "购物车状态:", StateManager.STATE_SHOPPING_CART)
            
            if (currentState === StateManager.STATE_SHOPPING_CART) {
                console.log("状态切换到购物车，刷新数据")
                cartPage.refreshCart()
            }
        }
    }

    // 组件完成时刷新购物车，并添加延时确保状态管理器已注入
    Component.onCompleted: {
        console.log("购物车组件加载完成")
        // 延时调用以确保 stateManager 已经注入
        Qt.callLater(function() {
            console.log("延时刷新购物车, stateManager:", cartPage.stateManager)
            cartPage.refreshCart()
        })
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                color: "#4158d0"; position: 0.0
            }
            GradientStop {
                color: "#c850c0"; position: 1.0
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.92, 1280)
        height: Math.min(parent.height * 0.92, 860)
        radius: 20
        color: "white"
        opacity: 0.98
        border.color: "#e0e0e0"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 60

                Rectangle {
                    id: backButton
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 40
                    radius: 10
                    color: backArea.containsMouse ? "#3498db" : "#2c3e50"

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "\u2190"; color: "white"; font.pixelSize: 16; font.bold: true
                        }
                        Text {
                            text: qsTr("返回"); color: "white"; font.pixelSize: 14; font.bold: true
                        }
                    }

                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: cartPage.backToMainMenuRequested()
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignLeft
                    spacing: 4
                    Text {
                        text: qsTr("购物车")
                        font.pixelSize: 26
                        font.bold: true
                        color: "#2c3e50"
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text {
                        text: cartPage.currentUserName && cartPage.currentUserName.length > 0 ? 
                              qsTr("当前用户: ") + cartPage.currentUserName : 
                              qsTr("未登录用户")
                        font.pixelSize: 13
                        color: "#7f8c8d"
                        horizontalAlignment: Text.AlignLeft
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 2; color: "#ecf0f1"; radius: 1
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 12
                color: "#f8f9fa"
                border.color: "#e0e0e0"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10

                    Text {
                        Layout.preferredWidth: 420
                        Layout.alignment: Qt.AlignLeft
                        text: qsTr("商品名称")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2c3e50"
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text {
                        Layout.preferredWidth: 120
                        Layout.alignment: Qt.AlignLeft
                        text: qsTr("单价")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2c3e50"
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text {
                        Layout.preferredWidth: 100
                        Layout.alignment: Qt.AlignLeft
                        text: qsTr("数量")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2c3e50"
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text {
                        Layout.preferredWidth: 150
                        Layout.alignment: Qt.AlignLeft
                        text: qsTr("小计")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2c3e50"
                        horizontalAlignment: Text.AlignLeft
                    }
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: cartList
                    width: parent.width
                    model: cartModel
                    spacing: 10

                    delegate: Rectangle {
                        width: parent ? parent.width : 0
                        height: 70
                        radius: 12
                        color: "#ffffff"
                        border.color: "#ecf0f1"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 10

                            Text {
                                Layout.preferredWidth: 420
                                Layout.alignment: Qt.AlignLeft
                                text: model.name && model.name.length > 0 ? model.name : qsTr("未知商品")
                                font.pixelSize: 14
                                color: "#2c3e50"
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignLeft
                            }

                            Text {
                                Layout.preferredWidth: 120
                                Layout.alignment: Qt.AlignLeft
                                text: model.displayUnitPrice || "\u00A50.00"
                                font.pixelSize: 14
                                color: "#2c3e50"
                                horizontalAlignment: Text.AlignLeft
                            }

                            Text {
                                Layout.preferredWidth: 100
                                Layout.alignment: Qt.AlignLeft
                                text: model.quantity || 0
                                font.pixelSize: 14
                                color: "#2c3e50"
                                horizontalAlignment: Text.AlignLeft
                            }

                            Text {
                                Layout.preferredWidth: 150
                                Layout.alignment: Qt.AlignLeft
                                text: model.displaySubtotal || "\u00A50.00"
                                font.pixelSize: 14
                                color: "#e74c3c"
                                horizontalAlignment: Text.AlignLeft
                                font.bold: true
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                radius: 15
                color: "#ffffff"
                border.color: "#ecf0f1"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    ColumnLayout {
                        Layout.alignment: Qt.AlignLeft
                        spacing: 6
                        Text {
                            text: qsTr("商品种类: ") + cartModel.count
                            font.pixelSize: 14
                            color: "#2c3e50"
                            horizontalAlignment: Text.AlignLeft
                        }
                        Text {
                            text: qsTr("商品数量: ") + cartPage.totalQuantity
                            font.pixelSize: 14
                            color: "#2c3e50"
                            horizontalAlignment: Text.AlignLeft
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignLeft
                        spacing: 6
                        Text {
                            text: qsTr("总金额")
                            font.pixelSize: 16
                            font.bold: true
                            color: "#2c3e50"
                            horizontalAlignment: Text.AlignLeft
                        }
                        Text {
                            text: cartPage.totalPriceText
                            font.pixelSize: 28
                            font.bold: true
                            color: "#e74c3c"
                            horizontalAlignment: Text.AlignLeft
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true; Layout.preferredHeight: 20
            }
        }
        
        // 购物车为空时的提示信息
        Text {
            anchors.centerIn: parent
            text: qsTr("购物车为空，快去挑选喜欢的商品吧！")
            font.pixelSize: 18
            color: "#7f8c8d"
            visible: cartModel.count === 0
            horizontalAlignment: Text.AlignHCenter
        }
    }
}