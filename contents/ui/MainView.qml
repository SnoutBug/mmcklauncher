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
import QtQuick 2.15
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kcoreaddons 1.0 as KCoreAddons

Item {
  id: main
  anchors.fill: parent
  property bool searching: (searchBar.text != "")
  signal  newTextQuery(string text)

  readonly property color textColor: plasmoid.configuration.theming == 0 ? "#FFFFFF" : plasmoid.configuration.theming == 1 ? "#000000" : PlasmaCore.Theme.textColor
  readonly property string textFont: plasmoid.configuration.theming == 2 ? PlasmaCore.Theme.defaultFont : "SF Pro Text" //This is the font that was used in the original design by Max McKinney
  readonly property bool isTop: plasmoid.location == PlasmaCore.Types.TopEdge & plasmoid.configuration.launcherPosition != 2 & !plasmoid.configuration.floating

  KCoreAddons.KUser {
      id: kuser
  }

  PlasmaCore.DataSource {
      id: pmEngine
      engine: "powermanagement"
      connectedSources: ["PowerDevil", "Sleep States"]
      function performOperation(what) {
          var service = serviceForSource("PowerDevil")
          var operation = service.operationDescription(what)
          service.startOperationCall(operation)
      }
  }

  function updateStartpage(){
    appList.currentStateIndex = plasmoid.configuration.defaultPage
  }

  function reload() {
    searchBar.clear()
    searchBar.focus = true
    appList.reset()
  }
  function reset(){
    searchBar.clear()
    searchBar.focus = true
    appList.reset()
  }

  Rectangle {
    id: backdrop
    x: 0
    y: isTop ? 0 : 200 * PlasmaCore.Units.devicePixelRatio
    width: main.width
    height: isTop ? main.height - 200 * PlasmaCore.Units.devicePixelRatio : main.height - y
    color: plasmoid.configuration.theming == 0 ? "#131314" : plasmoid.configuration.theming == 1 ? "#ECEDEE" : PlasmaCore.Theme.backgroundColor
    radius: 10
    Rectangle {
      id: topCorner
      visible: true
      anchors.top: backdrop.top
      color: backdrop.color
      width: backdrop.width
      height: 20
    }
    Rectangle {
      id: bottomCorner
      visible: !plasmoid.configuration.floating
      anchors.bottom: backdrop.bottom
      color: backdrop.color
      width: backdrop.width
      height: 20
    }
  }
  //Floating Avatar
  Item {
    id: avatarParent
    x: main.width / 2
    y: - root.margins.top
    FloatingAvatar { //Anyone looking for an unpredictable number generator?
      id: floatingAvatar
      //visualParent: root
      isTop: main.isTop
      avatarWidth: 125 * PlasmaCore.Units.devicePixelRatio
      visible: root.visible && !isTop ? true : root.visible && plasmoid.configuration.floating ? true : false
    }
  }
  //Power & Settings
  Item {
    Header {
      id: powerSettings
      x: main.width - width - iconSize / 2
      y: isTop ? main.height - 2 * height - iconSize / 2 : iconSize / 2
      iconSize: 20 * PlasmaCore.Units.devicePixelRatio
    }
  }
  //Greeting
  Item {
    id: greeting
    PlasmaComponents.Label {
      id: nameLabel
      x: main.width / 2 - width / 2 //This centeres the Text
      y: isTop ? main.height - height - 135 * PlasmaCore.Units.devicePixelRatio : 80 * PlasmaCore.Units.devicePixelRatio
      text: plasmoid.configuration.enableGreeting && plasmoid.configuration.customGreeting ? plasmoid.configuration.customGreeting : plasmoid.configuration.enableGreeting ? 'Hi, ' + kuser.fullName : i18n("%1@%2", kuser.loginName, kuser.host)
      color: textColor
      font.family: textFont
      font.pixelSize: 16 * PlasmaCore.Units.devicePixelRatio
    }
  }
  //Searchbar
  Item {
    Rectangle {
      x: 25 * PlasmaCore.Units.devicePixelRatio
      y: isTop ? main.height - height - (2 * powerSettings.height + powerSettings.iconSize / 2) - 10 * PlasmaCore.Units.devicePixelRatio : 125 * PlasmaCore.Units.devicePixelRatio
      width: main.width - 2 * x
      height: 45 * PlasmaCore.Units.devicePixelRatio
      radius: 6
      color: plasmoid.configuration.theming == 0 ? "#202124" : plasmoid.configuration.theming == 1 ? "#FFFFFF" : PlasmaCore.Theme.viewBackgroundColor
      Image {
        id: searchIcon
        x: 15 * PlasmaCore.Units.devicePixelRatio
        width: 15 * PlasmaCore.Units.devicePixelRatio
        height: width
        anchors.verticalCenter: parent.verticalCenter
        source: 'icons/feather/search.svg'
        ColorOverlay {
          visible: plasmoid.configuration.theming != 0
          anchors.fill: searchIcon
          source: searchIcon
          color: main.textColor
        }
      }
      Rectangle {
        x: 45 * PlasmaCore.Units.devicePixelRatio
        width: parent.width - 60 * PlasmaCore.Units.devicePixelRatio
        height: searchBar.height
        anchors.verticalCenter: parent.verticalCenter
        clip: true
        color: 'transparent'
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.IBeamCursor
            hoverEnabled: false
        }
        TextInput {
          id: searchBar
          width: parent.width
          anchors.verticalCenter: parent.verticalCenter
          focus: true
          color: textColor
          selectByMouse: true
          selectionColor: plasmoid.configuration.theming == 0 ? "#141414" : plasmoid.configuration.theming == 1 ? "#EBEBEB" : PlasmaCore.Theme.highlightedTextColor
          font.family: textFont
          font.pixelSize: 13 * PlasmaCore.Units.devicePixelRatio
          Text {
            anchors.fill: parent
            text: i18n("Search your computer")
            color: plasmoid.configuration.theming == 0 ? "#686B71" : plasmoid.configuration.theming == 1 ? "#798591" : PlasmaCore.Theme.disabledTextColor
            visible: !parent.text
          }
          onTextChanged: {
              runnerModel.query = text;
              newTextQuery(text)
          }
          function clear() {
              text = "";
          }
          function backspace() {
              if (searching) {
                  text = text.slice(0, -1);
              }
              focus = true;
          }
          function appendText(newText) {
              if (!root.visible) {
                  return;
              }
              focus = true;
              text = text + newText;
          }
          Keys.onPressed: {
            if (event.key == Qt.Key_Down) {
              event.accepted = true;
              runnerList.setFocus()
            } else if (event.key == Qt.Key_Tab || event.key == Qt.Key_Up) {
              event.accepted = true;
              runnerList.setFocus()
            } else if (event.key == Qt.Key_Escape) {
              event.accepted = true;
              if (searching) {
                clear()
              } else {
                root.toggle()
              }
            } else if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
              runnerList.setFocus()
              runnerList.triggerFirst()
            }
          }
        }
      }
    }
  }
  //List of Apps
  AppList {
    id: appList
    state: "visible"
    anchors.top: backdrop.top
    anchors.bottom: backdrop.bottom
    width: main.width - 30 * PlasmaCore.Units.devicePixelRatio
    height: main.height - y
    visible: opacity > 0
    states: [
    State {
      name: "visible"; when: (!searching)
      PropertyChanges { target: appList; opacity: 1.0 }
      PropertyChanges { target: appList; x: 25 * PlasmaCore.Units.devicePixelRatio }
    },
    State {
      name: "hidden"; when: (searching)
      PropertyChanges { target: appList; opacity: 0.0}
      PropertyChanges { target: appList; x: 5 * PlasmaCore.Units.devicePixelRatio}
    }]
    transitions: [
      Transition {
        to: "visible"
        PropertyAnimation {properties: 'opacity'; duration: 100; easing.type: Easing.OutQuart}
        PropertyAnimation {properties: 'x'; from: 5 * PlasmaCore.Units.devicePixelRatio; duration: 100; easing.type: Easing.OutQuart}
      },
      Transition {
        to: "hidden"
        PropertyAnimation {properties: 'opacity'; duration: 100; easing.type: Easing.OutQuart}
        PropertyAnimation {properties: 'x'; from: 25 * PlasmaCore.Units.devicePixelRatio; duration: 100; easing.type: Easing.OutQuart}
      }
    ]
  }
  RunnerList {
    id: runnerList
    model: runnerModel
    state: "hidden"
    visible: opacity > 0
    anchors.top: backdrop.top
    anchors.bottom: backdrop.bottom
    width: main.width - 30 * PlasmaCore.Units.devicePixelRatio
    height: backdrop.height
    states: [
    State {
      name: "visible"; when: (searching)
      PropertyChanges { target: runnerList; opacity: 1.0 }
      PropertyChanges { target: runnerList; x: 20  * PlasmaCore.Units.devicePixelRatio}
    },
    State {
      name: "hidden"; when: (!searching)
      PropertyChanges { target: runnerList; opacity: 0.0}
      PropertyChanges { target: runnerList; x: 40 * PlasmaCore.Units.devicePixelRatio}
    }]
    transitions: [
      Transition {
        to: "visible"
        PropertyAnimation {properties: 'opacity'; duration: 100; easing.type: Easing.OutQuart}
        PropertyAnimation {properties: 'x'; from: 80 * PlasmaCore.Units.devicePixelRatio; duration: 100; easing.type: Easing.OutQuart}
      },
      Transition {
        to: "hidden"
        PropertyAnimation {properties: 'opacity'; duration: 100; easing.type: Easing.OutQuart}
        PropertyAnimation {properties: 'x'; from: 20 * PlasmaCore.Units.devicePixelRatio; duration: 100; easing.type: Easing.OutQuart}
      }
    ]
  }
  //Shadows
  Rectangle {
    id: topShadow
    z: parent.z + 1
    width: main.width
    height: 40 * PlasmaCore.Units.devicePixelRatio
    anchors.top: backdrop.top
    radius: isTop ? backdrop.radius : 0
    gradient: Gradient {
      GradientStop { position: 0.0; color: Qt.darker(backdrop.color, 1.5) }
      GradientStop { position: 1.0; color: "transparent" }
    }
    states: [
    State {
      name: "visible"; when: (!searching ? appList.get_position() > 0.0 : runnerList.get_position() > 0.0 )
      PropertyChanges { target: topShadow; opacity: 1.0 }
    },
    State {
      name: "hidden"; when: (!searching ? appList.get_position() <= 0.0 : runnerList.get_position() <= 0.0)
      PropertyChanges { target: topShadow; opacity: 0.0 }
    }]
    transitions: [
      Transition {
        NumberAnimation { properties: 'opacity'; duration: 40}
      }
    ]
  }
  Rectangle {
    id: bottomShadow
    z: parent.z + 1
    width: main.width
    height: 40 * PlasmaCore.Units.devicePixelRatio
    anchors.bottom: backdrop.bottom
    radius: !bottomCorner.visible ? backdrop.radius : 0
    gradient: Gradient {
      GradientStop { position: 0.0; color: "transparent" }
      GradientStop { position: 1.0; color: Qt.darker(backdrop.color, 1.5)}
    }
    states: [
    State {
      name: "visible"; when: (!searching ? appList.get_position() <= (0.99999 - appList.get_size()) : runnerList.get_position() <= (runnerList.get_size()))
      PropertyChanges { target: bottomShadow; opacity: 1.0 }
    },
    State {
      name: "hidden"; when: (!searching ? appList.get_position() > (0.99999 - appList.get_size()) : runnerList.get_position() > (runnerList.get_size()))
      PropertyChanges { target: bottomShadow; opacity: 0.0 }
    }]
    transitions: [
      Transition {
        NumberAnimation { properties: 'opacity'; duration: 40}
      }
    ]
  }
  Keys.onPressed: {
    if (event.key == Qt.Key_Backspace) {
        event.accepted = true;
        if (searching)
            searchBar.backspace();
        else
            searchBar.focus = true
    } else if (event.key == Qt.Key_Escape) {
        event.accepted = true;
        if (searching) {
            searchBar.clear()
        } else {
            root.toggle()
        }
    } else if (event.text != "" || event.key == Qt.Key_Down) {
        if (event.key != Qt.Key_Return){
          event.accepted = true;
          searchBar.appendText(event.text);
        }
    }
  }
}
