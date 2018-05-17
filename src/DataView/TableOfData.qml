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

    QGCPalette { id: palette; colorGroupEnabled: enabled }

    Component {
        id: pageComponent

        RowLayout {
            width:  availableWidth
            height: availableHeight

            Connections {
                target: logController
                onSelectionChanged: {
                    tableView.selection.clear()
                    for(var i = 0; i < logController.model.count; i++) {
                        var o = logController.model.get(i)
                        if (o && o.selected) {
                            tableView.selection.select(i, i)
                        }
                    }
                }
            }

            TableView {
                id: tableView
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                model:              logController.model
                selectionMode:      SelectionMode.MultiSelection
                Layout.fillWidth:   true

                TableViewColumn {
                    title: qsTr("No")
                    width: ScreenTools.defaultFontPixelWidth * 6
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
                        horizontalAlignment: Text.AlignHCenter
                        text: {
                            var o = logController.model.get(styleData.row)
                            return o ? o.id : ""
                        }
                    }
                }

                TableViewColumn {
                    title: qsTr("Vehicle")
                    width: ScreenTools.defaultFontPixelWidth * 34
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
                        text: {
                            var o = logController.model.get(styleData.row)
                            if (o) {
                                //-- Have we received this entry already?
                                if(logController.model.get(styleData.row).received) {
                                    var d = logController.model.get(styleData.row).time
                                    if(d.getUTCFullYear() < 2010)
                                        return qsTr("Date Unknown")
                                    else
                                        return d.toLocaleString()
                                }
                            }
                            return ""
                        }
                    }
                }

                TableViewColumn {
                    title: qsTr("Contaminant")
                    width: ScreenTools.defaultFontPixelWidth * 18
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
                        horizontalAlignment: Text.AlignRight
                        text: {
                            var o = logController.model.get(styleData.row)
                            return o ? o.sizeStr : ""
                        }
                    }
                }

                TableViewColumn {
                    title: qsTr("Consentration")
                    width: ScreenTools.defaultFontPixelWidth * 22
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
                        horizontalAlignment: Text.AlignHCenter
                        text: {
                            var o = logController.model.get(styleData.row)
                            return o ? o.status : ""
                        }
                    }
                }

                TableViewColumn {
                    title: qsTr("Position")
                    width: ScreenTools.defaultFontPixelWidth * 22
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
                        horizontalAlignment: Text.AlignHCenter
                        text: {
                            var o = logController.model.get(styleData.row)
                            return o ? o.status : ""
                        }
                    }
                }
            }

            Column {
                spacing:            _margin
                Layout.alignment:   Qt.AlignTop | Qt.AlignLeft

                QGCButton {
                    enabled:    !logController.requestingList && !logController.downloadingLogs
                    text:       qsTr("Refresh")
                    width:      _butttonWidth

                    onClicked: {
                        if (!QGroundControl.multiVehicleManager.activeVehicle || QGroundControl.multiVehicleManager.activeVehicle.isOfflineEditingVehicle) {
                            tableDataPage.showMessage(qsTr("Log Refresh"), qsTr("You must be connected to a vehicle in order to download logs."), StandardButton.Ok)
                        } else {
                            logController.refresh()
                        }
                    }
                }

                QGCButton {
                    enabled:    !logController.requestingList && !logController.downloadingLogs && tableView.selection.count > 0
                    text:       qsTr("Load")
                    width:      _butttonWidth
                    onClicked: {
                        //-- Clear selection
                        for(var i = 0; i < logController.model.count; i++) {
                            var o = logController.model.get(i)
                            if (o) o.selected = false
                        }
                        //-- Flag selected log files
                        tableView.selection.forEach(function(rowIndex){
                            var o = logController.model.get(rowIndex)
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
                    enabled:    logController.requestingList || logController.downloadingLogs
                    onClicked:  logController.cancel()
                }

                QGCButton {
                    enabled:    !logController.requestingList && !logController.downloadingLogs && logController.model.count > 0
                    text:       qsTr("Clear All")
                    width:      _butttonWidth
                    onClicked:  tableDataPage.showDialog(eraseAllMessage,
                                                           qsTr("Delete All Log Files"),
                                                           tableDataPage.showDialogDefaultWidth,
                                                           StandardButton.Yes | StandardButton.No)

                    Component {
                        id: eraseAllMessage

                        QGCViewMessage {
                            message:    qsTr("All log files will be erased permanently. Is this really what you want?")

                            function accept() {
                                tableDataPage.hideDialog()
                                logController.eraseAll()
                            }
                        }
                    }
                }     
            } // Column - Buttons
        } // RowLayout
    } // Component
} // AnalyzePage
