import QtQuick              2.3
import QtQuick.Controls     1.2
import QtQuick.Dialogs      1.2
import QtQuick.Layouts      1.2

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0

AnalyzePage {
    id:                 tableDataPage
    pageComponent:      pageComponent
    pageName:           qsTr("Table of Data")
    pageDescription:    qsTr("Table of data shows the data which is accepted from vehicles. Click Refresh to get the newest data.")

    property real _margin:          ScreenTools.defaultFontPixelWidth
    property real _butttonWidth:    ScreenTools.defaultFontPixelWidth * 10
    property bool _start:           false
    property var  _activeVehicle:   QGroundControl.multiVehicleManager.activeVehicle

    QGCPalette { id: palette; colorGroupEnabled: enabled }

    Component {
        id: pageComponent

        RowLayout {
            width:  availableWidth
            height: availableHeight

            TableView {
                id: tableView
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                model:              _activeVehicle.tableData //_activeVehicle.contaminants//logController.model
                selectionMode:      SelectionMode.MultiSelection
                Layout.fillWidth:   true

                TableViewColumn {
                    title: qsTr("Vehicle")
                    width: ScreenTools.defaultFontPixelWidth * 10
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
                        horizontalAlignment: Text.AlignHCenter
                        text: {
                            var o = _activeVehicle.tableData.get(styleData.row) //_activeVehicle.contaminants.get(styleData.row)
                            return o ? o.vehicleType : ""
                        }
                    }
                }

                TableViewColumn {
                    title: qsTr("Contaminant")
                    width: ScreenTools.defaultFontPixelWidth * 15
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
                        horizontalAlignment: Text.AlignHCenter
                        text: {
                            var o = _activeVehicle.tableData.get(styleData.row) //_activeVehicle.contaminants.get(styleData.row)
                            return o ? o.subsType : ""
                        }
                    }
                }

                TableViewColumn {
                    title: qsTr("Contaminant ID")
                    width: ScreenTools.defaultFontPixelWidth * 15
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
                        horizontalAlignment: Text.AlignHCenter
                        text: {
                            var o = _activeVehicle.tableData.get(styleData.row) //_activeVehicle.contaminants.get(styleData.row)
                            return o ? o.subsID : ""
                        }
                    }
                }

                TableViewColumn {
                    title: qsTr("Consentration")
                    width: ScreenTools.defaultFontPixelWidth * 15
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
                        horizontalAlignment: Text.AlignHCenter
                        text: {
                            var o = _activeVehicle.tableData.get(styleData.row) //_activeVehicle.contaminants.get(styleData.row)
                            return o ? o.subsConsentration : ""
                        }
                    }
                }

                TableViewColumn {
                    title: qsTr("Position")
                    width: ScreenTools.defaultFontPixelWidth * 50
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
                        horizontalAlignment: Text.AlignHCenter
                        text: {
                            var o = _activeVehicle.tableData.get(styleData.row) //_activeVehicle.contaminants.get(styleData.row)
                            return o ? (o.coordinate.latitude + ", " + o.coordinate.longitude + ", " + o.coordinate.altitude) : ""
                        }
                    }
                }

            }

            Column {
                spacing:            _margin
                Layout.alignment:   Qt.AlignTop | Qt.AlignLeft

                QGCButton {
//                    enabled:    !logController.requestingList && !logController.downloadingLogs
                    text:       qsTr("Update")
                    width:      _butttonWidth
                    onClicked: {

                        if (!QGroundControl.multiVehicleManager.activeVehicle || QGroundControl.multiVehicleManager.activeVehicle.isOfflineEditingVehicle) {
                            tableDataPage.showMessage(qsTr("Table Update"), qsTr("You must be connected to a vehicle in order to show data of contaminants."), StandardButton.Ok)
                        } else {
                            _activeVehicle._copyData();
                        }
                    }
                }

                QGCButton {
//                    enabled:    !logController.requestingList && !logController.downloadingLogs
                    text:       qsTr("Stop")
                    width:      _butttonWidth
                    onClicked: {
//                        vehicle.setReceiveData(false)
                    }
                }

                QGCButton {
//                    enabled:    !logController.requestingList && !logController.downloadingLogs && tableView.selection.count > 0
                    text:       qsTr("Load")
                    width:      _butttonWidth
                    onClicked: {
                        //-- Clear selection
                        for(var i = 0; i < QGroundControl.multiVehicleManager.activeVehicle.contaminants.count; i++) {
                            var o = QGroundControl.multiVehicleManager.activeVehicle.contaminants.get(i)
                            if (o) o.selected = false
                        }
                        //-- Flag selected log files
                        tableView.selection.forEach(function(rowIndex){
                            var o = QGroundControl.multiVehicleManager.activeVehicle.contaminants.get(rowIndex)
                            if (o) o.selected = true
                        })
                        fileDialog.qgcView =        tableDataPage
                        fileDialog.title =          qsTr("Select save directory")
                        fileDialog.selectExisting = true
                        fileDialog.folder =         QGroundControl.settingsManager.appSettings.telemetrySavePath
                        fileDialog.selectFolder =   true
                        fileDialog.openForLoad()
                    }

                    QGCFileDialog {
                        id: fileDialog

                        onAcceptedForLoad: {
                            logController.download(file)
                            close()
                        }
                    }
                }

                QGCButton {
                    text:       qsTr("Save")
                    width:      _butttonWidth
//                    enabled:    logController.requestingList || logController.downloadingLogs
                    onClicked:  logController.cancel()
                }

                QGCButton {
//                    enabled:    !logController.requestingList && !logController.downloadingLogs && QGroundControl.multiVehicleManager.activeVehicle.contaminants.count > 0
                    text:       qsTr("Clear All")
                    width:      _butttonWidth
                    onClicked:  _activeVehicle._clearAll()

                }
            } // Column - Buttons
        } // RowLayout
    } // Component
} // AnalyzePage
