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
    //runnerList.reset()
  }
  function reset(){
    searchBar.clear()
    searchBar.focus = true
    appList.reset()
    //runnerList.reset()
  }

  Rectangle {
    id: backdrop
    x: 0
    y: 200 //175
    width: main.width
    height: main.height - y
    color: '#131314'
  }
  //Floating Avatar
  Item {
    id: avatarParent
    x: main.width / 2
    y: - root.margins.top
    FloatingAvatar { //i hate this
      id: floatingAvatar
      //visualParent: avatarParent
      avatarWidth: 125 //100
      visible: root.visible
    }
  }
  //Power & Settings
  Item {
    Header{
      x: main.width - width - iconSize / 2
      y: iconSize / 2
      iconSize: 20//15
    }
  }
  //Greeting
  Item {
    id: greeting
    PlasmaComponents.Label {
      id: nameLabel
      x: main.width / 2 - width / 2 //This centeres the Text
      y: 80//60
      text: plasmoid.configuration.enableGreeting ? 'Hi, ' + kuser.fullName : i18n("%1@%2", kuser.loginName, kuser.host)

      font.family: 'SF Pro Text' //This is the font that was used in the original design by Max McKinney
      font.pixelSize: 16
    }
  }
  //Searchbar
  Item {
    Rectangle {
      x: 25//20
      y: 125//100
      width: main.width - 2 * x
      height: 45//40
      radius: 6
      color: '#202124'
      Image {
        id: searchIcon
        x: 15
        width: 15
        height: width
        anchors.verticalCenter: parent.verticalCenter
        source: 'icons/feather/search.svg'
      }
      Rectangle {
        x: 45
        width: parent.width - 60
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
          color: 'white'
          selectByMouse: true
          selectionColor: '#141414'
          font.family: 'SF Pro Text'
          font.pixelSize: 13
          Text {
            anchors.fill: parent
            text: 'Search your computer'
            color: '#686B71'
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
    //x: 25
    state: "visible"
    anchors.top: backdrop.top
    width: main.width - 30
    height: main.height - y
    visible: opacity > 0
    states: [
    State {
      name: "visible"; when: (!searching)
      PropertyChanges { target: appList; opacity: 1.0 }
      PropertyChanges { target: appList; x: 25 }
    },
    State {
      name: "hidden"; when: (searching)
      PropertyChanges { target: appList; opacity: 0.0}
      PropertyChanges { target: appList; x: 5}
    }]
    transitions: [
      Transition {
        to: "visible"
        NumberAnimation {properties: 'opacity'; duration: 40;}
        NumberAnimation {properties: 'x'; from: 5; duration: 40;}
      },
      Transition {
        to: "hidden"
        NumberAnimation {properties: 'opacity'; duration: 40;}
        NumberAnimation {properties: 'x'; from: 25; duration: 40;}
      }
    ]
  }
  RunnerList {
    id: runnerList
    model: runnerModel
    //x: 20
    state: "hidden"
    visible: opacity > 0//searching
    anchors.top: backdrop.top
    width: main.width - 30
    height: backdrop.height
    states: [
    State {
      name: "visible"; when: (searching)
      PropertyChanges { target: runnerList; opacity: 1.0 }
      PropertyChanges { target: runnerList; x: 20 }
    },
    State {
      name: "hidden"; when: (!searching)
      PropertyChanges { target: runnerList; opacity: 0.0}
      PropertyChanges { target: runnerList; x: 40}
    }]
    transitions: [
      Transition {
        to: "visible"
        NumberAnimation {properties: 'opacity'; duration: 40;}
        NumberAnimation {properties: 'x'; from: 40; duration: 40;}
      },
      Transition {
        to: "hidden"
        NumberAnimation {properties: 'opacity'; duration: 40;}
        NumberAnimation {properties: 'x'; from: 40; duration: 40;}
      }
    ]
  }
  //Shadows
  Rectangle {
    id: topShadow
    z: parent.z + 1
    width: main.width
    height: 40//20
    anchors.top: backdrop.top
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#0d0d0d" }
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
    height: 40//20
    anchors.bottom: backdrop.bottom
    gradient: Gradient {
      GradientStop { position: 0.0; color: "transparent" }
      GradientStop { position: 1.0; color: "#0d0d0d"}
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
