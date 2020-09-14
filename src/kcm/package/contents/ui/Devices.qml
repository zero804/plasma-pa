/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
    SPDX-FileCopyrightText: 2019 Sefa Eyeoglu <contact@scrumplex.net>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3

import org.kde.kirigami 2.5 as Kirigami

import org.kde.plasma.private.volume 0.1

ScrollView {
    id: scrollView

    contentHeight: contentItem.height
    clip: true

    PulseObjectFilterModel {
        id: paSinkFilterModel

        sortRole: "SortByDefault"
        sortOrder: Qt.DescendingOrder
        filterOutInactiveDevices: true
        sourceModel: paSinkModel
    }

    PulseObjectFilterModel {
        id: paSourceFilterModel

        sortRole: "SortByDefault"
        sortOrder: Qt.DescendingOrder
        filterOutInactiveDevices: true
        sourceModel: paSourceModel
    }

    Item {
    id: contentItem
    width: scrollView.availableWidth
    height: contentLayout.implicitHeight

        ColumnLayout {
            id: contentLayout
            width: scrollView.availableWidth

            Header {
                Layout.fillWidth: true
                enabled: sinks.count > 0
                text: i18nd("kcm_pulseaudio", "Playback Devices")
                disabledText: i18ndc("kcm_pulseaudio", "@label", "No Playback Devices Available")
            }

            ListView {
                id: sinks
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                Layout.margins: Kirigami.Units.gridUnit / 2
                interactive: false
                spacing: Kirigami.Units.gridUnit
                model: inactiveDevicesButton.checked || !inactiveDevicesButton.visible ? paSinkModel : paSinkFilterModel
                delegate: DeviceListItem {
                    isPlayback: true
                }
            }

            Header {
                Layout.fillWidth: true
                enabled: sources.count > 0
                text: i18nd("kcm_pulseaudio", "Recording Devices")
                disabledText: i18ndc("kcm_pulseaudio", "@label", "No Recording Devices Available")
            }

            ListView {
                id: sources
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                Layout.margins: Kirigami.Units.gridUnit / 2
                interactive: false
                spacing: Kirigami.Units.gridUnit
                model: inactiveDevicesButton.checked || !inactiveDevicesButton.visible ? paSourceModel : paSourceFilterModel
                delegate: DeviceListItem {
                    isPlayback: false
                }
            }

            Button {
                id: inactiveDevicesButton

                Layout.alignment: Qt.AlignHCenter
                Layout.margins: Kirigami.Units.gridUnit

                checkable: true

                text: i18nd("kcm_pulseaudio", "Show Inactive Devices")
                icon.name: "view-visible"

                // Only show if there actually are any inactive devices
                visible: (paSourceModel.count != paSourceFilterModel.count) || (paSinkModel.count != paSinkFilterModel.count)
            }
        }
    }
}
