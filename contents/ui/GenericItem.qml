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
import QtQuick.Controls 2.15

import "../code/tools.js" as Tools

Item {
  id: allItem
  width: rect.width + 4 * PlasmaCore.Units.devicePixelRatio
  height: rect.height + 4 * PlasmaCore.Units.devicePixelRatio

  property bool highlighted: false
  property bool isDraging: false
  property bool canDrag: true
  property bool canNavigate: false
  property bool isMouseHighlight: false

  property int subIndex: 0

  signal highlightChanged

  property bool hasActionList: ((model.favoriteId !== null)
      || (("hasActionList" in model) && (model.hasActionList === true)))

  property var triggerModel

  function openActionMenu(x, y) {
      var actionList = hasActionList ? model.actionList : [];
      Tools.fillActionMenu(i18n, actionMenu, actionList, globalFavorites, model.favoriteId);
      actionMenu.visualParent = allItem;
      actionMenu.open(x, y);
  }
  function actionTriggered(actionId, actionArgument) {
      var close = (Tools.triggerAction(triggerModel, index, actionId, actionArgument) === true);
      if (close) {
          root.toggle();
      }
  }
  function trigger() {
    triggerModel.trigger(index, "", null);
    root.toggle()
  }
  function updateHighlight() {
    if (navGrid.currentIndex == index){
      highlighted = true
    } else {
      highlighted = false
    }
  }
  function deselect(){
    highlighted = false
    listView.currentIndex = -1
  }
  Rectangle {
    id: rect
    x: 10 * PlasmaCore.Units.devicePixelRatio
    y: 10 * PlasmaCore.Units.devicePixelRatio
    width: main.width - 40 * PlasmaCore.Units.devicePixelRatio - allItem.x
    height: 38 * PlasmaCore.Units.devicePixelRatio
    z: -20
    color: backdrop.color
    border.color: "transparent"
    border.width: 1
    radius: 6
    PlasmaCore.IconItem {
      x: 9 * PlasmaCore.Units.devicePixelRatio
      anchors.verticalCenter: rect.verticalCenter
      id: appicon
      width: 24 * PlasmaCore.Units.devicePixelRatio
      height: width
      source: model.decoration
      PlasmaComponents.Label {
        id: appname
        x: appicon.width + 9 * PlasmaCore.Units.devicePixelRatio
        anchors.verticalCenter: appicon.verticalCenter
        text: ("name" in model ? model.name : model.display)
        color: main.textColor
        font.family: main.textFont
        font.pixelSize: 12 * PlasmaCore.Units.devicePixelRatio
      }
    }
    states: [
    State {
      name: "highlight"; when: !canNavigate ? highlighted : runnerList.currentMainIndex == index && runnerList.currentSubIndex == subIndex
      PropertyChanges { target: rect; color: plasmoid.configuration.theming == 0 ? "#0E0E0F" : plasmoid.configuration.theming == 1 ? "#FFFFFF" : PlasmaCore.Theme.buttonFocusColor}
    },
    State {
      name: "default"; when: !canNavigate ? !highlighted : runnerList.currentMainIndex != index || runnerList.currentSubIndex != subIndex
      PropertyChanges { target: rect; color: backdrop.color}
    }]
    transitions: highlight
    onStateChanged: {
      if (state == 'default'){
        isMouseHighlight = false
      }
    }
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
          if (mouse.button == Qt.RightButton) {
            if (allItem.hasActionList) {
              var mapped = mapToItem(allItem, mouse.x, mouse.y);
              openActionMenu(mapped.x, mapped.y);
            }
          } else {
            trigger()
          }
        }
      }
      onReleased: {
        isDraging: false
      }
      onExited: {
        rect.state = "default"
        isMouseHighlight = false
      }
      onPositionChanged: {
        isDraging = pressed
        if (pressed && canDrag){
          if ("pluginName" in model) {
            dragHelper.startDrag(kicker, model.url, model.decoration,
                "text/x-plasmoidservicename", model.pluginName);
          } else {
            dragHelper.startDrag(kicker, model.url, model.decoration);
          }
        }
        if (containsMouse) {
          isMouseHighlight = true
          rect.state = "highlight"
          if (canNavigate) {
            if (runnerList.currentSubIndex != subIndex) {
              repeater.itemAt(runnerList.currentSubIndex).nGrid.currentIndex = -1
            }
            runnerList.currentSubIndex = subIndex
            runnerList.currentMainIndex = index
            listView.currentIndex = index
            listView.focus = true
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
