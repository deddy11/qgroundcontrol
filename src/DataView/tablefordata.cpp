//#include "tablefordata.h"
//#include "MultiVehicleManager.h"
//#include "QGCMAVLink.h"
//#if !defined(__mobile__)
//#include "QGCQFileDialog.h"
//#include "MainWindow.h"
//#endif
//#include "UAS.h"
//#include "QGCApplication.h"
//#include "QGCToolbox.h"
//#include "QGCMapEngine.h"
//#include "ParameterManager.h"
//#include "Vehicle.h"
//#include "SettingsManager.h"

//#include <QDebug>
//#include <QSettings>
//#include <QUrl>
//#include <QBitArray>
//#include <QtCore/qmath.h>

//#define kTimeOutMilliseconds 500
//#define kGUIRateMilliseconds 17
//#define kTableBins           512
//#define kChunkSize           (kTableBins * MAVLINK_MSG_LOG_DATA_FIELD_DATA_LEN)

//QGC_LOGGING_CATEGORY(Table, "Table")

////-----------------------------------------------------------------------------
//struct TableDownloadData {
//    TableDownloadData(QGCLogEntry* entry);
//    QBitArray     chunk_table;
//    uint32_t      current_chunk;
//    QFile         file;
//    QString       filename;
//    uint          ID;
//    QGCLogEntry*  entry;
//    uint          written;
//    size_t        rate_bytes;
//    qreal         rate_avg;
//    QElapsedTimer elapsed;

//    void advanceChunk()
//    {
//           current_chunk++;
//           chunk_table = QBitArray(chunkBins(), false);
//    }

//    // The number of MAVLINK_MSG_LOG_DATA_FIELD_DATA_LEN bins in the current chunk
//    uint32_t chunkBins() const
//    {
//        return qMin(qCeil((entry->size() - current_chunk*kChunkSize)/static_cast<qreal>(MAVLINK_MSG_LOG_DATA_FIELD_DATA_LEN)),
//                    kTableBins);
//    }

//    // The number of kChunkSize chunks in the file
//    uint32_t numChunks() const
//    {
//        return qCeil(entry->size() / static_cast<qreal>(kChunkSize));
//    }

//    // True if all bins in the chunk have been set to val
//    bool chunkEquals(const bool val) const
//    {
//        return chunk_table == QBitArray(chunk_table.size(), val);
//    }

//};

////----------------------------------------------------------------------------------------
//TableDownloadData::TableDownloadData(QGCLogEntry* entry_)
//    : ID(entry_->id())
//    , entry(entry_)
//    , written(0)
//    , rate_bytes(0)
//    , rate_avg(0)
//{

//}

////----------------------------------------------------------------------------------------
//QGCLogEntry::QGCLogEntry(uint logId, const QDateTime& dateTime, uint logSize, bool received)
//    : _logID(logId)
//    , _logSize(logSize)
//    , _logTimeUTC(dateTime)
//    , _received(received)
//    , _selected(false)
//{
//    _status = tr("Pending");
//}

////----------------------------------------------------------------------------------------
//TableForData::TableForData(void)
//    : _uas(NULL)
//    , _downloadData(NULL)
//    , _vehicle(NULL)
//    , _requestingLogEntries(false)
//    , _downloadingLogs(false)
//    , _retries(0)
//    , _apmOneBased(0)
//{
//    MultiVehicleManager *manager = qgcApp()->toolbox()->multiVehicleManager();
//    connect(manager, &MultiVehicleManager::activeVehicleChanged, this, &TableForData::_setActiveVehicle);
//    connect(&_timer, &QTimer::timeout, this, &TableForData::_processDownload);
//    _setActiveVehicle(manager->activeVehicle());
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::_processDownload()
//{
//    if(_requestingLogEntries) {
//        _findMissingEntries();
//    } else if(_downloadingLogs) {
//        _findMissingData();
//    }
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::_setActiveVehicle(Vehicle* vehicle)
//{
//    if(_uas) {
//        _logEntriesModel.clear();
//        disconnect(_uas, &UASInterface::logEntry, this, &TableForData::_logEntry);
//        disconnect(_uas, &UASInterface::logData,  this, &TableForData::_logData);
//        _uas = NULL;
//    }
//    _vehicle = vehicle;
//    if(_vehicle) {
//        _uas = vehicle->uas();
//        connect(_uas, &UASInterface::logEntry, this, &TableForData::_logEntry);
//        connect(_uas, &UASInterface::logData,  this, &TableForData::_logData);
//    }
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::_logEntry(UASInterface* uas, uint32_t time_utc, uint32_t size, uint16_t id, uint16_t num_logs, uint16_t /*last_log_num*/)
//{
//    //-- Do we care?
//    if(!_uas || uas != _uas || !_requestingLogEntries) {
//        return;
//    }
//    //-- If this is the first, pre-fill it
//    if(!_logEntriesModel.count() && num_logs > 0) {
//        //-- Is this APM? They send a first entry with bogus ID and only the
//        //   count is valid. From now on, all entries are 1-based.
//        if(_vehicle->firmwareType() == MAV_AUTOPILOT_ARDUPILOTMEGA) {
//            _apmOneBased = 1;
//        }
//        for(int i = 0; i < num_logs; i++) {
//            QGCLogEntry *entry = new QGCLogEntry(i);
//            _logEntriesModel.append(entry);
//        }
//    }
//    //-- Update this log record
//    if(num_logs > 0) {
//        //-- Skip if empty (APM first packet)
//        if(size || _vehicle->firmwareType() != MAV_AUTOPILOT_ARDUPILOTMEGA) {
//            id -= _apmOneBased;
//            if(id < _logEntriesModel.count()) {
//                QGCLogEntry* entry = _logEntriesModel[id];
//                entry->setSize(size);
//                entry->setTime(QDateTime::fromTime_t(time_utc));
//                entry->setReceived(true);
//                entry->setStatus(QString(tr("Available")));
//            } else {
//                qWarning() << "Received log entry for out-of-bound index:" << id;
//            }
//        }
//    } else {
//        //-- No logs to list
//        _receivedAllEntries();
//    }
//    //-- Reset retry count
//    _retries = 0;
//    //-- Do we have it all?
//    if(_entriesComplete()) {
//        _receivedAllEntries();
//    } else {
//        //-- Reset timer
//        _timer.start(kTimeOutMilliseconds);
//    }
//}

////----------------------------------------------------------------------------------------
//bool
//TableForData::_entriesComplete()
//{
//    //-- Iterate entries and look for a gap
//    int num_logs = _logEntriesModel.count();
//    for(int i = 0; i < num_logs; i++) {
//        QGCLogEntry* entry = _logEntriesModel[i];
//        if(entry) {
//            if(!entry->received()) {
//               return false;
//            }
//        }
//    }
//    return true;
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::_resetSelection(bool canceled)
//{
//    int num_logs = _logEntriesModel.count();
//    for(int i = 0; i < num_logs; i++) {
//        QGCLogEntry* entry = _logEntriesModel[i];
//        if(entry) {
//            if(entry->selected()) {
//                if(canceled) {
//                    entry->setStatus(QString(tr("Canceled")));
//                }
//                entry->setSelected(false);
//            }
//        }
//    }
//    emit selectionChanged();
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::_receivedAllEntries()
//{
//    _timer.stop();
//    _setListing(false);
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::_findMissingEntries()
//{
//    int start = -1;
//    int end   = -1;
//    int num_logs = _logEntriesModel.count();
//    //-- Iterate entries and look for a gap
//    for(int i = 0; i < num_logs; i++) {
//        QGCLogEntry* entry = _logEntriesModel[i];
//        if(entry) {
//            if(!entry->received()) {
//                if(start < 0)
//                    start = i;
//                else
//                    end = i;
//            } else {
//                if(start >= 0) {
//                    break;
//                }
//            }
//        }
//    }
//    //-- Is there something missing?
//    if(start >= 0) {
//        //-- Have we tried too many times?
//        if(_retries++ > 2) {
//            for(int i = 0; i < num_logs; i++) {
//                QGCLogEntry* entry = _logEntriesModel[i];
//                if(entry && !entry->received()) {
//                    entry->setStatus(QString(tr("Error")));
//                }
//            }
//            //-- Give up
//            _receivedAllEntries();
//            qWarning() << "Too many errors retreiving log list. Giving up.";
//            return;
//        }
//        //-- Is it a sequence or just one entry?
//        if(end < 0) {
//            end = start;
//        }
//        //-- APM "Fix"
//        start += _apmOneBased;
//        end   += _apmOneBased;
//        //-- Request these entries again
//        _requestLogList((uint32_t)start, (uint32_t) end);
//    } else {
//        _receivedAllEntries();
//    }
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::_logData(UASInterface* uas, uint32_t ofs, uint16_t id, uint8_t count, const uint8_t* data)
//{
//    if(!_uas || uas != _uas || !_downloadData) {
//        return;
//    }
//    //-- APM "Fix"
//    id -= _apmOneBased;
//    if(_downloadData->ID != id) {
//        qWarning() << "Received log data for wrong log";
//        return;
//    }

//    if ((ofs % MAVLINK_MSG_LOG_DATA_FIELD_DATA_LEN) != 0) {
//        qWarning() << "Ignored misaligned incoming packet @" << ofs;
//        return;
//    }

//    bool result = false;
//    uint32_t timeout_time = kTimeOutMilliseconds;
//    if(ofs <= _downloadData->entry->size()) {
//        const uint32_t chunk = ofs / kChunkSize;
//        if (chunk != _downloadData->current_chunk) {
//            qWarning() << "Ignored packet for out of order chunk" << chunk;
//            return;
//        }
//        const uint16_t bin = (ofs - chunk*kChunkSize) / MAVLINK_MSG_LOG_DATA_FIELD_DATA_LEN;
//        if (bin >= _downloadData->chunk_table.size()) {
//            qWarning() << "Out of range bin received";
//        } else
//            _downloadData->chunk_table.setBit(bin);
//        if (_downloadData->file.pos() != ofs) {
//            // Seek to correct position
//            if (!_downloadData->file.seek(ofs)) {
//                qWarning() << "Error while seeking log file offset";
//                return;
//            }
//        }

//        //-- Write chunk to file
//        if(_downloadData->file.write((const char*)data, count)) {
//            _downloadData->written += count;
//            _downloadData->rate_bytes += count;
//            if (_downloadData->elapsed.elapsed() >= kGUIRateMilliseconds) {
//                //-- Update download rate
//                qreal rrate = _downloadData->rate_bytes/(_downloadData->elapsed.elapsed()/1000.0);
//                _downloadData->rate_avg = _downloadData->rate_avg*0.95 + rrate*0.05;
//                _downloadData->rate_bytes = 0;

//                //-- Update status
//                const QString status = QString("%1 (%2/s)").arg(QGCMapEngine::bigSizeToString(_downloadData->written),
//                                                                QGCMapEngine::bigSizeToString(_downloadData->rate_avg));

//                _downloadData->entry->setStatus(status);
//                _downloadData->elapsed.start();
//            }
//            result = true;
//            //-- reset retries
//            _retries = 0;
//            //-- Reset timer
//            _timer.start(timeout_time);
//            //-- Do we have it all?
//            if(_logComplete()) {
//                _downloadData->entry->setStatus(QString(tr("Downloaded")));
//                //-- Check for more
//                _receivedAllData();
//            } else if (_chunkComplete()) {
//                _downloadData->advanceChunk();
//                _requestLogData(_downloadData->ID,
//                                _downloadData->current_chunk*kChunkSize,
//                                _downloadData->chunk_table.size()*MAVLINK_MSG_LOG_DATA_FIELD_DATA_LEN);
//            } else if (bin < _downloadData->chunk_table.size() - 1 && _downloadData->chunk_table.at(bin+1)) {
//                // Likely to be grabbing fragments and got to the end of a gap
//                _findMissingData();
//            }
//        } else {
//            qWarning() << "Error while writing log file chunk";
//        }
//    } else {
//        qWarning() << "Received log offset greater than expected";
//    }
//    if(!result) {
//        _downloadData->entry->setStatus(QString(tr("Error")));
//    }
//}


////----------------------------------------------------------------------------------------
//bool
//TableForData::_chunkComplete() const
//{
//    return _downloadData->chunkEquals(true);
//}

////----------------------------------------------------------------------------------------
//bool
//TableForData::_logComplete() const
//{
//    return _chunkComplete() && (_downloadData->current_chunk+1) == _downloadData->numChunks();
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::_receivedAllData()
//{
//    _timer.stop();
//    //-- Anything queued up for download?
//    if(_prepareLogDownload()) {
//        //-- Request Log
//        _requestLogData(_downloadData->ID, 0, _downloadData->chunk_table.size()*MAVLINK_MSG_LOG_DATA_FIELD_DATA_LEN);
//        _timer.start(kTimeOutMilliseconds);
//    } else {
//        _resetSelection();
//        _setDownloading(false);
//    }
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::_findMissingData()
//{
//    if (_logComplete()) {
//         _receivedAllData();
//         return;
//    } else if (_chunkComplete()) {
//        _downloadData->advanceChunk();
//    }

//    if(_retries++ > 2) {
//        _downloadData->entry->setStatus(QString(tr("Timed Out")));
//        //-- Give up
//        qWarning() << "Too many errors retreiving log data. Giving up.";
//        _receivedAllData();
//        return;
//    }

//    uint16_t start = 0, end = 0;
//    const int size = _downloadData->chunk_table.size();
//    for (; start < size; start++) {
//        if (!_downloadData->chunk_table.testBit(start)) {
//            break;
//        }
//    }

//    for (end = start; end < size; end++) {
//        if (_downloadData->chunk_table.testBit(end)) {
//            break;
//        }
//    }

//    const uint32_t pos = _downloadData->current_chunk*kChunkSize + start*MAVLINK_MSG_LOG_DATA_FIELD_DATA_LEN,
//                   len = (end - start)*MAVLINK_MSG_LOG_DATA_FIELD_DATA_LEN;
//    _requestLogData(_downloadData->ID, pos, len);
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::_requestLogData(uint16_t id, uint32_t offset, uint32_t count)
//{
//    if(_vehicle) {
//        //-- APM "Fix"
//        id += _apmOneBased;
//        qCDebug(Table) << "Request log data (id:" << id << "offset:" << offset << "size:" << count << ")";
//        mavlink_message_t msg;
//        mavlink_msg_log_request_data_pack_chan(
//                    qgcApp()->toolbox()->mavlinkProtocol()->getSystemId(),
//                    qgcApp()->toolbox()->mavlinkProtocol()->getComponentId(),
//                    _vehicle->priorityLink()->mavlinkChannel(),
//                    &msg,
//                    qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->id(), qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->defaultComponentId(),
//                    id, offset, count);
//        _vehicle->sendMessageOnLink(_vehicle->priorityLink(), msg);
//    }
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::refresh(void)
//{
//    _logEntriesModel.clear();
//    //-- Get first 50 entries
//    _requestLogList(0, 49);
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::_requestLogList(uint32_t start, uint32_t end)
//{
//    if(_vehicle && _uas) {
//        qCDebug(Table) << "Request log entry list (" << start << "through" << end << ")";
//        _setListing(true);
//        mavlink_message_t msg;
//        mavlink_msg_log_request_list_pack_chan(
//                    qgcApp()->toolbox()->mavlinkProtocol()->getSystemId(),
//                    qgcApp()->toolbox()->mavlinkProtocol()->getComponentId(),
//                    _vehicle->priorityLink()->mavlinkChannel(),
//                    &msg,
//                    _vehicle->id(),
//                    _vehicle->defaultComponentId(),
//                    start,
//                    end);
//        _vehicle->sendMessageOnLink(_vehicle->priorityLink(), msg);
//        //-- Wait 5 seconds before bitching about not getting anything
//        _timer.start(5000);
//    }
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::download(QString path)
//{
//    QString dir = path;
//#if defined(__mobile__)
//    if(dir.isEmpty()) {
//        dir = qgcApp()->toolbox()->settingsManager()->appSettings()->logSavePath();
//    }
//#else
//    if(dir.isEmpty()) {
//        dir = QGCQFileDialog::getExistingDirectory(
//                MainWindow::instance(),
//                tr("Log Download Directory"),
//                QDir::homePath(),
//                QGCQFileDialog::ShowDirsOnly | QGCQFileDialog::DontResolveSymlinks);
//    }
//#endif
//    downloadToDirectory(dir);
//}

//void TableForData::downloadToDirectory(const QString& dir)
//{
//    //-- Stop listing just in case
//    _receivedAllEntries();
//    //-- Reset downloads, again just in case
//    if(_downloadData) {
//        delete _downloadData;
//        _downloadData = 0;
//    }
//    _downloadPath = dir;
//    if(!_downloadPath.isEmpty()) {
//        if(!_downloadPath.endsWith(QDir::separator()))
//            _downloadPath += QDir::separator();
//        //-- Iterate selected entries and shown them as waiting
//        int num_logs = _logEntriesModel.count();
//        for(int i = 0; i < num_logs; i++) {
//            QGCLogEntry* entry = _logEntriesModel[i];
//            if(entry) {
//                if(entry->selected()) {
//                   entry->setStatus(QString(tr("Waiting")));
//                }
//            }
//        }
//        //-- Start download process
//        _setDownloading(true);
//        _receivedAllData();
//    }
//}


////----------------------------------------------------------------------------------------
//QGCLogEntry*
//TableForData::_getNextSelected()
//{
//    //-- Iterate entries and look for a selected file
//    int num_logs = _logEntriesModel.count();
//    for(int i = 0; i < num_logs; i++) {
//        QGCLogEntry* entry = _logEntriesModel[i];
//        if(entry) {
//            if(entry->selected()) {
//               return entry;
//            }
//        }
//    }
//    return NULL;
//}

////----------------------------------------------------------------------------------------
//bool
//TableForData::_prepareLogDownload()
//{
//    if(_downloadData) {
//        delete _downloadData;
//        _downloadData = NULL;
//    }
//    QGCLogEntry* entry = _getNextSelected();
//    if(!entry) {
//        return false;
//    }
//    //-- Deselect file
//    entry->setSelected(false);
//    emit selectionChanged();
//    bool result = false;
//    QString ftime;
//    if(entry->time().date().year() < 2010) {
//        ftime = tr("UnknownDate");
//    } else {
//        ftime = entry->time().toString(QStringLiteral("yyyy-M-d-hh-mm-ss"));
//    }
//    _downloadData = new TableDownloadData(entry);
//    _downloadData->filename = QString("log_") + QString::number(entry->id()) + "_" + ftime;
//    if (_vehicle->firmwareType() == MAV_AUTOPILOT_PX4) {
//        QString loggerParam = QStringLiteral("SYS_LOGGER");
//        if (_vehicle->parameterManager()->parameterExists(FactSystem::defaultComponentId, loggerParam) &&
//                _vehicle->parameterManager()->getParameter(FactSystem::defaultComponentId, loggerParam)->rawValue().toInt() == 0) {
//            _downloadData->filename += ".px4log";
//        } else {
//            _downloadData->filename += ".ulg";
//        }
//    } else {
//        _downloadData->filename += ".bin";
//    }
//    _downloadData->file.setFileName(_downloadPath + _downloadData->filename);
//    //-- Append a number to the end if the filename already exists
//    if (_downloadData->file.exists()){
//        uint num_dups = 0;
//        QStringList filename_spl = _downloadData->filename.split('.');
//        do {
//            num_dups +=1;
//            _downloadData->file.setFileName(filename_spl[0] + '_' + QString::number(num_dups) + '.' + filename_spl[1]);
//        } while( _downloadData->file.exists());
//    }
//    //-- Create file
//    if (!_downloadData->file.open(QIODevice::WriteOnly)) {
//        qWarning() << "Failed to create log file:" <<  _downloadData->filename;
//    } else {
//        //-- Preallocate file
//        if(!_downloadData->file.resize(entry->size())) {
//            qWarning() << "Failed to allocate space for log file:" <<  _downloadData->filename;
//        } else {
//            _downloadData->current_chunk = 0;
//            _downloadData->chunk_table = QBitArray(_downloadData->chunkBins(), false);
//            _downloadData->elapsed.start();
//            result = true;
//        }
//    }
//    if(!result) {
//        if (_downloadData->file.exists()) {
//            _downloadData->file.remove();
//        }
//        _downloadData->entry->setStatus(QString(tr("Error")));
//        delete _downloadData;
//        _downloadData = NULL;
//    }
//    return result;
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::_setDownloading(bool active)
//{
//    if (_downloadingLogs != active) {
//        _downloadingLogs = active;
//        _vehicle->setConnectionLostEnabled(!active);
//        emit downloadingLogsChanged();
//    }
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::_setListing(bool active)
//{
//    if (_requestingLogEntries != active) {
//        _requestingLogEntries = active;
//        _vehicle->setConnectionLostEnabled(!active);
//        emit requestingListChanged();
//    }
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::eraseAll(void)
//{
//    if(_vehicle && _uas) {
//        mavlink_message_t msg;
//        mavlink_msg_log_erase_pack_chan(
//                    qgcApp()->toolbox()->mavlinkProtocol()->getSystemId(),
//                    qgcApp()->toolbox()->mavlinkProtocol()->getComponentId(),
//                    _vehicle->priorityLink()->mavlinkChannel(),
//                    &msg,
//                    qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->id(), qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->defaultComponentId());
//        _vehicle->sendMessageOnLink(_vehicle->priorityLink(), msg);
//        refresh();
//    }
//}

////----------------------------------------------------------------------------------------
//void
//TableForData::cancel(void)
//{
//    if(_uas){
//        _receivedAllEntries();
//    }
//    if(_downloadData) {
//        _downloadData->entry->setStatus(QString(tr("Canceled")));
//        if (_downloadData->file.exists()) {
//            _downloadData->file.remove();
//        }
//        delete _downloadData;
//        _downloadData = 0;
//    }
//    _resetSelection(true);
//    _setDownloading(false);
//}

////-----------------------------------------------------------------------------
//QGCLogModel::QGCLogModel(QObject* parent)
//    : QAbstractListModel(parent)
//{

//}

////-----------------------------------------------------------------------------
//QGCLogEntry*
//QGCLogModel::get(int index)
//{
//    if (index < 0 || index >= _tableEntries.count()) {
//        return NULL;
//    }
//    return _tableEntries[index];
//}

////-----------------------------------------------------------------------------
//int
//QGCLogModel::count() const
//{
//    return _tableEntries.count();
//}

////-----------------------------------------------------------------------------
//void
//QGCLogModel::append(QGCLogEntry* object)
//{
//    beginInsertRows(QModelIndex(), rowCount(), rowCount());
//    QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
//    _tableEntries.append(object);
//    endInsertRows();
//    emit countChanged();
//}

////-----------------------------------------------------------------------------
//void
//QGCLogModel::clear(void)
//{
//    if(!_tableEntries.isEmpty()) {
//        beginRemoveRows(QModelIndex(), 0, _tableEntries.count());
//        while (_tableEntries.count()) {
//            QGCLogEntry* entry = _tableEntries.last();
//            if(entry) entry->deleteLater();
//            _tableEntries.removeLast();
//        }
//        endRemoveRows();
//        emit countChanged();
//    }
//}

////-----------------------------------------------------------------------------
//QGCLogEntry*
//QGCLogModel::operator[](int index)
//{
//    return get(index);
//}

////-----------------------------------------------------------------------------
//int
//QGCLogModel::rowCount(const QModelIndex& /*parent*/) const
//{
//    return _tableEntries.count();
//}

////-----------------------------------------------------------------------------
//QVariant
//QGCLogModel::data(const QModelIndex & index, int role) const {
//    if (index.row() < 0 || index.row() >= _tableEntries.count())
//        return QVariant();
//    if (role == ObjectRole)
//        return QVariant::fromValue(_tableEntries[index.row()]);
//    return QVariant();
//}

////-----------------------------------------------------------------------------
//QHash<int, QByteArray>
//QGCLogModel::roleNames() const {
//    QHash<int, QByteArray> roles;
//    roles[ObjectRole] = "logEntry";
//    return roles;
//}
