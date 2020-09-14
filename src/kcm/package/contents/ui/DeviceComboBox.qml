/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>
    SPDX-FileCopyrightText: 2016 David Rosca <nowrep@gmail.com>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick 2.0
import QtQuick.Controls 2.0

ComboBox {
    onModelChanged: updateIndex()
    onCountChanged: updateIndex()

    onActivated: {
        if (index === -1) {
            return;
        }

        DeviceIndex = modelIndexToDeviceIndex(index);
    }

    function updateIndex() {
        currentIndex = deviceIndexToModelIndex(DeviceIndex);
    }

    function deviceIndexToModelIndex(deviceIndex) {
        textRole = 'Index';
        var searchString = '';
        if (deviceIndex !== 0) {
            searchString = '' + deviceIndex;
        }
        var modelIndex = find(searchString);
        textRole = 'Description';
        return modelIndex;
    }

    function modelIndexToDeviceIndex(modelIndex) {
        textRole = 'Index';
        var deviceIndex = Number(textAt(modelIndex));
        textRole = 'Description';
        return deviceIndex;
    }

    Connections {
        target: PulseObject
        onDeviceIndexChanged: updateIndex();
    }

    Component.onCompleted: updateIndex();
}
