import QtQuick          2.3
import QtQuick.Controls 1.2
import QtLocation       5.3
import QtPositioning    5.3

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FlightMap     1.0

/// Simple Mission Item visuals
Item {
    id: root
    visible: true

    property var map        ///< Map control to place item in

    property real   _lat
    property real   _lon
    property real   _alt

    property int    _vehicleType
    property int    _substanceType
    property int    _subsConsentration
    property bool   _isCheckedUAVBox
    property bool   _isCheckedUGVBox

    property var    _color
    property int    _indicatorRadius:   15
    property int    _labelMargin:       2
    property int    _labelRadius:       _indicatorRadius + _labelMargin

    Component.onCompleted: {
        if (_subsConsentration == 0) {
            _color = 'green'
        }else if (_subsConsentration == 1) {
            _color = "#FFE000"
        }else if (_subsConsentration == 2) {
            _color = "#FFA500"
        }else if (_subsConsentration == 3){
            _color = "#FF5500"
        }else if (_subsConsentration == 4){
            _color = "#FF0000"
        }else {

        }

        var circle = Qt.createQmlObject(
                    "import QtQuick 2.0;" +
                    "import QtLocation 5.6 ;" +
                    "import QtQuick.Controls 1.2;"+
                    "import QGroundControl.ScreenTools 1.0;"+
                    "import QGroundControl.Palette     1.0;"+
                    "MapQuickItem {" +
                    "   id: circleItem;"+
                    "   sourceItem: Rectangle { " +
                    "               id:     recMain;"+
                    "                   Rectangle {"+
                    "                       id:                     labelControl;"+
                    "                       anchors.leftMargin:     -((_labelMargin * 2) + indicator.width);"+
                    "                       anchors.rightMargin:    -(_labelMargin * 2);"+
                    "                       anchors.fill:           labelControlLabel;"+
                    "                       color:                  'white';"+
                    "                       opacity:                0.5;"+
                    "                       radius:                 _labelRadius;"+
                    "                       visible:                (_vehicleType == 0) ? true:false;"+
                    "                   }"+

                    "                   Label {"+
                    "                       id:                     labelControlLabel;"+
                    "                       anchors.topMargin:      -_labelMargin;"+
                    "                       anchors.bottomMargin:   -_labelMargin;"+
                    "                       anchors.leftMargin:     _labelMargin;"+
                    "                       anchors.left:           indicator.right;"+
                    "                       anchors.top:            indicator.top;"+
                    "                       anchors.bottom:         indicator.bottom;"+
                    "                       color:                  'black';"+
                    "                       text:                   _alt;"+
                    "                       verticalAlignment:      Text.AlignVCenter;"+
                    "                       visible:                labelControl.visible;"+
                    "                   }"+

                    "                   Rectangle {"+
                    "                       id:                             indicator;"+
                    "                       anchors.horizontalCenter:       parent.left;"+
                    "                       anchors.verticalCenter:         parent.top;"+
                    "                       width:                          _indicatorRadius * 2;"+
                    "                       height:                         width;"+
                    "                       color:                          _color;"+
                    "                       radius:                         _indicatorRadius;"+

                    "                           Label {"+
                    "                               anchors.fill:           parent;"+
                    "                               horizontalAlignment:    Text.AlignHCenter;"+
                    "                               verticalAlignment:      Text.AlignVCenter;"+
                    "                               color:                  'white';"+
                    "                               font.pointSize:         ScreenTools.defaultFontPointSize;"+
                    "                               fontSizeMode:           Text.HorizontalFit;"+
                    "                               text:                   _index;"+
                    "                           }"+
                    "                   }"+
                                    "}"+
                    "   coordinate {"+
                    "       latitude: _lat;"+
                    "       longitude: _lon;"+
                    "       altitude: _alt;"+
                    "   }"+
                    "}"
                    , map)
        map.addMapItem(circle)
    }
}
