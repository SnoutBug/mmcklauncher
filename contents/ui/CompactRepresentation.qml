/*****************************************************************************
 *   Copyright (C) 2013-2014 by Eike Hein <hein@kde.org>                     *
 *   Copyright (C) 2021 by Prateek SU <pankajsunal123@gmail.com>             *
 *   Copyright (C) 2022 by Friedrich Schriewer <friedrich.schriewer@gmx.net> *
 *                                                                           *
 *   This program is free software; you can redistribute it and/or modify    *
 *   it under the terms of the GNU General Public License as published by    *
 *   the Free Software Foundation; either version 2 of the License, or       *
 *   (at your option) any later version.                                     *
 *                                                                           *
 *   This program is distributed in the hope that it will be useful,         *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           *
 *   GNU General Public License for more details.                            *
 *                                                                           *
 *   You should have received a copy of the GNU General Public License       *
 *   along with this program; if not, write to the                           *
 *   Free Software Foundation, Inc.,                                         *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .          *
 ****************************************************************************/

import QtQuick 2.12
import QtQuick.Layouts 1.12

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: root

    property QtObject dashWindow: null
    readonly property bool useCustomButtonImage: (plasmoid.configuration.useCustomButtonImage && plasmoid.configuration.customButtonImage.length != 0)

    PlasmaCore.IconItem {
        id: buttonIcon

        width: plasmoid.configuration.activationIndicator ? parent.width * 0.65 : parent.width
        height: plasmoid.configuration.activationIndicator ? parent.height * 0.65 : parent.height
        anchors.centerIn: parent

        source: useCustomButtonImage ? plasmoid.configuration.customButtonImage : plasmoid.configuration.icon

        active: mouseArea.containsMouse

        smooth: true

        Rectangle {
          id: indicator
          width: 0
          anchors.horizontalCenter: parent.horizontalCenter
          height: 3 * PlasmaCore.Units.devicePixelRatio
          radius: 10
          y: parent.height + height
          color: plasmoid.configuration.indicatorColor
          visible: plasmoid.configuration.activationIndicator

          states: [
            State { name: "inactive"
            when: !dashWindow.visible
            PropertyChanges {
                target: indicator
                width: 0

              }
            },
            State { name: "active"
            when: dashWindow.visible
            PropertyChanges {
                target: indicator
                width: parent.width * 0.65
              }
            }
          ]
          transitions: [
            Transition {
              NumberAnimation { properties: 'width'; duration: 60}
            }
          ]
        }
    }

    MouseArea
    {
        id: mouseArea

        anchors.fill: parent

        hoverEnabled: true

        onClicked: {
            dashWindow.visible = !dashWindow.visible;
        }
    }

    Component.onCompleted: {
        dashWindow = Qt.createQmlObject("MenuRepresentation {}", root);
        plasmoid.activated.connect(function() {
            dashWindow.visible = !dashWindow.visible;
        });
    }
}
