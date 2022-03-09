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

import QtGraphicalEffects 1.0

import QtQuick 2.12
import QtQuick.Controls 2.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

ScrollView {
  id: scrollView

  anchors {
  top: parent.top
  }
  width: parent.width
  height: parent.height

  contentWidth: - 1 //no horizontal scrolling

  property bool grabFocus: false
  property bool showDescriptions: false
  property int iconSize: units.iconSizes.medium

  property var pinnedModel: [globalFavorites, rootModel.modelForRow(0), rootModel.modelForRow(1)]
  property var allAppsModel: [rootModel.modelForRow(2)]

  property var currentStateIndex: plasmoid.configuration.defaultPage

  property bool hasListener: false
  property bool isRight: true

  property var scrollpositon: 0.0
  property var scrollheight: 0.0

  function updateModels() {
      item.pinnedModel = [globalFavorites, rootModel.modelForRow(0), rootModel.modelForRow(1)]
      item.allAppsModel = [rootModel.modelForRow(2)]
  }

  function reset(){
    ScrollBar.vertical.position = 0
    sortingImage.state = sortingImage.states[plasmoid.configuration.defaultPage].name
    currentStateIndex = plasmoid.configuration.defaultPage
  }
  function get_position(){
    return ScrollBar.vertical.position;
  }
  function get_size(){
    return ScrollBar.vertical.size;
  }
  Connections {
      target: root
      function onVisibleChanged() {
        sortingImage.state = sortingImage.states[plasmoid.configuration.defaultPage].name
        currentStateIndex = plasmoid.configuration.defaultPage
      }
  }
  onContentHeightChanged: {
    ScrollBar.vertical.position = scrollpositon * scrollheight / scrollView.contentHeight
  }
  Column {
    id: column
    width: parent.width
    onPositioningComplete: {
      scrollView.contentHeight = height
      if (height < backdrop.height) {
        scrollView.contentHeight = backdrop.height + 1
      }
    }
    Item { //Spacer
      width: 1
      height: 20 * PlasmaCore.Units.devicePixelRatio
    }
    Image {
      id: starImage
        source: "icons/feather/star.svg"
        width: 15 * PlasmaCore.Units.devicePixelRatio
        height: width
      PlasmaComponents.Label {
        x: parent.width + 10 * PlasmaCore.Units.devicePixelRatio
        anchors.verticalCenter: parent.verticalCenter
        text: i18n("Favorite Apps")
        color: main.textColor
        font.family: main.textFont
        font.pixelSize: 12 * PlasmaCore.Units.devicePixelRatio
      }
      ColorOverlay {
        visible: plasmoid.configuration.theming != 0
        anchors.fill: starImage
        source: starImage
        color: main.textColor
      }
    }
    Item { //Spacer
      width: 1
      height: 10 * PlasmaCore.Units.devicePixelRatio
    }
    Flow { //Favorites
      id: flow
      x: 0
      width: scrollView.width - 10 * PlasmaCore.Units.devicePixelRatio
      Repeater {
        model: pinnedModel[0]
        delegate:
        FavoriteItem {
          id: favitem
        }
      }
    }
    Item { //Spacer
      width: 1
      height: 24 * PlasmaCore.Units.devicePixelRatio
    }
    Image {
      id: sortingImage
      width: 15 * PlasmaCore.Units.devicePixelRatio
      height: width
      //I don't like it this way but I have to assign custom images anyways, so it's not too bad... right?
      states: [
      State {
        name: "all";
        PropertyChanges { target: sortingLabel; text: i18n("All")}
        PropertyChanges { target: sortingImage; source: 'icons/feather/file-text.svg'}
      },
      State {
        name: "dev";
        PropertyChanges { target: sortingLabel; text: i18n("Developement")}
        PropertyChanges { target: sortingImage; source: 'icons/feather/code.svg'}
        PropertyChanges { target: (currentStateIndex % 2 == 0 ? categoriesRepeater : categoriesRepeater2); model: rootModel.modelForRow(3)}
      },
      State {
        name: "games";
        PropertyChanges { target: sortingLabel; text: i18n("Games")}
        PropertyChanges { target: sortingImage; source: 'icons/lucide/gamepad-2.svg'}
        PropertyChanges { target: (currentStateIndex % 2 == 0 ? categoriesRepeater : categoriesRepeater2); model: rootModel.modelForRow(4)}
      },
      State {
        name: "graphics";
        PropertyChanges { target: sortingLabel; text: i18n("Graphics")}
        PropertyChanges { target: sortingImage; source: 'icons/feather/image.svg'}
        PropertyChanges { target: (currentStateIndex % 2 == 0 ? categoriesRepeater : categoriesRepeater2); model: rootModel.modelForRow(5)}
      },
      State {
        name: "internet";
        PropertyChanges { target: sortingLabel; text: i18n("Internet")}
        PropertyChanges { target: sortingImage; source: 'icons/feather/globe.svg'}
        PropertyChanges { target: (currentStateIndex % 2 == 0 ? categoriesRepeater : categoriesRepeater2); model: rootModel.modelForRow(6)}
      },
      State {
        name: "multimedia";
        PropertyChanges { target: sortingLabel; text: i18n("Multimedia")}
        PropertyChanges { target: sortingImage; source: 'icons/lucide/film.svg'}
        PropertyChanges { target: (currentStateIndex % 2 == 0 ? categoriesRepeater : categoriesRepeater2); model: rootModel.modelForRow(8)}
      },
      State {
        name: "office";
        PropertyChanges { target: sortingLabel; text: i18n("Office")}
        PropertyChanges { target: sortingImage; source: 'icons/lucide/paperclip.svg'}
        PropertyChanges { target: (currentStateIndex % 2 == 0 ? categoriesRepeater : categoriesRepeater2); model: rootModel.modelForRow(9)}
      },
      State {
        name: "science";
        PropertyChanges { target: sortingLabel; text: i18n("Science & Math")}
        PropertyChanges { target: sortingImage; source: 'icons/lucide/flask-conical.svg'}
        PropertyChanges { target: (currentStateIndex % 2 == 0 ? categoriesRepeater : categoriesRepeater2); model: rootModel.modelForRow(10)}
      },
      State {
        name: "settings";
        PropertyChanges { target: sortingLabel; text: i18n("Settings")}
        PropertyChanges { target: sortingImage; source: 'icons/feather/settings.svg'}
        PropertyChanges { target: (currentStateIndex % 2 == 0 ? categoriesRepeater : categoriesRepeater2); model: rootModel.modelForRow(11)}
      },
      State {
        name: "system";
        PropertyChanges { target: sortingLabel; text: i18n("System")}
        PropertyChanges { target: sortingImage; source: 'icons/lucide/cpu.svg'}
        PropertyChanges { target: (currentStateIndex % 2 == 0 ? categoriesRepeater : categoriesRepeater2); model: rootModel.modelForRow(12)}
      },
      State {
        name: "utilities";
        PropertyChanges { target: sortingLabel; text: i18n("Utilities")}
        PropertyChanges { target: sortingImage; source: 'icons/feather/tool.svg'}
        PropertyChanges { target: (currentStateIndex % 2 == 0 ? categoriesRepeater : categoriesRepeater2); model: rootModel.modelForRow(13)}
      },
      State {
        name: "lost";
        PropertyChanges { target: sortingLabel; text: i18n("Lost & Found")}
        PropertyChanges { target: sortingImage; source: 'icons/feather/trash-2.svg'}
        PropertyChanges { target: (currentStateIndex % 2 == 0 ? categoriesRepeater : categoriesRepeater2); model: rootModel.modelForRow(7)}
      }
      ]
      PlasmaComponents.Label {
        id: sortingLabel
        x: parent.width + 10 * PlasmaCore.Units.devicePixelRatio
        anchors.verticalCenter: parent.verticalCenter
        text: i18n("All")
        color: main.textColor
        font.family: main.textFont
        font.pixelSize: 12 * PlasmaCore.Units.devicePixelRatio
      }
      MouseArea {
        id: mouseArea
        width: parent.width + sortingLabel.width + 5 * PlasmaCore.Units.devicePixelRatio
        height: parent.height
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: {
          if (mouse.button == Qt.LeftButton) {
            isRight = false
            currentStateIndex += 1
          } else if (mouse.button == Qt.RightButton) {
            isRight = true
            currentStateIndex -= 1
          } else if (mouse.button == Qt.MiddleButton) {
            isRight = false
            currentStateIndex = plasmoid.configuration.defaultPage
          }
          if (currentStateIndex > sortingImage.states.length - 1) {
            currentStateIndex = 0
          } else if (currentStateIndex < 0) {
            currentStateIndex = sortingImage.states.length - 1
          }
          sortingImage.state = sortingImage.states[currentStateIndex].name
        }
      }
      ColorOverlay {
        visible: plasmoid.configuration.theming != 0
        anchors.fill: sortingImage
        source: sortingImage
        color: main.textColor
      }
    }
    Item { //Spacer
      id: spacer
      width: 1
      height: 10 * PlasmaCore.Units.devicePixelRatio
    }

      Grid {
        id: allAppsGrid
        x: - 10 * PlasmaCore.Units.devicePixelRatio
        columns: 1
        width: scrollView.width - 10 * PlasmaCore.Units.devicePixelRatio
        visible: opacity > 0
        Repeater {
          id: allAppsRepeater
          model: allAppsModel[0]
          Repeater {
            id: repeater2
            model: allAppsRepeater.model.modelForRow(index)
            GenericItem {
              id: genericItem
              triggerModel: repeater2.model
            }
          }
        }
        states: [
        State {
          name: "hidden"; when: (sortingImage.state != 'all')
          PropertyChanges { target: allAppsGrid; opacity: 0.0 }
          PropertyChanges { target: allAppsGrid; x: (!isRight ? -20 * PlasmaCore.Units.devicePixelRatio : 0) }
        },
        State {
          name: "shown"; when: (sortingImage.state == 'all')
          PropertyChanges { target: allAppsGrid; opacity: 1.0 }
          PropertyChanges { target: allAppsGrid; x: -10 }
        }]
        transitions: [
          Transition {
            to: "hidden"
            PropertyAnimation { properties: 'opacity'; duration: 80; easing: Easing.InQuart}
            PropertyAnimation { properties: 'x'; from: -10 * PlasmaCore.Units.devicePixelRatio; duration: 80;easing: Easing.InQuart}
          },
          Transition {
            to: "shown"
            PropertyAnimation { properties: 'opacity'; duration: 80; easing: Easing.InQuart}
            PropertyAnimation { properties: 'x'; from: (isRight ? -20 * PlasmaCore.Units.devicePixelRatio : 0); duration: 80; easing: Easing.InQuart}
          }
        ]
        onStateChanged: {
          if (state == 'hidden') {
            scrollpositon = scrollView.ScrollBar.vertical.position
            scrollheight = scrollView.contentHeight
          }
        }
      }
      Grid { //Categories
        id: appCategories
        columns: 1
        width: scrollView.width - 10 * PlasmaCore.Units.devicePixelRatio
        visible: opacity > 0
        Repeater {
          id: categoriesRepeater
          delegate:
          GenericItem {
            id: genericItemCat
            triggerModel: categoriesRepeater.model
          }
        }
        states: [
        State {
          name: "hidden"; when: (currentStateIndex % 2 === 1)
          PropertyChanges { target: appCategories; opacity: 0.0 }
          PropertyChanges { target: appCategories; x: (isRight ? -20 * PlasmaCore.Units.devicePixelRatio : 0) }
        },
        State {
          name: "shown"; when: (currentStateIndex % 2 === 0)
          PropertyChanges { target: appCategories; opacity: 1.0 }
          PropertyChanges { target: appCategories; x: -10 * PlasmaCore.Units.devicePixelRatio }
        }]
        transitions: [
          Transition {
            to: "hidden"
            PropertyAnimation { properties: 'opacity'; duration: 80; easing: Easing.InQuart}
            PropertyAnimation { properties: 'x'; from: -10 * PlasmaCore.Units.devicePixelRatio; duration: 80; easing: Easing.InQuart}
          },
          Transition {
            to: "shown"
            PropertyAnimation { properties: 'opacity'; duration: 80; easing: Easing.InQuart}
            PropertyAnimation { properties: 'x'; from: (isRight ? -20 * PlasmaCore.Units.devicePixelRatio : 0); duration: 80; easing: Easing.InQuart}
          }
        ]
        onStateChanged: {
          if (state == 'hidden') {
            scrollpositon = scrollView.ScrollBar.vertical.position
            scrollheight = scrollView.contentHeight
          }
        }
      }

      Grid { //Categories
        id: appCategories2
        columns: 1
        width: scrollView.width - 10 * PlasmaCore.Units.devicePixelRatio
        visible: opacity > 0
        Repeater {
          id: categoriesRepeater2
          delegate:
          GenericItem {
            id: genericItemCat2
            triggerModel: categoriesRepeater2.model
          }
        }
        states: [
        State {
          name: "hidden"; when: (currentStateIndex % 2 === 0)
          PropertyChanges { target: appCategories2; opacity: 0.0 }
          PropertyChanges { target: appCategories2; x: (isRight ? -20 * PlasmaCore.Units.devicePixelRatio : 0) }
        },
        State {
          name: "shown"; when: (currentStateIndex % 2 === 1)
          PropertyChanges { target: appCategories2; opacity: 1.0 }
          PropertyChanges { target: appCategories2; x: -10  * PlasmaCore.Units.devicePixelRatio}
        }]
        transitions: [
          Transition {
            to: "hidden"
            PropertyAnimation { properties: 'opacity'; duration: 80; easing: Easing.InQuart}
            PropertyAnimation { properties: 'x'; from: -10 * PlasmaCore.Units.devicePixelRatio; duration: 80; easing: Easing.InQuart}
          },
          Transition {
            to: "shown"
            PropertyAnimation { properties: 'opacity'; duration: 80; easing: Easing.InQuart}
            PropertyAnimation { properties: 'x'; from: (isRight ? -20 * PlasmaCore.Units.devicePixelRatio : 0);duration: 80; easing: Easing.InQuart}
          }
        ]
        onStateChanged: {
          if (state == 'hidden') {
            scrollpositon = scrollView.ScrollBar.vertical.position
            scrollheight = scrollView.contentHeight
          }
        }
      }

    Item { //Spacer
      width: 1
      height: 20 * PlasmaCore.Units.devicePixelRatio
    }
  }
}
