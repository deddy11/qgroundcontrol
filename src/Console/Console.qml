// Author: Deddy Welsan

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0

import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 1.2

Rectangle {
    id: rectangle
    color: qgcPal.window

    property int uavTabIndex: 1
    property int ugvTabIndex: 1

    readonly property real  _defaultTextHeight:     ScreenTools.defaultFontPixelHeight
    readonly property real  _defaultTextWidth:      ScreenTools.defaultFontPixelWidth
    readonly property real  _horizontalMargin:      _defaultTextWidth / 1.5
    readonly property real  _verticalMargin:        _defaultTextHeight / 2
    readonly property real  _buttonWidth:           _defaultTextWidth * 18

    MouseArea {
        id: mouseArea
    }

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
        Tab {
            title: "Tab " + uavTabIndex
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

    Button {
        id:                     addUAVTabButton
        anchors.top:            tabviewUAV.top
        text:                   qsTr("+")
        x:                      85
        width:                  34
        height:                 20
        checkable:              false
        onClicked: {

        }
    }

    Button {
        id:                     addUGVTabButton
        anchors.top:            tabviewUGV.top
        text:                   qsTr("+")
        x:                      1015
        width:                  34
        height:                 20
        checkable:              false
    }
}


