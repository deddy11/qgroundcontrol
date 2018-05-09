import QtQuick          2.3
import QtLocation       5.3
import QtPositioning    5.3
import QtQuick.Controls 1.0

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0

/// Marker for displaying a vehicle location on the map
MapQuickItem {
    property var    vehicle                                                         /// Vehicle object, undefined for ADSB vehicle
    property var    map
//    property string callsign:       ""                                              ///< Vehicle callsign
//    property double heading:        vehicle ? vehicle.heading.value : Number.NaN    ///< Vehicle heading, NAN for none

//    anchorPoint.x:  vehicleItem.width  / 2
//    anchorPoint.y:  vehicleItem.height / 2
    visible:        coordinate.isValid

    property int    vehicleType:    0
    property int    subsType
    property int    subsConsentration
    property real   alt
    //    property bool   isCheckedUAVBox
    //    property bool   isCheckedUGVBox

    property var    _color
    property int    _indicatorRadius:   15
    property int    _labelMargin:       2
    property int    _labelRadius:       _indicatorRadius + _labelMargin


    sourceItem: Item {
        id:         vehicleItem
        width:      indicator.width
        height:     indicator.height
        Component.onCompleted: {
            if (subsConsentration == 0) {
                _color = 'green'
            }else if (subsConsentration == 1) {
                _color = 'yellow'
            }else if (subsConsentration == 2) {
                _color = 'blue'
            }else {
                _color = 'red'
            }
        }
        Rectangle {
            id:                     labelControl
            anchors.leftMargin:     -((_labelMargin * 2) + indicator.width)
            anchors.rightMargin:    -(_labelMargin * 2)
            anchors.fill:           labelControlLabel
            color:                  'white'
            opacity:                0.5
            radius:                 _labelRadius
            visible:                (vehicleType == 0) ? true:false
        }

        Label {
            id:                     labelControlLabel
            anchors.topMargin:      -_labelMargin
            anchors.bottomMargin:   -_labelMargin
            anchors.leftMargin:     _labelMargin
            anchors.left:           indicator.right
            anchors.top:            indicator.top
            anchors.bottom:         indicator.bottom
            color:                  'black'
            text:                   alt
            verticalAlignment:      Text.AlignVCenter
            visible:                labelControl.visible
        }

        Rectangle {
            id:                             indicator
            anchors.horizontalCenter:       parent.left
            anchors.verticalCenter:         parent.top
            width:                          _indicatorRadius * 2
            height:                         width
            color:                          _color
            radius:                         _indicatorRadius
            Label {
                anchors.fill:           parent
                horizontalAlignment:    Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  'white'
                font.pointSize:         ScreenTools.defaultFontPointSize
                fontSizeMode:           Text.HorizontalFit
                text:                   _index
            }
        }
    }


    //        Image {
    //            id:                 vehicleIcon
    //            source:             _adsbVehicle ? "/qmlimages/adsbVehicle.svg" : vehicle.vehicleImageOpaque
    //            mipmap:             true
    //            width:              size
    //            sourceSize.width:   size
    //            fillMode:           Image.PreserveAspectFit

    //            transform: Rotation {
    //                origin.x:       vehicleIcon.width  / 2
    //                origin.y:       vehicleIcon.height / 2
    //                angle:          isNaN(heading) ? 0 : heading
    //            }
    //        }

    //        QGCMapLabel {
    //            id:                         vehicleLabel
    //            anchors.top:                parent.bottom
    //            anchors.horizontalCenter:   parent.horizontalCenter
    //            map:                        _map
    //            text:                       vehicleLabelText
    //            font.pointSize:             ScreenTools.smallFontPointSize
    //            visible:                    _adsbVehicle ? !isNaN(altitude) : _multiVehicle

    //            property string vehicleLabelText: visible ?
    //                                                  (_adsbVehicle ?
    //                                                       QGroundControl.metersToAppSettingsDistanceUnits(altitude).toFixed(0) + " " + QGroundControl.appSettingsDistanceUnitsString :
    //                                                       (_multiVehicle ? qsTr("Vehicle %1").arg(vehicle.id) : "")) :
    //                                                  ""

    //        }

    //        QGCMapLabel {
    //            anchors.top:                vehicleLabel.bottom
    //            anchors.horizontalCenter:   parent.horizontalCenter
    //            map:                        _map
    //            text:                       vehicleLabelText
    //            font.pointSize:             ScreenTools.smallFontPointSize
    //            visible:                    _adsbVehicle ? !isNaN(altitude) : _multiVehicle

    //            property string vehicleLabelText: visible && _adsbVehicle ? callsign : ""
    //        }

}
