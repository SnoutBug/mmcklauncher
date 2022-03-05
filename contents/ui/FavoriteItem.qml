/*****************************************************************************
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
import QtGraphicalEffects 1.0
import QtQuick.Window 2.2
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kcoreaddons 1.0 as KCoreAddons
import org.kde.kirigami 2.13 as Kirigami

import "../code/tools.js" as Tools

Item {
  id: favItem
  width: rect.width + 10 * PlasmaCore.Units.devicePixelRatio
  height: rect.height + 10 * PlasmaCore.Units.devicePixelRatio

  signal itemActivated(int index, string actionId, string argument)

  property bool highlighted: false
  property bool isDraging: false

  property bool hasActionList: ((model.favoriteId !== null)
      || (("hasActionList" in model) && (model.hasActionList === true)))


  function openActionMenu(x, y) {
      var actionList = hasActionList ? model.actionList : [];
      console.log(model.favoriteId)
      Tools.fillActionMenu(i18n, actionMenu, actionList, globalFavorites, model.favoriteId);
      actionMenu.visualParent = favItem;
      actionMenu.open(x, y);
  }

  function actionTriggered(actionId, actionArgument) {
      var close = (Tools.triggerAction(kicker.globalFavorites, index, actionId, actionArgument) === true);
      if (close) {
          root.toggle();
      }
  }
  Rectangle {
    id: rect
    x: 10 * PlasmaCore.Units.devicePixelRatio
    y: 10 * PlasmaCore.Units.devicePixelRatio
    width: appname.width + appicon.width + 3 * (10 * PlasmaCore.Units.devicePixelRatio) + 5 * PlasmaCore.Units.devicePixelRatio
    height: 45 * PlasmaCore.Units.devicePixelRatio
    z: -20
    color: plasmoid.configuration.theming == 0 ? "#202124" : plasmoid.configuration.theming == 1 ? "#E0E1E3" : PlasmaCore.Theme.buttonBackgroundColor
    border.color: "transparent"
    border.width: 1
    radius: 6
    PlasmaCore.IconItem {
      x: 10 * PlasmaCore.Units.devicePixelRatio
      anchors.verticalCenter: rect.verticalCenter
      id: appicon
      width: 25 * PlasmaCore.Units.devicePixelRatio
      height: width
      source: model.decoration
      PlasmaComponents.Label {
        id: appname
        x: appicon.width + 10 * PlasmaCore.Units.devicePixelRatio
        anchors.verticalCenter: appicon.verticalCenter
        text: ("name" in model ? model.name : model.display)
        color: plasmoid.configuration.theming != 2 ? main.textColor : PlasmaCore.Theme.buttonTextColor
        font.family: main.textFont
        font.pixelSize: 12 * PlasmaCore.Units.devicePixelRatio
      }
    }
    states: [
    State {
      name: "highlight"; when: (highlighted)
      PropertyChanges { target: rect; color: plasmoid.configuration.theming == 0 ? "#292A2E" : plasmoid.configuration.theming == 1 ? "#FFFFFF" : PlasmaCore.Theme.buttonHoverColor }
    },
    State {
      name: "default"; when: (!highlighted)
      PropertyChanges { target: rect; color: plasmoid.configuration.theming == 0 ? "#202124" : plasmoid.configuration.theming == 1 ? "#F7F7F7" : PlasmaCore.Theme.buttonBackgroundColor }
    }]
    transitions: highlight
  }
  MouseArea {
      id: ma
      anchors.fill: parent
      z: parent.z + 1
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      cursorShape: Qt.PointingHandCursor
      hoverEnabled: true
      onClicked: {
        if (!isDraging) {
          if (mouse.button == Qt.RightButton ) {
            if (favItem.hasActionList) {
                var mapped = mapToItem(favItem, mouse.x, mouse.y);
                openActionMenu(mapped.x, mapped.y);
            }
          } else {
            kicker.globalFavorites.trigger(index, "", null);
            root.toggle()
          }
        }
      }
      onReleased: {
        isDraging: false
      }
      onEntered: {
        rect.state = "highlight"
      }
      onExited: {
        rect.state = "default"
      }
      onPositionChanged: {
        isDraging = pressed
        if (pressed){
          if ("pluginName" in model) {
            dragHelper.startDrag(kicker, model.url, model.decoration,
                "text/x-plasmoidservicename", model.pluginName);
          } else {
            dragHelper.startDrag(kicker, model.url, model.decoration);
          }
        }
      }
  }
  ActionMenu {
      id: actionMenu

      onActionClicked: {
          visualParent.actionTriggered(actionId, actionArgument);
          root.toggle()
      }
  }
  Transition {
    id: highlight
    ColorAnimation {duration: 100 }
  }
}
