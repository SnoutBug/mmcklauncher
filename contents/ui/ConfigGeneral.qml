/*****************************************************************************
 *   Copyright (C) 2013-2014 by Eike Hein <hein@kde.org>                     *
 *   Copyright (C) 2021 by Prateek SU <pankajsunal123@gmail.com>             *
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
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.0

import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.draganddrop 2.0 as DragDrop
import org.kde.kirigami 2.3 as Kirigami

import org.kde.plasma.private.kicker 0.1 as Kicker

Kirigami.FormLayout {
    id: configGeneral

    anchors.left: parent.left
    anchors.right: parent.right

    property bool isDash: (plasmoid.pluginName === "org.kde.plasma.kickerdash")

    property string cfg_icon: plasmoid.configuration.icon
    property bool cfg_useCustomButtonImage: plasmoid.configuration.useCustomButtonImage
    property string cfg_customButtonImage: plasmoid.configuration.customButtonImage
    property bool cfg_activationIndicator: plasmoid.configuration.activationIndicator
    property color cfg_indicatorColor: plasmoid.configuration.indicatorColor
    property bool cfg_enableGreeting: plasmoid.configuration.indicatorColor
    property alias cfg_defaultPage: defaultPage.currentIndex
    property alias cfg_theming: theming.currentIndex
    property alias cfg_useExtraRunners: useExtraRunners.checked
    property alias cfg_customGreeting: customGreeting.text
    property alias cfg_floating: floating.checked
    property alias cfg_launcherPosition: launcherPosition.currentIndex
    property alias cfg_offsetX: screenOffset.value
    property alias cfg_offsetY: panelOffset.value

    Button {
        id: iconButton

        Kirigami.FormData.label: i18n("Icon:")

        implicitWidth: previewFrame.width + units.smallSpacing * 2
        implicitHeight: previewFrame.height + units.smallSpacing * 2

        // Just to provide some visual feedback when dragging;
        // cannot have checked without checkable enabled
        checkable: true
        checked: dropArea.containsAcceptableDrag

        onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

        DragDrop.DropArea {
            id: dropArea

            property bool containsAcceptableDrag: false

            anchors.fill: parent

            onDragEnter: {
                // Cannot use string operations (e.g. indexOf()) on "url" basic type.
                var urlString = event.mimeData.url.toString();

                // This list is also hardcoded in KIconDialog.
                var extensions = [".png", ".xpm", ".svg", ".svgz"];
                containsAcceptableDrag = urlString.indexOf("file:///") === 0 && extensions.some(function (extension) {
                    return urlString.indexOf(extension) === urlString.length - extension.length; // "endsWith"
                });

                if (!containsAcceptableDrag) {
                    event.ignore();
                }
            }
            onDragLeave: containsAcceptableDrag = false

            onDrop: {
                if (containsAcceptableDrag) {
                    // Strip file:// prefix, we already verified in onDragEnter that we have only local URLs.
                    iconDialog.setCustomButtonImage(event.mimeData.url.toString().substr("file://".length));
                }
                containsAcceptableDrag = false;
            }
        }

        KQuickAddons.IconDialog {
            id: iconDialog

            function setCustomButtonImage(image) {
                cfg_customButtonImage = image || cfg_icon || "start-here-kde"
                cfg_useCustomButtonImage = true;
            }

            onIconNameChanged: setCustomButtonImage(iconName);
        }

        PlasmaCore.FrameSvgItem {
            id: previewFrame
            anchors.centerIn: parent
            imagePath: plasmoid.location === PlasmaCore.Types.Vertical || plasmoid.location === PlasmaCore.Types.Horizontal
                ? "widgets/panel-background" : "widgets/background"
            width: units.iconSizes.large + fixedMargins.left + fixedMargins.right
            height: units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

            PlasmaCore.IconItem {
                anchors.centerIn: parent
                width: units.iconSizes.large
                height: width
                source: cfg_useCustomButtonImage ? cfg_customButtonImage : cfg_icon
            }
        }

        Menu {
            id: iconMenu

            // Appear below the button
            y: +parent.height

            onClosed: iconButton.checked = false;

            MenuItem {
                text: i18nc("@item:inmenu Open icon chooser dialog", "Choose...")
                icon.name: "document-open-folder"
                onClicked: iconDialog.open()
            }
            MenuItem {
                text: i18nc("@item:inmenu Reset icon to default", "Clear Icon")
                icon.name: "edit-clear"
                onClicked: {
                    cfg_icon = "start-here-kde"
                    cfg_useCustomButtonImage = false
                }
            }
        }
    }
    CheckBox {
      id: activationIndicatorCheck
      Kirigami.FormData.label: i18n("Indicator:")
      text: i18n("Enabled")
      checked: plasmoid.configuration.activationIndicator
      onCheckedChanged: {
        plasmoid.configuration.activationIndicator = checked
        cfg_activationIndicator = checked
      }
    }
    Button {
        id: colorButton
        width: units.iconSizes.small
        height: width
        Kirigami.FormData.label: i18n("Indicator Color:")

        Rectangle {
          anchors.centerIn: parent
          anchors.fill: parent
          radius: 10
          color: cfg_indicatorColor
        }
        onPressed: colorDialog.visible ? colorDialog.close() : colorDialog.open()
        ColorDialog {
        id: colorDialog
        title: i18n("Please choose a color")
        onAccepted: {
            cfg_indicatorColor = colorDialog.color
        }
      }
    }
    Item {
        Kirigami.FormData.isSection: true
    }
    CheckBox {
      id: enableGreetingCheck
      Kirigami.FormData.label: i18n("Greeting:")
      text: i18n("Enabled")
      checked: plasmoid.configuration.enableGreeting
      onCheckedChanged: {
        plasmoid.configuration.enableGreeting = checked
        cfg_enableGreeting = checked
        customGreeting.enabled = checked
      }
    }
    TextField {
      id: customGreeting
      Kirigami.FormData.label: i18n("Custom Greeting Text:")
      placeholderText: i18n("No custom greeting set")
    }
    Item {
        Kirigami.FormData.isSection: true
    }
    ComboBox {
        id: launcherPosition
        Kirigami.FormData.label: i18n("Launcher Positioning:")
        model: [
        i18n("Default"),
        i18n("Horizontal Center"),
        i18n("Screen Center"),
        ]
        onCurrentIndexChanged: {
          if (currentIndex == 2) {
            floating.enabled = false
            floating.checked = true
          } else {
            floating.enabled = true
          }
        }
    }
    CheckBox {
      id: floating
      text: i18n("Floating")
      onCheckedChanged: {
        screenOffset.visible = checked
        panelOffset.visible = checked
      }
    }
    Slider {
      id: screenOffset
      visible: plasmoid.configuration.floating
      Kirigami.FormData.label: i18n("Offset Screen Edge (0 is Default):")
      from: 0
      value: 0
      to: 100
      stepSize: 1
      PlasmaComponents.ToolTip {
          text: screenOffset.value
      }
    }
    Slider {
      id: panelOffset
      visible: plasmoid.configuration.floating
      Kirigami.FormData.label: i18n("Offset Panel (0 is Default):")
      from: 0
      value: 0
      to: 100
      stepSize: 1
      PlasmaComponents.ToolTip {
          text: panelOffset.value
      }
    }
    Item {
        Kirigami.FormData.isSection: true
    }
    ComboBox {
        id: defaultPage
        Kirigami.FormData.label: i18n("Default Page:")
        model: [
        i18n("All Applications (Default)"),
        i18n("Developement"),
        i18n("Games"),
        i18n("Graphics"),
        i18n("Internet"),
        i18n("Multimedia"),
        i18n("Office"),
        i18n("Science & Math"),
        i18n("Settings"),
        i18n("System"),
        i18n("Utilities"),
        i18n("Lost & Found"),
        ]
    }
    Item {
        Kirigami.FormData.isSection: true
    }
    CheckBox {
        id: useExtraRunners
        Kirigami.FormData.label: i18n("Search:")
        text: i18n("Expand search to bookmarks, files and emails")
    }
    Item {
        Kirigami.FormData.isSection: true
    }
    ComboBox {
        id: theming
        Kirigami.FormData.label: i18n("Theming:")
        model: [
        i18n("Dark (Default)"),
        i18n("Light"),
        i18n("Matching"),
        ]
    }
}
