#ifndef WORKSPACE_H
#define WORKSPACE_H

#include <QObject>
#include <QJsonArray>
#include <QSettings>
#include <QQmlListProperty>


class Pipe : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString inputId READ inputId WRITE setInputId NOTIFY inputIdChanged)
    Q_PROPERTY(QString outputId READ outputId WRITE setOutputId NOTIFY outputIdChanged)
public:
    explicit Pipe(QObject *parent = nullptr);

    void setInputId(const QString &id)
    {
        mInputId = id;
        emit inputIdChanged(mInputId);
    }
    QString inputId()
    {
        return mInputId;
    }
    void setOutputId(const QString &id)
    {
        mOutputId = id;
        emit outputIdChanged(mOutputId);
    }
    QString outputId()
    {
        return mOutputId;
    }

private:
    QString mInputId;
    QString mOutputId;

signals:
    void inputIdChanged(QString inputId);
    void outputIdChanged(QString inputId);
};

class Workspace:public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QQmlListProperty<Pipe> pipeList READ pipeList)
public:
    Workspace(QObject *parent = nullptr);

    static Workspace* fromJson(const QString &jsonStr);

    QString name()
    {
        return mName;
    }
    void setName(const QString &name)
    {
        mName = name;
    }
    QQmlListProperty<Pipe> pipeList();

    void appendPipe(Pipe *pipe);
    int pipeCount() const;
    Pipe *pipeAt(int idx) const;
    void clearPipes();

private:
    QString mName;
    QList<Pipe *> mPipeList;

    static void appendPipe(QQmlListProperty<Pipe> *, Pipe *pipe);
    static int pipeCount(QQmlListProperty<Pipe> *);
    static Pipe *pipeAt(QQmlListProperty<Pipe> *,int idx);
    static void clearPipes(QQmlListProperty<Pipe> *);
signals:
    void nameChanged(QString name);
};

class WorkspaceModel:public QObject
{
    Q_OBJECT

public:
    WorkspaceModel(QObject *parent = nullptr);

public slots:
    Q_INVOKABLE QJsonArray listJson();
    Q_INVOKABLE void addJson(QJsonValue json);
    Q_INVOKABLE void remove(int index);

private:
    QSettings *settings;
};

#endif // WORKSPACE_H
