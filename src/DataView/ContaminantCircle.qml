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
    visible:        coordinate.isValid

    property int    vehicleType:    0
    property int    subsType
    property int    subsConsentration
    property int    lastSubsConsentration
    property real   alt
    //    property bool   isCheckedUAVBox
    //    property bool   isCheckedUGVBox

    property color    _color: '#FFE000'
    property int    _indicatorRadius:   15
    property int    _labelMargin:       2
    property int    _labelRadius:       _indicatorRadius + _labelMargin

    function getColor(consentration)
    {
        if (subsConsentration == 0) {
            return('green')
        }else if (subsConsentration == 1) {
            return("#FFE000")
        }else if (subsConsentration == 2) {
            return("#FFA500")
        }else if (subsConsentration == 3){
            return("#FF5500")
        }else if (subsConsentration == 4){
            return("#FF0000")
        }else {

        }
    }

    sourceItem: Item {
        id:         vehicleItem
        width:      indicator.width
        height:     indicator.height

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
            color:                          getColor(subsConsentration)
            radius:                         _indicatorRadius
//            Label {
//                anchors.fill:           parent
//                horizontalAlignment:    Text.AlignHCenter
//                verticalAlignment:      Text.AlignVCenter
//                color:                  'white'
//                font.pointSize:         ScreenTools.defaultFontPointSize
//                fontSizeMode:           Text.HorizontalFit
//                text:                   _index
//            }
        }
    }
}
