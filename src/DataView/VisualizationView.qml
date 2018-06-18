/****************************************************************************
 * Written by Deddy Welsan
 * Modified from PlanView.qml
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2
import QtLocation       5.3
import QtPositioning    5.3
import QtQuick.Layouts  1.2
import QtQuick.Window   2.2

import QGroundControl               1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controllers   1.0

/// Mission Editor

QGCView {
    id:         _qgcView
    viewPanel:  panel
    anchors.rightMargin: ScreenTools.defaultFontPixelWidth
    anchors.leftMargin:  ScreenTools.defaultFontPixelWidth
    color:          qgcPal.window

//    readonly property real  _horizontalMargin:          ScreenTools.defaultFontPixelWidth  / 2
    readonly property var   _activeVehicle:             QGroundControl.multiVehicleManager.activeVehicle
//    readonly property real  _rightPanelWidth:           Math.min(parent.width / 3, ScreenTools.defaultFontPixelWidth * 30)

    property real   _toolbarHeight:             _qgcView.height - ScreenTools.availableHeight

    property var    _circleItem


    QGCViewPanel {
        id:             panel
        anchors.fill:   parent

        FlightMap {
            id:                         editorMap
            anchors.fill:               parent
            mapName:                    "MissionEditor"
            allowGCSLocationCenter:     true
            allowVehicleLocationCenter: true
            planView:                   true

            // This is the center rectangle of the map which is not obscured by tools
//            property rect centerViewport: Qt.rect(_leftToolWidth, _toolbarHeight, editorMap.width - _leftToolWidth - _rightPanelWidth, editorMap.height - _statusHeight - _toolbarHeight)

            property real _leftToolWidth:   toolStrip.x + toolStrip.width
//            property real _statusHeight:    waypointValuesDisplay.visible ? editorMap.height - waypointValuesDisplay.y : 0

            readonly property real animationDuration: 500

            // Initial map position duplicates Fly view position
            Component.onCompleted: editorMap.center = QGroundControl.flightMapPosition

            Behavior on zoomLevel {
                NumberAnimation {
                    duration:       editorMap.animationDuration
                    easing.type:    Easing.InOutQuad
                }
            }

            QGCMapPalette { id: mapPal; lightColors: editorMap.isSatelliteMap }

            //Add Contaminant Circle
            //Show UAV's Data
            MapItemView {
                model: cbUAV.checked ? _activeVehicle.contaminants : undefined

                delegate: ContaminantCircle {
                    vehicle:            QGroundControl.multiVehicleManager.vehicles
                    map:                editorMap
                    coordinate:         object.coordinate
                    alt:                object.coordinate.altitude
                    vehicleType:        object.vehicleType
                    subsType:           object.subsType
                    subsID:             object.subsID
                    subsConsentration:  object.subsConsentration
                    visibleCircle:      object.vehicleType === 1 ? true : false
                }
            }

            //Show UGV's Data
            MapItemView {
                model: cbUGV.checked ? _activeVehicle.contaminants : undefined

                delegate: ContaminantCircle {
                    vehicle:            QGroundControl.multiVehicleManager.vehicles
                    map:                editorMap
                    coordinate:         object.coordinate
                    alt:                object.coordinate.altitude
                    vehicleType:        object.vehicleType
                    subsType:           object.subsType
                    subsID:             object.subsID
                    subsConsentration:  object.subsConsentration
                    visibleCircle:      object.vehicleType === 2 ? true : false
                }
            }

            ToolStrip {
                id:                 toolStrip
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth
                anchors.left:       parent.left
                anchors.topMargin:  5
                anchors.top:        parent.top
                color:              qgcPal.window
                title:              qsTr("Map")
                z:                  QGroundControl.zOrderWidgets
                showAlternateIcon:  [ false, false ]
                rotateImage:        [ false, false ]
                animateImage:       [ false, false ]
                buttonEnabled:      [ true, true ]
                buttonVisible:      [ _showZoom, _showZoom ]
                maxHeight:          mapScale.y - toolStrip.y

                property bool _showZoom: !ScreenTools.isMobile

                model: [
                    {
                        name:       "In",
                        iconSource: "/qmlimages/ZoomPlus.svg",
                    },
                    {
                        name:       "Out",
                        iconSource: "/qmlimages/ZoomMinus.svg",
                    }
                ]

                onClicked: {
                    switch (index) {
                    case 0:
                        editorMap.zoomLevel += 1
                        break
                    case 1:
                        editorMap.zoomLevel -= 1
                        break
                    }
                }
            }

        } // FlightMap

        //panel for contaminant selection
        Rectangle {
            id:                 leftPanel
            anchors.leftMargin: 80
            anchors.left:       parent.left
            anchors.topMargin:  5
            anchors.top:        parent.top
            height:             75
            width:              210
            color:              "white"
            opacity:            0.5
        }

        CheckBox {
            id:                 cbUAV
            anchors.top:        leftPanel.top
            anchors.topMargin:  10
            anchors.left:       leftPanel.left
            anchors.leftMargin: 10
            text:               qsTr("UAV")
        }

        CheckBox {
            id:                 cbUGV
            anchors.top:        leftPanel.top
            anchors.topMargin:  10
            anchors.left:       cbChemical.right
            anchors.leftMargin: 10
            text:               qsTr("UGV")
        }

        CheckBox {
            id:                 cbChemical
            anchors.top:        cbUAV.bottom
            anchors.topMargin:  10
            anchors.left:       leftPanel.left
            anchors.leftMargin: 10
            text:               qsTr("Chemical")
        }

        CheckBox {
            id:                 cbRadioActive
            anchors.top:        cbUGV.bottom
            anchors.topMargin:  10
            anchors.left:       cbChemical.right
            anchors.leftMargin: 10
            text:               qsTr("Radio Active")
        }

        // Right panel for contaminant legend
        Rectangle {
            id:                 legendPanel
            anchors.bottom:     parent.bottom
            anchors.right:      parent.right
            height:             205
            width:              250
            color:              "white"
            opacity:            0.5
        }

        Text {
            id: textLegend
            anchors.topMargin: 5
            anchors.top:    legendPanel.top
            anchors.left:   legendPanel.left
            anchors.right:  legendPanel.right
            width: 108
            height: 22
            text: qsTr("Consentration Legend")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 23
        }

        Rectangle {
            id:                 line
            anchors.left:       legendPanel.left
            anchors.right:      legendPanel.right
            anchors.topMargin:  5
            anchors.top:        textLegend.bottom
            height:             2
            color:              "black"
        }

        Rectangle {
            id:     safeCircle
            anchors.topMargin:  10
            anchors.leftMargin: 20
            anchors.top:    line.bottom
            anchors.left:   legendPanel.left
            width:  20
            height: width
            color:  'green'
            radius: 10
        }

        Text {
            id: textSafeCont
            anchors.verticalCenter: safeCircle.verticalCenter
            anchors.leftMargin: 20
            anchors.left: safeCircle.right
            width: 108
            height: 22
            text: qsTr("None of contaminant")
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 18
        }

        Rectangle {
            id:     veryLowCircle
            anchors.topMargin:  10
            anchors.leftMargin: 20
            anchors.top: safeCircle.bottom
            anchors.left: legendPanel.left
            width:  20
            height: width
            color:  "#FFE000"
            radius: 10
        }

        Text {
            id: textVeryLowCont
            anchors.verticalCenter: veryLowCircle.verticalCenter
            anchors.leftMargin: 20
            anchors.left: veryLowCircle.right
            width: 108
            height: 22
            text: qsTr("Very low")
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 18
        }

        Rectangle {
            id:     lowCircle
            anchors.topMargin:  10
            anchors.leftMargin: 20
            anchors.top: veryLowCircle.bottom
            anchors.left: legendPanel.left
            width:  20
            height: width
            color:  "#FFA500"
            radius: 10
        }

        Text {
            id: textLowCont
            anchors.verticalCenter: lowCircle.verticalCenter
            anchors.leftMargin: 20
            anchors.left: lowCircle.right
            width: 108
            height: 22
            text: qsTr("Low")
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 18
        }

        Rectangle {
            id:     mediumCircle
            anchors.topMargin:  10
            anchors.leftMargin: 20
            anchors.top: lowCircle.bottom
            anchors.left: legendPanel.left
            width:  20
            height: width
            color:  "#FF5500"
            radius: 10
        }

        Text {
            id: textMediumCont
            anchors.verticalCenter: mediumCircle.verticalCenter
            anchors.leftMargin: 20
            anchors.left: mediumCircle.right
            width: 108
            height: 22
            text: qsTr("Medium")
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 18
        }

        Rectangle {
            id:     highCircle
            anchors.topMargin:  10
            anchors.leftMargin: 20
            anchors.top: mediumCircle.bottom
            anchors.left: legendPanel.left
            width:  20
            height: width
            color:  "#FF0000"
            radius: 10
        }

        Text {
            id: textHighCont
            anchors.verticalCenter: highCircle.verticalCenter
            anchors.leftMargin: 20
            anchors.left: highCircle.right
            width: 108
            height: 22
            text: qsTr("High")
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 18
        }

        //Show map scale
        MapScale {
            id:                 mapScale
            anchors.margins:    ScreenTools.defaultFontPixelHeight * (0.66)
            anchors.bottom:     parent.bottom
            anchors.left:       parent.left
            mapControl:         editorMap
            visible:            true
        }

        Component {
            id: contaminantIDDialogComponent

            QGCViewDialog {
                QGCFlickable {
                    anchors.fill:   parent
                    contentHeight:  categoryColumn.height
                    clip:           true

                    Column {
                        id:         categoryColumn
                        spacing:    ScreenTools.defaultFontPixelHeight / 2

                        Repeater {
                            model: ["01 Nerve", "02 Blist", "03 Blood", "04 Chemical Hazard", "05 Acid",
                                    "06 Toxic", "07 Cyanogen chloride", "08 Vesicant precursor", "09 Flameable",
                                    "10 Organic Acid", "12 Chemical Detected", "13 TDI", "14 Acetonitrile",
                                    "15 Inorganic Acid", "16 VOC", "17 Cyanide", "18 Oxidizer", "19 Air", "20 Choking",
                                    "21 TIC", "22 TIC Oxidizer", "23 TIC Hydride", "24 TIC Acidic", "25 TIC Organic",
                                    "26 Chlorine", "27 Ammonia", "28 Hydrogen sulfide", "29 Sulfure dioxide",
                                    "30 Hydrogen cyanide", "31 Unrecognize Gas"]

                            Label {
                                text:   modelData
                                color:  "white"
                                }
                            }
                        }
                    }
                } // QGCViewDialog
            } // Component - contaminantIDDialogComponent

        QGCButton {
            id:                     contaminantIDButton
            anchors.top:            parent.top
            anchors.topMargin:      5
            anchors.right:          parent.right
            anchors.rightMargin:    5
            text:                   qsTr("  Contaminant ID List  ")
            onClicked:              showDialog(contaminantIDDialogComponent, qsTr("List of contaminant ID"), qgcView.showDialogDefaultWidth, StandardButton.Close)
        }

    } // QGCViewPanel
}

/*
        // Right pane for mission editing controls
//        Rectangle {
//            id:                 rightPanel
//            anchors.top:        parent.top
//            anchors.right:      parent.right
//            height:             260
//            width:              _rightPanelWidth
//            color:              "white"
//            opacity:            0.5
//        }

//        Rectangle {
//            id:                 recInput
//            anchors.top:        parent.top
//            anchors.topMargin:  10
//            anchors.right:      parent.right
//            width:              _rightPanelWidth
//            color:              qgcPal.window

//            Text {
//                id: textConsentration
//                anchors.verticalCenter: tfConsentration.verticalCenter
//                anchors.left: recInput.left
//                width: 108
//                height: 22
//                text: qsTr("Consentration")
//                verticalAlignment: Text.AlignVCenter
//                horizontalAlignment: Text.AlignHCenter
//                font.pixelSize: 12
//            }

//            Text {
//                id: textLat
//                anchors.verticalCenter: tfLat.verticalCenter
//                anchors.left: recInput.left
//                width: 108
//                height: 22
//                text: qsTr("Latitude")
//                verticalAlignment: Text.AlignVCenter
//                horizontalAlignment: Text.AlignHCenter
//                font.pixelSize: 12
//            }

//            Text {
//                id: textLong
//                anchors.verticalCenter: tfLong.verticalCenter
//                anchors.left: recInput.left
//                width: 108
//                height: 22
//                text: qsTr("Longitude")
//                horizontalAlignment: Text.AlignHCenter
//                font.pixelSize: 12
//                verticalAlignment: Text.AlignVCenter
//            }

//            Text {
//                id: textAlt
//                anchors.verticalCenter: tfAlt.verticalCenter
//                anchors.left: recInput.left
//                width: 108
//                height: 22
//                text: qsTr("Altitude")
//                horizontalAlignment: Text.AlignHCenter
//                font.pixelSize: 12
//                verticalAlignment: Text.AlignVCenter
//            }

//            TextField {
//                id: tfConsentration
//                anchors.top: rbChemical.bottom
//                anchors.topMargin: 5
//                anchors.left: textConsentration.right
//                width: 126
//                height: 30
//                font.pointSize: 11
//                horizontalAlignment: Text.AlignHCenter
//            }

//            TextField {
//                id: tfLat
//                anchors.top: tfConsentration.bottom
//                anchors.topMargin: 5
//                anchors.left: textLat.right
//                width: 126
//                height: 30
//                font.pointSize: 11
//                horizontalAlignment: Text.AlignHCenter
//            }

//            TextField {
//                id: tfLong
//                anchors.top: tfLat.bottom
//                anchors.topMargin: 5
//                anchors.left: textLong.right
//                width: 126
//                height: 30
//                horizontalAlignment: Text.AlignHCenter
//                font.pointSize: 11
//            }

//            TextField {
//                id: tfAlt
//                anchors.top: tfLong.bottom
//                anchors.topMargin: 5
//                anchors.left: textAlt.right
//                width: 126
//                height: 30
//                horizontalAlignment: Text.AlignHCenter
//                font.pointSize: 11
//            }

//            RadioButton {
//                id: rbUAV
//                anchors.top: recInput.top
//                anchors.topMargin: 10
//                anchors.left: recInput.left
//                anchors.leftMargin: 20
//                text: qsTr("UAV")
//                checked: true
//                onClicked: rbUGV.checked = false

//            }
//            RadioButton {
//                id: rbUGV
//                anchors.top: recInput.top
//                anchors.topMargin: 10
//                anchors.left: rbUAV.right
//                anchors.leftMargin: 30
//                text: qsTr("UGV")
//                onClicked: rbUAV.checked = false
//            }

//            RadioButton {
//                id: rbChemical
//                anchors.top: rbUAV.bottom
//                anchors.topMargin: 10
//                anchors.left: recInput.left
//                anchors.leftMargin: 20
//                text: qsTr("Chemical")
//                checked: true
//                onClicked: rbRadioActive.checked = false

//            }
//            RadioButton {
//                id: rbRadioActive
//                anchors.top: rbUGV.bottom
//                anchors.topMargin: 10
//                anchors.left: rbChemical.right
//                anchors.leftMargin: 30
//                text: qsTr("Radio Active")
//                onClicked: rbChemical.checked = false
//            }
//            Button{
//                id: buttonCreate
//                anchors.top: tfAlt.bottom
//                anchors.left: recInput.left
//                anchors.topMargin: 10
//                anchors.leftMargin: 20
//                text: qsTr("Create")
//                onClicked: {
//                    var component = Qt.createComponent("MakeCircleVisualization.qml")
//                    if (component.status === Component.Ready) {
//                        _circleItem = component.createObject(editorMap,
//                                    { "map": editorMap, "_lat": tfLat.text, "_lon": tfLong.text, "_alt": tfAlt.text,
//                                      "_vehicleType": rbUAV.checked ? 0 : 1, "_substanceType": rbChemical ? 0 : 1, "_isCheckedUGVBox": cbUGV.checked,
//                                      "_subsConsentration": tfConsentration.text, "_isCheckedUAVBox": cbUAV.checked })
//                    }
//                }
//            }
//        }
*/
