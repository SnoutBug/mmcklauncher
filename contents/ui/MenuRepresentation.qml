/***************************************************************************
 *   Copyright (C) 2014 by Weng Xuetian <wengxt@gmail.com>
 *   Copyright (C) 2013-2017 by Eike Hein <hein@kde.org>                   *
 *   Copyright (C) 2021 by Prateek SU <pankajsunal123@gmail.com>           *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.12
import QtQuick.Layouts 1.12
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

PlasmaCore.Dialog {
    id: root

    type: "Normal"

    objectName: "popupWindow"
    flags: Qt.WindowStaysOnTopHint
    //location: PlasmaCore.Types.Floating
    hideOnWindowDeactivate: true

    onVisibleChanged: {
        if (!visible) {
            reset();
        } else {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
            requestActivate();
        }
    }

    function toggle() {
        root.visible = false;
    }

    function reset() {
        main.reset()
    }

    function popupPosition(width, height) {
        var screenAvail = plasmoid.availableScreenRect;
        var screenGeom = plasmoid.screenGeometry;
        //QtBug - QTBUG-64115
        var screen = Qt.rect(screenAvail.x + screenGeom.x,
            screenAvail.y + screenGeom.y,
            screenAvail.width,
            screenAvail.height);

        var offset = 0;

        // Fall back to bottom-left of screen area when the applet is on the desktop or floating.
        var x = offset;
        var y = screen.height - height - offset;
        var horizMidPoint = screen.x + (screen.width / 2);
        var vertMidPoint = screen.y + (screen.height / 2);
        var appletTopLeft = parent.mapToGlobal(0, 0);
        var appletBottomLeft = parent.mapToGlobal(0, parent.height);

        if (plasmoid.configuration.isCentered){
          x = horizMidPoint - width / 2;
        } else {
          x = (appletTopLeft.x < horizMidPoint) ? screen.x : (screen.x + screen.width) - width;
        }

        y = screen.height - fs.height + root.margins.bottom + root.margins.top;

        return Qt.point(x, y);
    }

    FocusScope {
        id: fs
        focus: true
        Layout.minimumWidth: 515//450
        Layout.minimumHeight: 600//530
        Layout.maximumWidth: Layout.minimumWidth
        Layout.maximumHeight: Layout.minimumHeight

        Item {
          x: - root.margins.left
          y: - root.margins.top
          width: parent.width + root.margins.left + root.margins.right
          height: parent.height + root.margins.top + root.margins.bottom

          MainView {
            id: main
          }
        }


        Keys.onPressed: {
            if (event.key == Qt.Key_Escape) {
                root.visible = false;
            }
        }
    }

    function refreshModel() {
        main.reload()
    }

    Component.onCompleted: {
        rootModel.refreshed.connect(refreshModel)
        kicker.reset.connect(reset);
        reset();
    }
}
