/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

#include "card.h"

#include "debug.h"

#include "context.h"

namespace QPulseAudio
{

Card::Card(QObject *parent)
    : PulseObject(parent)
{
}

void Card::update(const pa_card_info *info)
{
    updatePulseObject(info);

    QString infoName = QString::fromUtf8(info->name);
    if (m_name != infoName) {
        m_name = infoName;
        Q_EMIT nameChanged();
    }

    qDeleteAll(m_profiles);
    m_profiles.clear();
    for (auto **it = info->profiles2; it && *it != nullptr; ++it) {
        Profile *profile = new Profile(this);
        profile->setInfo(*it);
        m_profiles.append(profile);
        if (info->active_profile2 == *it) {
            m_activeProfileIndex = m_profiles.length() - 1;
        }
    }
    Q_EMIT profilesChanged();
    Q_EMIT activeProfileIndexChanged();

    qDeleteAll(m_ports);
    m_ports.clear();
    for (auto **it = info->ports; it && *it != nullptr; ++it) {
        CardPort *port = new CardPort(this);
        port->update(*it);
        m_ports.append(port);
    }
    Q_EMIT portsChanged();
}

QString Card::name() const
{
    return m_name;
}

QList<QObject *> Card::profiles() const
{
    return m_profiles;
}

quint32 Card::activeProfileIndex() const
{
    return m_activeProfileIndex;
}

void Card::setActiveProfileIndex(quint32 profileIndex)
{
    const Profile *profile = qobject_cast<Profile *>(profiles().at(profileIndex));
    context()->setCardProfile(index(), profile->name());
}

QList<QObject *> Card::ports() const
{
    return m_ports;
}

} // QPulseAudio
