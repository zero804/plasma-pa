/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0

ColumnLayout {
    property alias text: heading.text
    property alias disabledText: disabledLabel.text

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: units.gridUnit * 1.5
        Layout.topMargin: units.smallSpacing

        Label {
            id: heading
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            font.weight: Font.DemiBold
        }
    }

    Label {
        id: disabledLabel
        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        visible: text && !parent.enabled
        font.italic: true
    }
}
