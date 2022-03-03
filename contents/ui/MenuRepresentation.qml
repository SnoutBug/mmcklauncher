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

    objectName: "popupWindow"
    flags: Qt.WindowStaysOnTopHint
    location: PlasmaCore.Types.Floating
    hideOnWindowDeactivate: true

    property int iconSize: units.iconSizes.medium
    property int iconSizeSide: units.iconSizes.smallMedium

    property int cellSize: iconSize + theme.mSize(theme.defaultFont).height
        + units.largeSpacing
        + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
            highlightItemSvg.margins.left + highlightItemSvg.margins.right))

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

    onHeightChanged: {
        var pos = popupPosition(width, height);
        x = pos.x;
        y = pos.y;
    }

    onWidthChanged: {
        var pos = popupPosition(width, height);
        x = pos.x;
        y = pos.y;
    }

    function toggle() {
        root.visible = false;
    }

    function reset() {
        mainColumnItem.reset()
    }

    function popupPosition(width, height) {
        var screenAvail = plasmoid.availableScreenRect;
        var screenGeom = plasmoid.screenGeometry;
        //QtBug - QTBUG-64115
        var screen = Qt.rect(screenAvail.x + screenGeom.x,
            screenAvail.y + screenGeom.y,
            screenAvail.width,
            screenAvail.height);

        var offset = units.smallSpacing;

        // Fall back to bottom-left of screen area when the applet is on the desktop or floating.
        var x = offset;
        var y = screen.height - height - offset;
        var horizMidPoint = screen.x + (screen.width / 2);
        var vertMidPoint = screen.y + (screen.height / 2);
        var appletTopLeft = parent.mapToGlobal(0, 0);
        var appletBottomLeft = parent.mapToGlobal(0, parent.height);
        if (plasmoid.configuration.menuPosition == 0) {
            x = plasmoid.location === PlasmaCore.Types.LeftEdge ? parent.width + panelSvg.margins.right + offset + 6 : plasmoid.location === PlasmaCore.Types.RightEdge ? appletTopLeft.x - panelSvg.margins.left - offset - width - 6 : horizMidPoint - width / 2;
            y = plasmoid.location === PlasmaCore.Types.TopEdge ? parent.height + panelSvg.margins.bottom + offset + 6 : plasmoid.location === PlasmaCore.Types.BottomEdge ? screen.height - height - offset - panelSvg.margins.top - 6 : vertMidPoint - height / 2;
        } else if (plasmoid.location === PlasmaCore.Types.BottomEdge) {
            if (plasmoid.configuration.menuPosition == 1)
                x = (appletTopLeft.x < horizMidPoint) ? screen.x + offset + 6 : (screen.x + screen.width) - width - offset - 6;
            else
                x = appletTopLeft.x - width / 2
            y = screen.height - height - offset - panelSvg.margins.top - 6;
        } else if (plasmoid.location === PlasmaCore.Types.TopEdge) {
            if (plasmoid.configuration.menuPosition == 1)
                x = (appletBottomLeft.x < horizMidPoint) ? screen.x + offset + 6 : (screen.x + screen.width) - width - offset - 6;
            else
                x = appletBottomLeft.x - width / 2
            y = parent.height + panelSvg.margins.bottom + offset + 6;
        } else if (plasmoid.location === PlasmaCore.Types.LeftEdge) {
            x = parent.width + panelSvg.margins.right + offset + 6;
            if (plasmoid.configuration.menuPosition == 1)
                y = (appletTopLeft.y < vertMidPoint) ? screen.y + offset + 6 : (screen.y + screen.height) - height - offset - 6;
            else
                y = appletTopLeft.y - height / 2
        } else if (plasmoid.location === PlasmaCore.Types.RightEdge) {
            x = appletTopLeft.x - panelSvg.margins.left - offset - width - 6;
            if (plasmoid.configuration.menuPosition == 1)
                y = (appletTopLeft.y < vertMidPoint) ? screen.y + offset + 6 : (screen.y + screen.height) - height - offset - 6;
            else
                y = appletTopLeft.y - height / 2
        }

        return Qt.point(x, y);
    }


    FocusScope {
        Layout.minimumWidth: mainColumnItem.width
        Layout.minimumHeight: cellSize * (5.1 + plasmoid.configuration.numberRows + (plasmoid.configuration.alwaysShowSearchBar ? 0.6 : 0))
        Layout.maximumWidth: Layout.minimumWidth
        Layout.maximumHeight: Layout.minimumHeight

        focus: true

        Row{
            anchors.fill: parent
            spacing: units.largeSpacing

            MainColumnItem{
                id: mainColumnItem
            }
        }


        Keys.onPressed: {
            if (event.key == Qt.Key_Escape) {
                root.visible = false;
            }
        }
    }

    function refreshModel() {
        mainColumnItem.reload()
        console.log("refresh model - menu 11")
    }

    Component.onCompleted: {
        rootModel.refreshed.connect(refreshModel)
        kicker.reset.connect(reset);
        reset();
    }
}
