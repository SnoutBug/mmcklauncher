/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
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
import QtQuick.Controls 2.5

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

    property alias cfg_appNameFormat: appNameFormat.currentIndex

    property alias cfg_menuPosition: menuPosition.currentIndex
    property alias cfg_favGridModel: favGridModel.currentIndex
    property alias cfg_recentGridModel: recentGridModel.currentIndex

    property alias cfg_useExtraRunners: useExtraRunners.checked
    property alias cfg_reduceIconSizeFooter: reduceIconSizeFooter.checked
    property alias cfg_reduceIconSizeUserProfile: reduceIconSizeUserProfile.checked
    property alias cfg_reducePinnedSize: reducePinnedSize.checked
    property alias cfg_gridAllowTwoLines: gridAllowTwoLines.checked
    property alias cfg_defaultAllApps: defaultAllApps.checked
    property alias cfg_showDescription: showDescription.checked
    property alias cfg_alwaysShowSearchBar: alwaysShowSearchBar.checked
    property alias cfg_preferFullName: preferFullName.checked
    property alias cfg_replaceExplorerIcon: replaceExplorerIcon.checked

    property alias cfg_numberColumns: numberColumns.value
    property alias cfg_numberRows: numberRows.value

    property alias cfg_downIconsDocuments: downIconsDocuments.checked
    property alias cfg_downIconsDownloads: downIconsDownloads.checked
    property alias cfg_downIconsPictures: downIconsPictures.checked
    property alias cfg_downIconsMusic: downIconsMusic.checked
    property alias cfg_downIconsVideos: downIconsVideos.checked
    property alias cfg_downIconsFileManager: downIconsFileManager.checked
    property alias cfg_downIconsSystemSettings: downIconsSystemSettings.checked
    property alias cfg_downIconsLock: downIconsLock.checked
    property alias cfg_downIconsPowerOptions: downIconsPowerOptions.checked

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


    Item {
        Kirigami.FormData.isSection: true
    }

    ComboBox {
        id: menuPosition

        Kirigami.FormData.label: i18n("Menu Position:")

        model: [i18n("Center"), i18n("On Edge"), i18n("Auto")]
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    ComboBox {
        id: favGridModel

        Kirigami.FormData.label: i18n("Pinned item:")

        model: [i18n("Favourite apps"), i18n("Recent apps"), i18n("Recent documents")]
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    ComboBox {
        id: recentGridModel

        Kirigami.FormData.label: i18n("Recommended item:")

        model: [i18n("Recent documents"), i18n("Recent apps"), i18n("Favourite apps"), i18n("None")]
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    SpinBox{
        id: numberColumns

        Kirigami.FormData.label: i18n("Number of columns in grid:")

        from: 4
        to: 10
    }

    SpinBox{
        id: numberRows

        Kirigami.FormData.label: i18n("Number of rows in grid:")

        from: 1
        to: 10
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    CheckBox {
        id: defaultAllApps
        Kirigami.FormData.label: i18n("Panel Properties:")
        text: i18n("Show All apps by default")
    }

    CheckBox {
        id: gridAllowTwoLines
        text: i18n("Allow label to have two lines (Pinned)")
    }

    CheckBox {
        id: showDescription
        text: i18n("Show Description for all apps and search item")
    }

    CheckBox {
        id: alwaysShowSearchBar
        text: i18n("Always Show Search Bar")
    }

    CheckBox {
        id: preferFullName
        text: i18n("Prefer showing full name, instead of login name")
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    CheckBox {
        id: replaceExplorerIcon
        Kirigami.FormData.label: i18n("Icon Properties:")
        text: i18n("Replace Explorer icon in footer")
    }

    CheckBox {
        id: reduceIconSizeUserProfile
        text: i18n("Reduce Icon Size for User Profile")
    }

    CheckBox {
        id: reduceIconSizeFooter
        text: i18n("Reduce Icon Size for Footer")
    }

    CheckBox {
        id: reducePinnedSize
        text: i18n("Reduce Icon Size for Pinned item")
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    ComboBox {
        id: appNameFormat

        Kirigami.FormData.label: i18n("Show applications as:")

        model: [i18n("Name only"), i18n("Description only"), i18n("Name (Description)"), i18n("Description (Name)")]
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    CheckBox {
        id: downIconsDocuments
        Kirigami.FormData.label: i18n("Icons on Bottom bar:")
        text: i18n("Documents")
    }

    CheckBox {
        id: downIconsPictures
        text: i18n("Pictures")
    }

    CheckBox {
        id: downIconsMusic
        text: i18n("Music")
    }

    CheckBox {
        id: downIconsDownloads
        text: i18n("Downloads")
    }

    CheckBox {
        id: downIconsVideos
        text: i18n("Videos")
    }

    CheckBox {
        id: downIconsFileManager
        text: i18n("File manager")
    }

    CheckBox {
        id: downIconsSystemSettings
        text: i18n("System settings")
    }

    CheckBox {
        id: downIconsLock
        text: i18n("Lock screen")
    }

    CheckBox {
        id: downIconsPowerOptions
        text: i18n("Power options")
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    CheckBox {
        id: useExtraRunners

        Kirigami.FormData.label: i18n("Search:")

        text: i18n("Expand search to bookmarks, files and emails")
    }
}
