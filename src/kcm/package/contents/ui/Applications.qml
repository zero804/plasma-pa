/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
    SPDX-FileCopyrightText: 2016 David Rosca <nowrep@gmail.com>
    SPDX-FileCopyrightText: 2019 Sefa Eyeoglu <contact@scrumplex.net>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2

import org.kde.plasma.private.volume 0.1

ScrollView {
    id: scrollView

    contentHeight: contentItem.height
    clip: true

    Item {
        id: contentItem
        width: scrollView.availableWidth
        height: contentLayout.implicitHeight

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent

            Header {
                Layout.fillWidth: true
                enabled: eventStreamView.count || sinkInputView.count
                text: i18nd("kcm_pulseaudio", "Playback Streams")
                disabledText: i18ndc("kcm_pulseaudio", "@label", "No Applications Playing Audio")
            }

            ListView {
                id: eventStreamView
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                Layout.margins: units.gridUnit / 2
                interactive: false
                spacing: units.largeSpacing
                model: PulseObjectFilterModel {
                    filters: [ { role: "Name", value: "sink-input-by-media-role:event" } ]
                    sourceModel: StreamRestoreModel {}
                }
                delegate: StreamListItem {
                    deviceModel: paSinkModel
                    isPlayback: true
                }
            }

            ListView {
                id: sinkInputView
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                Layout.margins: units.gridUnit / 2
                interactive: false
                spacing: units.largeSpacing
                model: PulseObjectFilterModel {
                    filters: [ { role: "VirtualStream", value: false } ]
                    sourceModel: SinkInputModel {}
                }
                delegate: StreamListItem {
                    deviceModel: paSinkModel
                    isPlayback: true
                }
            }

            Header {
                Layout.fillWidth: true
                enabled: sourceOutputView.count > 0
                text: i18nd("kcm_pulseaudio", "Recording Streams")
                disabledText: i18ndc("kcm_pulseaudio", "@label", "No Applications Recording Audio")
            }

            ListView {
                id: sourceOutputView
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                Layout.margins: units.gridUnit / 2
                interactive: false
                spacing: units.largeSpacing
                model: PulseObjectFilterModel {
                    filters: [ { role: "VirtualStream", value: false } ]
                    sourceModel: SourceOutputModel {}
                }

                delegate: StreamListItem {
                    deviceModel: sourceModel
                    isPlayback: false
                }
            }
        }
    }
}
