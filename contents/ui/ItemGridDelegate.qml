/***************************************************************************
 *   Copyright (C) 2015 by Eike Hein <hein@kde.org>                        *
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

import "../code/tools.js" as Tools

Item {
    id: item
    width: GridView.view.cellWidth
    height: GridView.view.cellHeight
    property bool showLabel: true
    property bool showDescription: false
    property bool increaseLeftSpacing: false
    property int itemIndex: model.index
    property string favoriteId: model.favoriteId !== undefined ? model.favoriteId : ""
    property url url: model.url !== undefined ? model.url : ""
    property variant icon: model.decoration !== undefined ? model.decoration : ""
    property var m: model
    property bool hasActionList: ((model.favoriteId !== null)
        || (("hasActionList" in model) && (model.hasActionList === true)))

    Accessible.role: Accessible.MenuItem
    Accessible.name: model.display
    function openActionMenu(x, y) {
        var actionList = hasActionList ? model.actionList : [];
        Tools.fillActionMenu(i18n, actionMenu, actionList, GridView.view.model.favoritesModel, model.favoriteId);
        actionMenu.visualParent = item;
        actionMenu.open(x, y);
    }

    function actionTriggered(actionId, actionArgument) {
        var close = (Tools.triggerAction(GridView.view.model, model.index, actionId, actionArgument) === true);

        if (close) {
            root.toggle();
        }
    }
    PlasmaCore.IconItem {
        id: icon
        x: increaseLeftSpacing ? units.smallSpacing : 0
        anchors.verticalCenter: parent.verticalCenter
        width: iconSize
        height: width
        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        animated: false
        usesPlasmaTheme: item.GridView.view.usesPlasmaTheme
        source: model.decoration
    }


    ColumnLayout {
        width: parent.width * 0.75
        visible: showLabel
        anchors {
            left: icon.right
            leftMargin: PlasmaCore.Units.smallSpacing * 4
            rightMargin: anchors.leftMargin / 2
            verticalCenter: parent.verticalCenter
        }
        spacing: 0

        PlasmaComponents.Label {
            id: label
            Layout.maximumWidth: parent.width
            maximumLineCount: 1
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            font.pointSize: 9
            color: theme.textColor
            text: ("name" in model ? model.name : model.display)
        }
        PlasmaComponents.Label {
            Layout.maximumWidth: parent.width
            maximumLineCount: 1
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            color: theme.textColor
            text: model.description
            font.pointSize: 8
            visible: showDescription
            opacity: 0.7
        }
    }

    PlasmaCore.ToolTipArea {
        id: toolTip
        property string text: model.display
        anchors.fill: parent
        active: label.truncated
        mainItem: toolTipDelegate

        onContainsMouseChanged: item.GridView.view.itemContainsMouseChanged(containsMouse)
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Menu && hasActionList) {
            event.accepted = true;
            openActionMenu(item);
        } else if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return)) {
            event.accepted = true;

            if ("trigger" in GridView.view.model) {
                GridView.view.model.trigger(index, "", null);
                root.toggle();
            }

            itemGrid.itemActivated(index, "", null);
        }
    }
}
