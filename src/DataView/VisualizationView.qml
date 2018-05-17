/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
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

Rectangle {
    id:             _summaryRoot
    anchors.fill:   parent
    anchors.rightMargin: ScreenTools.defaultFontPixelWidth
    anchors.leftMargin:  ScreenTools.defaultFontPixelWidth
    color:          qgcPal.window

    readonly property int   _decimalPlaces:             8
    readonly property real  _horizontalMargin:          ScreenTools.defaultFontPixelWidth  / 2
    readonly property real  _margin:                    ScreenTools.defaultFontPixelHeight * 0.5
    readonly property var   _activeVehicle:             QGroundControl.multiVehicleManager.activeVehicle
    readonly property real  _rightPanelWidth:           Math.min(parent.width / 3, ScreenTools.defaultFontPixelWidth * 30)
    readonly property real  _toolButtonTopMargin:       parent.height - ScreenTools.availableHeight + (ScreenTools.defaultFontPixelHeight / 2)
    readonly property var   _defaultVehicleCoordinate:  QtPositioning.coordinate(37.803784, -122.462276)
    readonly property bool  _waypointsOnlyMode:         QGroundControl.corePlugin.options.missionWaypointsOnly

    property var    _planMasterController:      masterController
    property var    _missionController:         _planMasterController.missionController
    property var    _geoFenceController:        _planMasterController.geoFenceController
    property var    _rallyPointController:      _planMasterController.rallyPointController
    property var    _visualItems:               _missionController.visualItems
    property bool   _lightWidgetBorders:        editorMap.isSatelliteMap
    property bool   _addWaypointOnClick:        false
    property bool   _addROIOnClick:             false
    property bool   _singleComplexItem:         _missionController.complexMissionItemNames.length === 1
    property real   _toolbarHeight:             _qgcView.height - ScreenTools.availableHeight
    property int    _editingLayer:              _layerMission
    property int    _toolStripBottom:           toolStrip.height + toolStrip.y

    readonly property int       _layerMission:              1
    readonly property int       _layerGeoFence:             2
    readonly property int       _layerRallyPoints:          3
    readonly property string    _armedVehicleUploadPrompt:  qsTr("Vehicle is currently armed. Do you want to upload the mission to the vehicle?")

    property var    _circleItem

//    Component.onCompleted: {
//        toolbar.planMasterController =  Qt.binding(function () { return _planMasterController })
//        toolbar.currentMissionItem =    Qt.binding(function () { return _missionController.currentPlanViewItem })
//    }

    function addComplexItem(complexItemName) {
        var coordinate = editorMap.center
        coordinate.latitude = coordinate.latitude.toFixed(_decimalPlaces)
        coordinate.longitude = coordinate.longitude.toFixed(_decimalPlaces)
        coordinate.altitude = coordinate.altitude.toFixed(_decimalPlaces)
        insertComplexMissionItem(complexItemName, coordinate, _missionController.visualItems.count)
    }

    function insertComplexMissionItem(complexItemName, coordinate, index) {
        var sequenceNumber = _missionController.insertComplexMissionItem(complexItemName, coordinate, index)
        _missionController.setCurrentPlanViewIndex(sequenceNumber, true)
    }

    property bool _firstMissionLoadComplete:    false
    property bool _firstFenceLoadComplete:      false
    property bool _firstRallyLoadComplete:      false
    property bool _firstLoadComplete:           false

    MapFitFunctions {
        id:                         mapFitFunctions  // The name for this id cannot be changed without breaking references outside of this code. Beware!
        map:                        editorMap
        usePlannedHomePosition:     true
        planMasterController:       _planMasterController
    }

    Connections {
        target: QGroundControl.settingsManager.appSettings.defaultMissionItemAltitude

        onRawValueChanged: {
            if (_visualItems.count > 1) {
                _qgcView.showDialog(applyNewAltitude, qsTr("Apply new alititude"), showDialogDefaultWidth, StandardButton.Yes | StandardButton.No)
            }
        }
    }

    Component {
        id: applyNewAltitude

        QGCViewMessage {
            message:    qsTr("You have changed the default altitude for mission items. Would you like to apply that altitude to all the items in the current mission?")

            function accept() {
                hideDialog()
                _missionController.applyDefaultMissionAltitude()
            }
        }
    }

    Component {
        id: activeMissionUploadDialogComponent

        QGCViewDialog {

            Column {
                anchors.fill:   parent
                spacing:        ScreenTools.defaultFontPixelHeight

                QGCLabel {
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    text:       qsTr("Your vehicle is currently flying a mission. In order to upload a new or modified mission the current mission will be paused.")
                }

                QGCLabel {
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                    text:       qsTr("After the mission is uploaded you can adjust the current waypoint and start the mission.")
                }

                QGCButton {
                    text:       qsTr("Pause and Upload")
                    onClicked: {
                        _activeVehicle.flightMode = _activeVehicle.pauseFlightMode
                        _planMasterController.sendToVehicle()
                        hideDialog()
                    }
                }
            }
        }
    }

    Component {
        id: noItemForKML

        QGCViewMessage {
            message:    qsTr("You need at least one item to create a KML.")
        }
    }

    PlanMasterController {
        id: masterController

        Component.onCompleted: {
            start(true /* editMode */)
            _missionController.setCurrentPlanViewIndex(0, true)
        }

        function waitingOnDataMessage() {
            _qgcView.showMessage(qsTr("Unable to Save/Upload"), qsTr("Plan is waiting on terrain data from server for correct altitude values."), StandardButton.Ok)
        }

        function upload() {
            if (!readyForSaveSend()) {
                waitingOnDataMessage()
                return
            }
            if (_activeVehicle && _activeVehicle.armed && _activeVehicle.flightMode === _activeVehicle.missionFlightMode) {
                _qgcView.showDialog(activeMissionUploadDialogComponent, qsTr("Plan Upload"), _qgcView.showDialogDefaultWidth, StandardButton.Cancel)
            } else {
                sendToVehicle()
            }
        }

        function loadFromSelectedFile() {
            fileDialog.title =          qsTr("Select Plan File")
            fileDialog.selectExisting = true
            fileDialog.nameFilters =    masterController.loadNameFilters
            fileDialog.fileExtension =  QGroundControl.settingsManager.appSettings.planFileExtension
            fileDialog.fileExtension2 = QGroundControl.settingsManager.appSettings.missionFileExtension
            fileDialog.openForLoad()
        }

        function saveToSelectedFile() {
            if (!readyForSaveSend()) {
                waitingOnDataMessage()
                return
            }
            fileDialog.title =          qsTr("Save Plan")
            fileDialog.plan =           true
            fileDialog.selectExisting = false
            fileDialog.nameFilters =    masterController.saveNameFilters
            fileDialog.fileExtension =  QGroundControl.settingsManager.appSettings.planFileExtension
            fileDialog.fileExtension2 = QGroundControl.settingsManager.appSettings.missionFileExtension
            fileDialog.openForSave()
        }

        function fitViewportToItems() {
            mapFitFunctions.fitMapViewportToMissionItems()
        }

        function saveKmlToSelectedFile() {
            if (!readyForSaveSend()) {
                waitingOnDataMessage()
                return
            }
            fileDialog.title =          qsTr("Save KML")
            fileDialog.plan =           false
            fileDialog.selectExisting = false
            fileDialog.nameFilters =    masterController.saveKmlFilters
            fileDialog.fileExtension =  QGroundControl.settingsManager.appSettings.kmlFileExtension
            fileDialog.fileExtension2 = ""
            fileDialog.openForSave()
        }
    }

    Connections {
        target: _missionController

        onNewItemsFromVehicle: {
            if (_visualItems && _visualItems.count != 1) {
                mapFitFunctions.fitMapViewportToMissionItems()
            }
            _missionController.setCurrentPlanViewIndex(0, true)
        }
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    ExclusiveGroup {
        id: _mapTypeButtonsExclusiveGroup
    }

    /// Inserts a new simple mission item
    ///     @param coordinate Location to insert item
    ///     @param index Insert item at this index
    function insertSimpleMissionItem(coordinate, index) {
        var sequenceNumber = _missionController.insertSimpleMissionItem(coordinate, index)
        _missionController.setCurrentPlanViewIndex(sequenceNumber, true)
    }

    /// Inserts a new ROI mission item
    ///     @param coordinate Location to insert item
    ///     @param index Insert item at this index
    function insertROIMissionItem(coordinate, index) {
        var sequenceNumber = _missionController.insertROIMissionItem(coordinate, index)
        _missionController.setCurrentPlanViewIndex(sequenceNumber, true)
        _addROIOnClick = false
        toolStrip.uncheckAll()
    }

    property int _moveDialogMissionItemIndex

    QGCFileDialog {
        id:             fileDialog
        qgcView:        _qgcView
        property bool plan: true
        folder:         QGroundControl.settingsManager.appSettings.missionSavePath

        onAcceptedForSave: {
            plan ? masterController.saveToFile(file) : masterController.saveToKml(file)
            close()
        }

        onAcceptedForLoad: {
            masterController.loadFromFile(file)
            masterController.fitViewportToItems()
            _missionController.setCurrentPlanViewIndex(0, true)
            close()
        }
    }

    Component {
        id: moveDialog

        QGCViewDialog {
            function accept() {
                var toIndex = toCombo.currentIndex

                if (toIndex === 0) {
                    toIndex = 1
                }
                _missionController.moveMissionItem(_moveDialogMissionItemIndex, toIndex)
                hideDialog()
            }

            Column {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        ScreenTools.defaultFontPixelHeight

                QGCLabel {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    wrapMode:       Text.WordWrap
                    text:           qsTr("Move the selected mission item to the be after following mission item:")
                }

                QGCComboBox {
                    id:             toCombo
                    model:          _visualItems.count
                    currentIndex:   _moveDialogMissionItemIndex
                }
            }
        }
    }

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
            property rect centerViewport: Qt.rect(_leftToolWidth, _toolbarHeight, editorMap.width - _leftToolWidth - _rightPanelWidth, editorMap.height - _statusHeight - _toolbarHeight)

            property real _leftToolWidth:   toolStrip.x + toolStrip.width
            property real _statusHeight:    waypointValuesDisplay.visible ? editorMap.height - waypointValuesDisplay.y : 0

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

            MouseArea {
                //-- It's a whole lot faster to just fill parent and deal with top offset below
                //   than computing the coordinate offset.
                anchors.fill: parent
                onClicked: {
                    // Take focus to close any previous editing
                    editorMap.focus = true

                    //-- Don't pay attention to items beneath the toolbar.
                    var topLimit = parent.height - ScreenTools.availableHeight
                    if(mouse.y < topLimit) {
                        return
                    }

                    var coordinate = editorMap.toCoordinate(Qt.point(mouse.x, mouse.y), false /* clipToViewPort */)
                    coordinate.latitude = coordinate.latitude.toFixed(_decimalPlaces)
                    coordinate.longitude = coordinate.longitude.toFixed(_decimalPlaces)
                    coordinate.altitude = coordinate.altitude.toFixed(_decimalPlaces)

                    switch (_editingLayer) {
                    case _layerMission:
                        if (_addWaypointOnClick) {
                            insertSimpleMissionItem(coordinate, _missionController.visualItems.count)
                        } else if (_addROIOnClick) {
                            _addROIOnClick = false
                            insertROIMissionItem(coordinate, _missionController.visualItems.count)
                        }
                        break
                    case _layerRallyPoints:
                        if (_rallyPointController.supported) {
                            _rallyPointController.addPoint(coordinate)
                        }
                        break
                    }
                }
            }

//            MapItemView {
//                model: QGroundControl.multiVehicleManager.vehicles
//                delegate:
//                    VehicleMapItem {
//                    vehicle:        object
//                    coordinate:     object.coordinate
//                    map:            editorMap
//                    size:           ScreenTools.defaultFontPixelHeight * 3
//                    z:              QGroundControl.zOrderMapItems - 1
//                }
//            }

            //Add Contaminant Circle
            MapItemView {
                model: QGroundControl.multiVehicleManager.activeVehicle.contaminants

                delegate: ContaminantCircle {
                    vehicle:            QGroundControl.multiVehicleManager.vehicles
                    map:                editorMap
                    coordinate:         object.coordinate
                    alt:                object.coordinate.altitude
                    subsType:           object.subsType
                    subsConsentration:  object.subsConsentration
                }
            }

            /*
            // Add the mission item visuals to the map
            Repeater {
                model: _editingLayer == _layerMission ? _missionController.visualItems : undefined

                delegate: MissionItemMapVisual {
                    map:        editorMap
                    qgcView:    _qgcView
                    onClicked:  _missionController.setCurrentPlanViewIndex(sequenceNumber, false)
                    visible:    _editingLayer == _layerMission
                }
            }
            */
        /*
            // Add lines between waypoints
            MissionLineView {
                model: _editingLayer == _layerMission ? _missionController.waypointLines : undefined
            }

            // Add the vehicles to the map
            MapItemView {
                model: QGroundControl.multiVehicleManager.vehicles
                delegate:
                    VehicleMapItem {
                    vehicle:        object
                    coordinate:     object.coordinate
                    map:            editorMap
                    size:           ScreenTools.defaultFontPixelHeight * 3
                    z:              QGroundControl.zOrderMapItems - 1
                }
            }
           */

            ToolStrip {
                id:                 toolStrip
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth
                anchors.left:       parent.left
                anchors.topMargin:  ScreenTools.toolbarHeight + (_margins * 2)
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

        Rectangle {
            id:                 leftPanel
            anchors.leftMargin: 80
            anchors.left:       parent.left
            anchors.topMargin:  ScreenTools.toolbarHeight + (_margins * 2)
            anchors.top:        parent.top
            height:             100
            width:              _rightPanelWidth
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

        //Show map scale
        MapScale {
            id:                 mapScale
            anchors.margins:    ScreenTools.defaultFontPixelHeight * (0.66)
            anchors.bottom:     parent.bottom
            anchors.left:       parent.left
            mapControl:         editorMap
            visible:            _toolStripBottom < y
        }

    } // QGCViewPanel
}
