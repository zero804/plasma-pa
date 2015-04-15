#ifndef SINKINPUT_H
#define SINKINPUT_H

#include "streambase.h"

class Q_DECL_EXPORT SinkInput : public StreamBase<pa_sink_input_info>
{
    Q_OBJECT
#warning missing properties

    Q_PROPERTY(qint64 volume READ volume WRITE setVolume)
    Q_PROPERTY(bool muted READ isMuted WRITE setMuted)
public:
    void setInfo(const pa_sink_input_info *info) Q_DECL_OVERRIDE Q_DECL_FINAL;

    quint32 sinkIndex() const { return m_sinkIndex; }

    void setVolume(qint64 volume) Q_DECL_OVERRIDE;
    void setMuted(bool muted) Q_DECL_OVERRIDE;

private:
    quint32 m_sinkIndex = 0;
};

#endif // SINKINPUT_H
