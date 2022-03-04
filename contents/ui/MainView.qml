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
import QtQuick.Window 2.2
import QtGraphicalEffects 1.12
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kcoreaddons 1.0 as KCoreAddons
import org.kde.kirigami 2.13 as Kirigami
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.plasma.plasmoid 2.0

Item {
  id: main
  anchors.fill: parent

  property bool searching: (searchBar.text != "")
  signal newTextQuery(string text)
  readonly property color textColor: plasmoid.configuration.theming == 0 ? "#FFFFFF" : plasmoid.configuration.theming == 1 ? "#000000" : PlasmaCore.Theme.textColor
  readonly property string textFont: plasmoid.configuration.theming == 2 ? PlasmaCore.Theme.defaultFont : "SF Pro Text"

  // Component.onCompleted: {
  //   if (PlasmaCore.Theme.defaultFontChanged) {
  //     console.log(PlasmaCore.Theme.defaultFont);
  //   } else {
  //     console.log(PlasmaCore.Theme.defaultFont);
  //   }
  // }

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

  function reload() {
    searchBar.clear()
    searchBar.focus = true
    appList.reset()
  }

  function reset() {
    searchBar.clear()
    searchBar.focus = true
    appList.reset()
  }

  // Background for Avatar
  Rectangle {
    id: avatarBg
    x: 0
    y: 0
    width: main.width
    height: width / 10
    color: "#00FFFFFF"
  }

  Rectangle {
    id: backdrop
    x: 0
    y: main.height * 0.28 + avatarBg.height
    width: main.width
    height: main.height - y
    color: plasmoid.configuration.theming == 0 ? "#131314" : plasmoid.configuration.theming == 1 ? "#ECEDEE" : PlasmaCore.Theme.backgroundColor
  }
  //Floating Avatar
  Item {
    id: avatarParent
    anchors.bottom: avatarBg.bottom
    x: main.width / 2
    // y: main.height * 0.35 
    Item {
      id: avatarFrame
      anchors.centerIn: parent
      width: main.width / 5
      height: width
      Kirigami.Avatar {
        source: kuser.faceIconUrl
        anchors {
          fill: parent
          margins: PlasmaCore.Units.smallSpacing
        }
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          hoverEnabled: false
          onClicked: {
            KQuickAddons.KCMShell.openSystemSettings("kcm_users")
            root.toggle()
          }
        }
      }
    }
  }
  //Power & Settings
  Item {
    Header {
      x: (main.width - width - iconSize)
      y: backdrop.y * 0.25
      iconSize: PlasmaCore.Units.iconSizes.small
    }
  }
  //Greeting
  Item {
    id: greeting
    PlasmaExtras.Heading {
      id: nameLabel
      x: (main.width - width) / 2 //This centeres the Text
      y: backdrop.y * 0.5
      level: 2
      text: plasmoid.configuration.enableGreeting && plasmoid.configuration.customGreeting ? plasmoid.configuration.customGreeting : plasmoid.configuration.enableGreeting ? 'Hi, ' + kuser.fullName : i18n("%1@%2", kuser.loginName, kuser.host)
      color: textColor
      font.family: textFont //This is the font that was used in the original design by Max McKinney
    }
  }
  //Searchbar
  Item {
    Rectangle {
      id: seachBarBackground
      x: (main.width - width) / 2
      y: backdrop.y * 0.7
      width: main.width - PlasmaCore.Units.smallSpacing * 6
      height: PlasmaCore.Units.iconSizes.medium
      radius: main.width * 0.1
      color: plasmoid.configuration.theming == 0 ? "#202124" : plasmoid.configuration.theming == 1 ? "#FFFFFF" : PlasmaCore.Theme.viewBackgroundColor
      Image {
        id: searchIcon
        x: width
        width: PlasmaCore.Units.iconSizes.small
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
        x: PlasmaCore.Units.smallSpacing * 6 + searchIcon.width
        width: seachBarBackground.width
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
          width: seachBarBackground.width
          anchors.verticalCenter: parent.verticalCenter
          focus: true
          color: textColor
          selectByMouse: true
          selectionColor: plasmoid.configuration.theming == 0 ? "#141414" : plasmoid.configuration.theming == 1 ? "#EBEBEB" : PlasmaCore.Theme.highlightedTextColor
          font.family: textFont
          Text {
            anchors.fill: parent
            text: 'Search your computer'
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
    width: main.width
    height: main.height - y
    visible: opacity > 0
    states: [
      State {
        name: "visible";when: (!searching)
        PropertyChanges {
          target: appList;opacity: 1.0
        }
        PropertyChanges {
          target: appList;x: 25
        }
      },
      State {
        name: "hidden";when: (searching)
        PropertyChanges {
          target: appList;opacity: 0.0
        }
        PropertyChanges {
          target: appList;x: 5
        }
      }
    ]
    transitions: [
      Transition {
        to: "visible"
        NumberAnimation {
          properties: 'opacity';duration: 40;
        }
        NumberAnimation {
          properties: 'x';from: 5;duration: 40;
        }
      },
      Transition {
        to: "hidden"
        NumberAnimation {
          properties: 'opacity';duration: 40;
        }
        NumberAnimation {
          properties: 'x';from: 25;duration: 40;
        }
      }
    ]
  }
  RunnerList {
    id: runnerList
    model: runnerModel
    state: "hidden"
    visible: opacity > 0 //searching
    anchors.top: backdrop.top
    width: main.width
    height: backdrop.height
    states: [
      State {
        name: "visible";when: (searching)
        PropertyChanges {
          target: runnerList;opacity: 1.0
        }
        PropertyChanges {
          target: runnerList;x: 20
        }
      },
      State {
        name: "hidden";when: (!searching)
        PropertyChanges {
          target: runnerList;opacity: 0.0
        }
        PropertyChanges {
          target: runnerList;x: 40
        }
      }
    ]
    transitions: [
      Transition {
        to: "visible"
        NumberAnimation {
          properties: 'opacity';duration: 40;
        }
        NumberAnimation {
          properties: 'x';from: 40;duration: 40;
        }
      },
      Transition {
        to: "hidden"
        NumberAnimation {
          properties: 'opacity';duration: 40;
        }
        NumberAnimation {
          properties: 'x';from: 40;duration: 40;
        }
      }
    ]
  }
  //Shadows
  Rectangle {
    id: topShadow
    z: parent.z + 1
    width: main.width
    height: main.height * 0.2
    anchors.top: backdrop.top
    gradient: Gradient {
      GradientStop {
        position: 0.0;color: Qt.darker(backdrop.color, 1.5)
      }
      GradientStop {
        position: 1.0;color: "transparent"
      } //"#0d0d0d"
    }
    states: [
      State {
        name: "visible";when: (!searching ? appList.get_position() > 0.0 : runnerList.get_position() > 0.0)
        PropertyChanges {
          target: topShadow;opacity: 1.0
        }
      },
      State {
        name: "hidden";when: (!searching ? appList.get_position() <= 0.0 : runnerList.get_position() <= 0.0)
        PropertyChanges {
          target: topShadow;opacity: 0.0
        }
      }
    ]
    transitions: [
      Transition {
        NumberAnimation {
          properties: 'opacity';duration: 40
        }
      }
    ]
  }
  Rectangle {
    id: bottomShadow
    z: parent.z + 1
    width: main.width
    height: main.height * 0.2
    anchors.bottom: backdrop.bottom
    gradient: Gradient {
      GradientStop {
        position: 0.0;color: "transparent"
      }
      GradientStop {
        position: 1.0;color: Qt.darker(backdrop.color, 1.5)
      }
    }
    states: [
      State {
        name: "visible";when: (!searching ? appList.get_position() <= (0.99999 - appList.get_size()) : runnerList.get_position() <= (runnerList.get_size()))
        PropertyChanges {
          target: bottomShadow;opacity: 1.0
        }
      },
      State {
        name: "hidden";when: (!searching ? appList.get_position() > (0.99999 - appList.get_size()) : runnerList.get_position() > (runnerList.get_size()))
        PropertyChanges {
          target: bottomShadow;opacity: 0.0
        }
      }
    ]
    transitions: [
      Transition {
        NumberAnimation {
          properties: 'opacity';duration: 40
        }
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
      if (event.key != Qt.Key_Return) {
        event.accepted = true;
        searchBar.appendText(event.text);
      }
    }
  }
}