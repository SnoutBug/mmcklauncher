import QtQuick 2.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

import QtQuick.Window 2.2
//import org.kde.plasma.components 3.0 as PlasmaComponents
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.draganddrop 2.0
import org.kde.plasma.private.kicker 0.1 as Kicker

ScrollView {
  id: runnerList
  property alias model: repeater.model

  property int activeIndex: 0

  property var runnerModelTemp

  property var activeItem: null

  function subGridAt(index) {
    return repeater2.itemAt(index).itemGrid;
  }

  function get_position(){
    return ScrollBar.vertical.position;
  }
  function get_size(){
    return ScrollBar.vertical.size;
  }

  ListModel {
    id: results
  }

  Column {
    y: 25
    x: -10
    width: runnerList.width
    height: runnerList.height
    Repeater {
      id: repeater
      model: runnerModel
      delegate:
      Item {
        width: runnerList.width
        height: sectionImage.height + resultsList.height
        visible: resultsList.count > 0
        Image {
          id: sectionImage
          x: 20
          source: repeater.model.modelForRow(index).description === 'Command Line' ? "icons/feather/code.svg" : repeater.model.modelForRow(index).description == 'Desktop Search' ? "icons/feather/search.svg" : "icons/feather/file-text.svg"
          width: 15
          height: width
          PlasmaComponents.Label {
            id: sectionLabel
            x: sectionImage.width + 10
            anchors.verticalCenter: sectionImage.verticalCenter
            text: repeater.model.modelForRow(index).description
            font.family: "SF Pro Text"
            font.pixelSize: 12
          }
        }
        FocusScope {
          Component{
              id: genericItem
              GenericItem {
              }
          }
          PlasmaExtras.ScrollArea {
            signal keyNavLeft
            signal keyNavRight
            signal keyNavUp
            signal keyNavDown
            
            focus: true
            verticalScrollBarPolicy: Qt.ScrollBarAsNeeded
            GridView {
              id: resultsList
              cellWidth: main.width
              cellHeight: genericItem.height
              focus: true
              currentIndex: -1
              model: repeater.model.modelForRow(index)
              delegate: genericItem
              onModelChanged: {
                  currentIndex = -1;
              }
            }
          }
          Kicker.WheelInterceptor {
              anchors.fill: resultsList
              z: 1

              destination: findWheelArea(runnerList.flickableItem)
          }
        }
      }
    }
  }
  Item {
    width: 1
    height: 20
  }
}
/*
Image {
  id: sectionImage
  source: repeater.model.modelForRow(index).description === 'Command Line' ? "icons/feather/code.svg" : repeater.model.modelForRow(index).description == 'Desktop Search' ? "icons/feather/search.svg" : "icons/feather/file-text.svg"
  width: 15
  height: width
  PlasmaComponents.Label {
    id: sectionLabel
    x: sectionImage.width + 10
    anchors.verticalCenter: sectionImage.verticalCenter
    text: repeater.model.modelForRow(index).description
    font.family: "SF Pro Text"
    font.pixelSize: 12
  }
}
*/
