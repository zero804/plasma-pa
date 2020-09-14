/*
    SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

#pragma once

#include <QObject>
#include <QPersistentModelIndex>
#include <QPointer>
#include <QVector>

class QAction;
class QTimer;

class KStatusNotifierItem;

class VolumeOSD;

namespace QPulseAudio
{
class Source;
class SourceModel;
class SourceOutputModel;
}

class MicrophoneIndicator : public QObject
{
    Q_OBJECT

public:
    explicit MicrophoneIndicator(QObject *parent = nullptr);
    ~MicrophoneIndicator() override;

    Q_INVOKABLE void init();

Q_SIGNALS:
    void enabledChanged();

private:
    void scheduleUpdate();
    void update();

    bool muted() const;
    void setMuted(bool muted);
    void toggleMuted();

    void adjustVolume(int direction);

    static int volumePercent(QPulseAudio::Source *source);
    void showOsd();

    QStringList appNames() const;

    QPulseAudio::SourceModel *m_sourceModel = nullptr; // microphone devices
    QPulseAudio::SourceOutputModel *m_sourceOutputModel = nullptr; // recording streams

    KStatusNotifierItem *m_sni = nullptr;
    QPointer<QAction> m_muteAction;
    QPointer<QAction> m_dontAgainAction;

    QVector<QPersistentModelIndex> m_mutedIndices;

    VolumeOSD *m_osd = nullptr;
    bool m_showOsdOnUpdate = false;

    int m_wheelDelta = 0;

    QTimer *m_updateTimer;

};
