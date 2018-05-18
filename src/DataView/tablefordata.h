//#ifndef TABLEFORDATA_H
//#define TABLEFORDATA_H

//#include <QObject>
//#include <QTimer>
//#include <QAbstractListModel>
//#include <QLocale>
//#include <QElapsedTimer>
//#include "QGCQGeoCoordinate.h"

//#include <memory>

//#include "UASInterface.h"
//#include "AutoPilotPlugin.h"

//class  MultiVehicleManager;
//class  UASInterface;
//class  Vehicle;
//class  QGCLogEntry;
//struct LogDownloadData;

//Q_DECLARE_LOGGING_CATEGORY(Table)

////-----------------------------------------------------------------------------
//class QGCLogModel : public QAbstractListModel
//{
//    Q_OBJECT
//public:

//    enum QGCLogModelRoles {
//        ObjectRole = Qt::UserRole + 1
//    };

//    QGCLogModel(QObject *parent = 0);

//    Q_PROPERTY(int count READ count NOTIFY countChanged)
//    Q_INVOKABLE QGCLogEntry* get(int index);

//    int         count           (void) const;
//    void        append          (QGCLogEntry* entry);
//    void        clear           (void);
//    QGCLogEntry*operator[]      (int i);

//    int         rowCount        (const QModelIndex & parent = QModelIndex()) const;
//    QVariant    data            (const QModelIndex & index, int role = Qt::DisplayRole) const;

//signals:
//    void        countChanged    ();

//protected:
//    QHash<int, QByteArray> roleNames() const;
//private:
//    QList<QGCLogEntry*> _tableEntries;
//};

////-----------------------------------------------------------------------------
//class QGCLogEntry : public QObject {
//    Q_OBJECT
//    Q_PROPERTY(int              vehicleType     READ vehicleType    WRITE setVehicleType    NOTIFY vehicleTypeChanged)
//    Q_PROPERTY(int              subsType        READ subsType       WRITE setSubsType       NOTIFY subsTypeChanged)
//    Q_PROPERTY(int              subsID          READ subsID         WRITE setSubsID         NOTIFY subsIDChanged)
//    Q_PROPERTY(int              consentration   READ consentration  WRITE setConsentration  NOTIFY consentrationChanged)
//    Q_PROPERTY(QGeoCoordinate   position        READ position       WRITE setPosition       NOTIFY positionChanged)

//    Q_PROPERTY(bool             received        READ received       WRITE setReceived       NOTIFY receivedChanged)
//    Q_PROPERTY(bool             selected        READ selected       WRITE setSelected       NOTIFY selectedChanged)

//public:
//    QGCLogEntry(uint logId, const QDateTime& dateTime = QDateTime(), uint logSize = 0, bool received = false); //belum

//    QGeoCoordinate position(void) { return _position; }
//    int vehicleType(void) { return _vehicleType; }
//    int subsType(void) { return _subsType; }
//    int subsID(void) { return _subsID; }
//    int consentration(void) { return _consentration; }
//    bool        received    () const { return _received; }
//    bool        selected    () const { return _selected; }

////    uint        id          () const { return _logID; }
////    uint        size        () const { return _logSize; }
////    QString     sizeStr     () const;
////    QDateTime   time        () const { return _logTimeUTC; }
////    QString     status      () const { return _status; }

////    void        setId       (uint id_)          { _logID = id_; }
////    void        setSize     (uint size_)        { _logSize = size_;     emit sizeChanged(); }
////    void        setTime     (QDateTime date_)   { _logTimeUTC = date_;  emit timeChanged(); }
////    void        setStatus               (QString stat_)     { _status = stat_;      emit statusChanged(); }
//    void    setPosition             (QGeoCoordinate position_)  { _position = position_;            emit positionChanged(); }
//    void    setVehicleType          (int vehicleType_)          { _vehicleType = vehicleType_;      emit vehicleTypeChanged(); }
//    void    setSubsType             (int subsType_)             { _subsType = subsType_;            emit subsTypeChanged(); }
//    void    setSubsID               (int subsID_)               { _subsID = subsID_;                emit subsIDChanged(); }
//    void    setSubsConsentration    (int consentration_)        { _consentration = consentration_;  emit consentrationChanged(); }
//    void    setReceived             (bool rec_)                 { _received = rec_;                 emit receivedChanged(); }
//    void    setSelected             (bool sel_)                 { _selected = sel_;                 emit selectedChanged(); }


//signals:
////    void    idChanged       ();
////    void    timeChanged     ();
////    void    sizeChanged     ();
////    void    statusChanged   ();
//    void    receivedChanged         ();
//    void    selectedChanged         ();
//    void    positionChanged         ();
//    void    vehicleTypeChanged      ();
//    void    subsTypeChanged         ();
//    void    subsIDChanged           ();
//    void    consentrationChanged    ();

//private:
////    uint        _logID;
////    uint        _logSize;
////    QDateTime   _logTimeUTC;
////    QString     _status;
//    QGeoCoordinate  _position;
//    int             _vehicleType;
//    int             _subsType;
//    int             _subsID;
//    int             _consentration;
//    bool            _received;
//    bool            _selected;

//};

//class TableForData : public Object
//{
//    Q_OBJECT
//public:
//    TableForData(void);
//    Q_PROPERTY(QGCLogModel* model           READ model              NOTIFY modelChanged)
//    Q_PROPERTY(bool         requestingList  READ requestingList     NOTIFY requestingListChanged)
//    Q_PROPERTY(bool         downloadingLogs READ downloadingLogs    NOTIFY downloadingLogsChanged)

//    QGCLogModel*    model                   () { return &_logEntriesModel; }
//    bool            requestingList          () { return _requestingLogEntries; }
//    bool            downloadingLogs         () { return _downloadingLogs; }

//    Q_INVOKABLE void refresh                ();
//    Q_INVOKABLE void download               ( QString path = QString() );
//    Q_INVOKABLE void eraseAll               ();
//    Q_INVOKABLE void cancel                 ();

//    void downloadToDirectory(const QString& dir);

//signals:
//    void requestingListChanged  ();
//    void downloadingLogsChanged ();
//    void modelChanged           ();
//    void selectionChanged       ();

//private slots:
//    void _setActiveVehicle  (Vehicle* vehicle);
//    void _logEntry          (UASInterface *uas, uint32_t time_utc, uint32_t size, uint16_t id, uint16_t num_logs, uint16_t last_log_num);
//    void _logData           (UASInterface *uas, uint32_t ofs, uint16_t id, uint8_t count, const uint8_t *data);
//    void _processDownload   ();

//private:
//    bool _entriesComplete   ();
//    bool _chunkComplete     () const;
//    bool _logComplete       () const;
//    void _findMissingEntries();
//    void _receivedAllEntries();
//    void _receivedAllData   ();
//    void _resetSelection    (bool canceled = false);
//    void _findMissingData   ();
//    void _requestLogList    (uint32_t start, uint32_t end);
//    void _requestLogData    (uint16_t id, uint32_t offset = 0, uint32_t count = 0xFFFFFFFF);
//    bool _prepareLogDownload();
//    void _setDownloading    (bool active);
//    void _setListing        (bool active);

//    QGCLogEntry* _getNextSelected();

//    UASInterface*       _uas;
//    LogDownloadData*    _downloadData;
//    QTimer              _timer;
//    QGCLogModel         _logEntriesModel;
//    Vehicle*            _vehicle;
//    bool                _requestingLogEntries;
//    bool                _downloadingLogs;
//    int                 _retries;
//    int                 _apmOneBased;
//    QString             _downloadPath;

//};
//#endif // TABLEFORDATA_H
