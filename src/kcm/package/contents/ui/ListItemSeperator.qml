/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.0
import QtQuick.Layouts 1.0

Rectangle {
    property ListView view

    Layout.fillWidth: true

    visible: (view.count != 0) && (view.count != (index + 1))
    color: systemPalette.mid
    height: Math.ceil(units.gridUnit / 20)

    SystemPalette {
        id: systemPalette
    }
}
