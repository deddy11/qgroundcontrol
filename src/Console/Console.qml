// Author: Deddy Welsan

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0


import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 1.2

Rectangle {
    id:     terminalPanel
    color:  qgcPal.window
    z:      QGroundControl.zOrderTopMost

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    ExclusiveGroup { id: setupButtonGroup }

    readonly property real  _defaultTextHeight:     ScreenTools.defaultFontPixelHeight
    readonly property real  _defaultTextWidth:      ScreenTools.defaultFontPixelWidth
    readonly property real  _horizontalMargin:      _defaultTextWidth / 2
    readonly property real  _verticalMargin:        _defaultTextHeight / 2
    readonly property real  _buttonWidth:           _defaultTextWidth * 18

    property int uavTabIndex: 1
    property int ugvTabIndex: 1

    Terminal{
        id: terminal
    }

    QGCFlickable {
        id:                 buttonScroll
        width:              buttonColumn.width
        anchors.topMargin:  _defaultTextHeight / 2
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        anchors.leftMargin: _horizontalMargin
        anchors.left:       parent.left
        contentHeight:      buttonColumn.height
        flickableDirection: Flickable.VerticalFlick
        clip:               true

        Column {
            id:         buttonColumn
            width:      _maxButtonWidth
            spacing:    _defaultTextHeight / 2

            property real _maxButtonWidth: 0

            Component.onCompleted: reflowWidths()

            function reflowWidths() {
                buttonColumn._maxButtonWidth = 0
                for (var i = 0; i < children.length; i++) {
                    buttonColumn._maxButtonWidth = Math.max(buttonColumn._maxButtonWidth, children[i].width)
                }
                for (var j = 0; j < children.length; j++) {
                    children[j].width = buttonColumn._maxButtonWidth
                }
            }

            QGCLabel {
                anchors.left:           parent.left
                anchors.right:          parent.right
                text:                   qsTr("Terminal")
                wrapMode:               Text.WordWrap
                horizontalAlignment:    Text.AlignHCenter
                visible:                !ScreenTools.isShortScreen
            }

            QGCButton {
                text:           qsTr("Add UAV Tab")
                width:          _butttonWidth
                exclusiveGroup: setupButtonGroup
                onClicked:      {
                    tabviewUAV.addTab("UAV ", componentUAVTab)
                    tabviewUAV.currentIndex = tabviewUAV.count - 1
                    terminal.openTerminalUAV()
                }
            }

            QGCButton {
                text:           qsTr("Add UGV Tab")
                width:          _butttonWidth
                exclusiveGroup: setupButtonGroup
                onClicked:      {
                    tabviewUGV.addTab("UGV ", componentUGVTab)
                    tabviewUGV.currentIndex = tabviewUGV.count - 1
                    terminal.openTerminalUGV()
                }
            }

            QGCButton {
                text:           qsTr("Remove UAV Tab")
                width:          _butttonWidth
                exclusiveGroup: setupButtonGroup
                onClicked:      tabviewUAV.removeTab(tabviewUAV.currentIndex)
            }

            QGCButton {
                text:           qsTr("Remove UGV Tab")
                width:          _butttonWidth
                exclusiveGroup: setupButtonGroup
                onClicked:      tabviewUGV.removeTab(tabviewUGV.currentIndex)
            }

            QGCButton {
                text:           qsTr("Clear UAV Tab")
                width:          _butttonWidth
                exclusiveGroup: setupButtonGroup
                onClicked:      tabviewUAV.getTab(tabviewUAV.currentIndex).item.text = ""
            }

            QGCButton {
                text:           qsTr("Clear UGV Tab")
                width:          _butttonWidth
                exclusiveGroup: setupButtonGroup
                onClicked:      tabviewUGV.getTab(tabviewUGV.currentIndex).item.text = ""
            }
        }
    }

    Rectangle {
        id:                     lineDivider
        anchors.topMargin:      _verticalMargin
        anchors.bottomMargin:   _verticalMargin
        anchors.leftMargin:     _horizontalMargin
        anchors.left:           buttonScroll.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        width:                  1
        color:                  qgcPal.windowShade
    }

    Rectangle {
        id: recTerminal
        color: qgcPal.window
        anchors.topMargin:      _verticalMargin
        anchors.bottomMargin:   _verticalMargin
        anchors.leftMargin:     _horizontalMargin
        anchors.rightMargin:    _horizontalMargin
        anchors.left:           lineDivider.right
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom

        TabView {
            id: tabviewUAV
            anchors.topMargin:      _verticalMargin
            anchors.bottomMargin:   _verticalMargin
            anchors.leftMargin:     _horizontalMargin
            anchors.rightMargin:    _horizontalMargin
            anchors.left:           parent.left
            anchors.top:            parent.top
            anchors.bottom:         textFieldUAV.top
            anchors.right:          divider.left
            tabsVisible: true

            style: TabViewStyle {
                tab: Rectangle {
                    color: styleData.selected ? "black" :"grey"
                    implicitWidth:60
                    implicitHeight: 20
                    border.width: 1
                    radius: 5
                    Text {
                        x: 13
                        text: styleData.title
                        color: "white"
                    }
                }
                frame: Rectangle { color: "black" }
            }
        }

        TabView {
            id: tabviewUGV
            anchors.topMargin:      _verticalMargin
            anchors.bottomMargin:   _verticalMargin
            anchors.leftMargin:     _horizontalMargin
            anchors.rightMargin:    _horizontalMargin
            anchors.left:           divider.right
            anchors.top:            parent.top
            anchors.bottom:         textFieldUGV.top
            anchors.right:          parent.right
            tabsVisible: true

            style: TabViewStyle {
                tab: Rectangle {
                    color: styleData.selected ? "black" :"grey"
                    implicitWidth:60
                    implicitHeight: 20
                    border.width: 1
                    radius: 5
                    Text {
                        x: 13
                        text: styleData.title
                        color: "white"
                    }
                }
                frame: Rectangle { color: "black" }
            }
        }

        TextField {
            id: textFieldUAV
            anchors.topMargin:      _verticalMargin
            anchors.bottomMargin:   _verticalMargin
            anchors.leftMargin:     _horizontalMargin
            anchors.rightMargin:    _horizontalMargin
            anchors.left:           parent.left
            anchors.bottom:         parent.bottom
            anchors.right:          divider.left
            placeholderText: qsTr("Input UAV command here . . .")
            onAccepted: {
                tabviewUAV.getTab(tabviewUAV.currentIndex).item.append(textFieldUAV.text)
                terminal.sendCommandUAV(textFieldUAV.text)
                textFieldUAV.text = ""
            }
        }

        TextField {
            id: textFieldUGV
            anchors.topMargin:      _verticalMargin
            anchors.bottomMargin:   _verticalMargin
            anchors.leftMargin:     _horizontalMargin
            anchors.rightMargin:    _horizontalMargin
            anchors.left:           divider.right
            anchors.bottom:         parent.bottom
            anchors.right:          parent.right
            placeholderText: qsTr("Input UGV command here . . .")
            onAccepted: {
                tabviewUGV.getTab(tabviewUGV.currentIndex).item.append(textFieldUGV.text)
                terminal.sendCommandUGV(textFieldUGV.text)
                textFieldUGV.text = ""
            }
        }

        Rectangle {
            id:                     divider
            anchors.topMargin:      _verticalMargin
            anchors.bottomMargin:   _verticalMargin
            anchors.top:            parent.top
            anchors.bottom:         parent.bottom
            x:                      parent.width/2
            width:                  2
            color:                  qgcPal.windowShade
        }

        Component {
            id: componentUAVTab
            TextArea {
                id: textAreaUAV
                anchors.topMargin:      _verticalMargin
                anchors.bottomMargin:   _verticalMargin
                anchors.leftMargin:     _horizontalMargin
                anchors.rightMargin:    _horizontalMargin
                anchors.left:           parent.left
                anchors.top:            parent.top
                anchors.bottom:         parent.bottom
                anchors.right:          parent.right
                backgroundVisible: false
                textColor: "white"
                wrapMode: Text.Wrap
                font.pixelSize: 15
            }
        }

        Component {
            id: componentUGVTab
            TextArea {
                id: textAreaUGV
                anchors.topMargin:      _verticalMargin
                anchors.bottomMargin:   _verticalMargin
                anchors.leftMargin:     _horizontalMargin
                anchors.rightMargin:    _horizontalMargin
                anchors.left:           parent.left
                anchors.top:            parent.top
                anchors.bottom:         parent.bottom
                anchors.right:          parent.right
                backgroundVisible: false
                textColor: "white"
                wrapMode: Text.Wrap
                font.pixelSize: 15
            }
        }
    }

}
//sudo apt-get dist-upgrade

/* code to create tab style
TabView {
    id: tabviewUGV
    anchors.topMargin:      _verticalMargin
    anchors.bottomMargin:   _verticalMargin
    anchors.leftMargin:     _horizontalMargin
    anchors.rightMargin:    _horizontalMargin
    anchors.left:           divider.right
    anchors.top:            parent.top
    anchors.bottom:         textFieldUGV.top
    anchors.right:          parent.right
    tabsVisible: true
    Tab {
        title: "Tab " + ugvTabIndex
        TextArea {
            id: textAreaUGV
            anchors.topMargin:      _verticalMargin
            anchors.bottomMargin:   _verticalMargin
            anchors.leftMargin:     _horizontalMargin
            anchors.rightMargin:    _horizontalMargin
            anchors.left:           parent.left
            anchors.top:            parent.top
            anchors.bottom:         parent.bottom
            anchors.right:          parent.right
            backgroundVisible: false
            textColor: "white"
            wrapMode: Text.Wrap
            font.pixelSize: 15
        }
    }

    style: TabViewStyle {
        frameOverlap: 1
        tab: Rectangle {
            color: "white"
            implicitWidth:75
            implicitHeight: 20
            radius: 2
            Text {
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                x: 10
                text: styleData.title
                color: "black"
            }
            Button {
                anchors.right:          parent.right
                text:                   "x"
                width:                  20
                height:                 20
                checkable:              false
                style: ButtonStyle {
                    background: Rectangle {
                        border.width: 1
                        border.color: "black"
                        implicitWidth: 20
                        implicitHeight: 20
                        color: "white"
                    }
                }
                onClicked: {
                    tabviewUGV.removeTab(tabviewUGV.currentIndex)
                }
            }
        }
        frame: Rectangle { color: "black" }
    }
}
*/
