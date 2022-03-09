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

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.kicker 0.1 as Kicker

import QtQuick.Window 2.2
import org.kde.plasma.components 3.0 as PlasmaComponents
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0

PlasmaExtras.ScrollArea {
  id: runnerList
  focus: true
  property alias model: repeater.model
  property alias count: repeater.count

  horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
  verticalScrollBarPolicy: Qt.ScrollBarAsNeeded

  property int currentMainIndex: 0
  property int currentSubIndex: 0

  onFocusChanged: {
    if (!focus) {
      for (var i = 0; i < repeater.count; i++) {
        repeater.itemAt(i).nGrid.focus = false
      }
    } else {
      currentMainIndex = 0
      for (var i = 0; i < repeater.count; ++i) {
        if (repeater.itemAt(i).nGrid.count > 0) {
          currentSubIndex = i
          repeater.itemAt(i).nGrid.setFocus();
          break
        }
      }
    }
  }

  function get_position(){
    return flickableItem.contentY / (flickableItem.contentHeight - height)
  }
  function get_size(){
    return (flickableItem.contentHeight <= height ? -1 : 0.99999)
  }
  function setFocus() {
    currentMainIndex = 0
    for (var i = 0; i < repeater.count; ++i) {
      if (repeater.itemAt(i).nGrid.count > 0) {
        currentSubIndex = i
        repeater.itemAt(i).nGrid.setFocus();
        break
      }
    }
  }
  function triggerFirst(){
    repeater.itemAt(currentSubIndex).nGrid.currentItem.trigger()
  }

  Column {
    y: 25 * PlasmaCore.Units.devicePixelRatio
    x: -10 * PlasmaCore.Units.devicePixelRatio
    Repeater {
      id: repeater
      delegate:
      Item {
        id: section
        width: runnerList.width
        height: headerLabel.height + navGrid.height + (index == repeater.count - 1 ? 0 : 10)
        visible: navGrid.count > 0
        property Item nGrid: navGrid
        Item {
          id: headerLabel
          anchors.top: parent.top
          height: image.height
          Image {
            id: image
            x: 20 * PlasmaCore.Units.devicePixelRatio
            source: repeater.model.modelForRow(index).description === 'Command Line' ? "icons/feather/code.svg" : repeater.model.modelForRow(index).description == 'Desktop Search' ? "icons/feather/search.svg" : "icons/feather/file-text.svg"
            width: 15 * PlasmaCore.Units.devicePixelRatio
            height: width
            //visible: repeater.model.modelForRow(index).count > 0
            PlasmaComponents.Label {
              x: parent.width + 10 * PlasmaCore.Units.devicePixelRatio
              anchors.verticalCenter: parent.verticalCenter
              text: repeater.model.modelForRow(index).description
              color: main.textColor
              font.family: main.textFont
              font.pixelSize: 12 * PlasmaCore.Units.devicePixelRatio
            }
            ColorOverlay {
              visible: plasmoid.configuration.theming != 0
              anchors.fill: image
              source: image
              color: main.textColor
            }
          }
        }
        NavGrid {
          id: navGrid
          width: runnerList.width
          height: Math.ceil(count * (42 * PlasmaCore.Units.devicePixelRatio )) + 10 * PlasmaCore.Units.devicePixelRatio
          anchors.top: headerLabel.bottom
          subIndex: index
          triggerModel: repeater.model.modelForRow(index)

          onFocusChanged: {
            if (focus) {
              runnerList.focus = true;
            }
          }
          onCountChanged: {
            if (index == 0 && count > 0) {
              currentIndex = 0;
              focus = true;
            }
          }
          onCurrentItemChanged: {
            if (!currentItem) {
              return;
            }
            if (currentItem.isMouseHighlight) {
              return
            }
            if (index == 0 && currentIndex === 0) {
              runnerList.flickableItem.contentY = 0;
              return;
            }
            var y = currentItem.y;
            y = contentItem.mapToItem(runnerList.flickableItem.contentItem, 0, y).y;

            if (y < runnerList.flickableItem.contentY) {
              runnerList.flickableItem.contentY = y;
            } else {
              y += currentItem.height + 10 * PlasmaCore.Units.devicePixelRatio + 15 * PlasmaCore.Units.devicePixelRatio;
              y -= runnerList.flickableItem.contentY;
              y -= runnerList.viewport.height;

              if (y > 0) {
                runnerList.flickableItem.contentY += y;
              }
            }
          }
          onKeyNavUp: {
            if (index > 0) {
              for (var i = index - 1; i > -1; --i) {
                if (repeater.itemAt(i).nGrid.count > 0) {
                  repeater.itemAt(i).nGrid.setFocusLast()
                  currentSubIndex = index - 1
                  break
                }
              }
            }
          }

          onKeyNavDown: {
            if (index < repeater.count - 1) {
              for (var i = index + 1; i < repeater.count; ++i) {
                if (repeater.itemAt(i).nGrid.count > 0) {
                  repeater.itemAt(i).nGrid.setFocus()
                  currentSubIndex = index + 1
                  break
                }
              }
            }
          }
        }
        Kicker.WheelInterceptor {
          anchors.fill: navGrid
          z: 1
          destination: findWheelArea(runnerList.flickableItem)
        }
      }
    }
    Item {
      width: 1
      height: 40 * PlasmaCore.Units.devicePixelRatio
    }
  }
}
