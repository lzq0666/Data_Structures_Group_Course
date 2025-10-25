import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    id: card
    color: "white"
    radius: 8
    border.color: cardMouseArea.containsMouse ? "#3b82f6" : "#e5e7eb"
    border.width: 1
    
    // 性能优化：启用缓存
    layer.enabled: true
    
    property var productData
    
    signal viewDetailsClicked()
    signal addToCartClicked()
    
    // 移除复杂的悬停效果，减少GPU负担
    MouseArea {
        id: cardMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: viewDetailsClicked()
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        // 简化商品图片区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            radius: 6
            color: "#f8fafc"
            border.color: "#e2e8f0"
            border.width: 1
            
            Text {
                anchors.centerIn: parent
                text: getCategoryIcon(productData.category)
                font.pixelSize: 36
                color: "#3b82f6"
            }
        }
        
        // 商品信息
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            
            Text {
                Layout.fillWidth: true
                text: productData.name || "未知商品"
                font.pixelSize: 15
                font.weight: Font.Bold
                color: "#1f2937"
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
            
            // 简化标签设计
            Rectangle {
                Layout.preferredWidth: categoryLabel.implicitWidth + 12
                Layout.preferredHeight: 20
                radius: 4
                color: "#e0f2fe"
                
                Text {
                    id: categoryLabel
                    anchors.centerIn: parent
                    text: productData.category || "未分类"
                    font.pixelSize: 10
                    color: "#0c4a6e"
                }
            }
            
            // 简化评分和库存
            Row {
                spacing: 8
                
                Text {
                    text: "★ " + (productData.avgRating || 0).toFixed(1)
                    font.pixelSize: 11
                    color: "#f59e0b"
                }
                
                Text {
                    text: "库存 " + (productData.stock || 0)
                    font.pixelSize: 11
                    color: (productData.stock || 0) > 0 ? "#10b981" : "#ef4444"
                }
            }
        }
        
        Item {
            Layout.fillHeight: true
        }
        
        // 简化底部区域
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                Layout.fillWidth: true
                text: "¥" + (productData.price || 0).toFixed(2)
                font.pixelSize: 18
                font.weight: Font.Bold
                color: "#dc2626"
                horizontalAlignment: Text.AlignHCenter
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    radius: 4
                    color: "#3b82f6"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "详情"
                        color: "white"
                        font.pixelSize: 12
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: viewDetailsClicked()
                    }
                }
                
                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 32
                    radius: 4
                    color: "#10b981"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "🛒"
                        font.pixelSize: 14
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: addToCartClicked()
                    }
                }
            }
        }
    }
    
    function getCategoryIcon(category) {
        switch(category) {
            case "食品":
                return "🍎"
            case "日用品":
                return "🧴"
            case "电器":
                return "🔌"
            case "数码产品":
                return "📱"
            case "服装":
                return "👗"
            case "酒水":
                return "🍷"
            default: return "📦"
        }
    }
}