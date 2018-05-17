#ifndef CONTAMINANT_H
#define CONTAMINANT_H

#pragma once

#include <QObject>
#include <QGeoCoordinate>

class Contaminant : public QObject
{
    Q_OBJECT
public:
    explicit Contaminant(QObject *parent = nullptr);

    Q_PROPERTY(QGeoCoordinate coordinate READ coordinate NOTIFY coordinateChanged);
    Q_PROPERTY(int vehicleType READ vehicleType WRITE setVehicleType NOTIFY vehicleTypeChanged);
    Q_PROPERTY(int subsType READ subsType WRITE setSubsType NOTIFY subsTypeChanged);
    Q_PROPERTY(int subsID READ subsID WRITE setSubsID NOTIFY subsIDChanged);
    Q_PROPERTY(int subsConsentration READ subsConsentration WRITE setSubsConsentration NOTIFY subsConsentrationChanged)

//getters
    QGeoCoordinate coordinate(void) { return _coordinate; }
    int vehicleType(void) { return _vehicleType; }
    int subsType(void) { return _subsType; }
    int subsID(void) { return _subsID; }
    int subsConsentration(void) { return _subsConsentration; };

//setters
    void setVehicleType(int vehicleType);
    void setSubsType(int subsType);
    void setSubsID(int subsID);
    void setSubsConsentration(int subsConsentration);

public slots:
    void setLatitude(float lati);
    void setLongitude(float longi);
    void setAltitude(float alti);

signals:
    void coordinateChanged ( QGeoCoordinate _coordinate );
    void vehicleTypeChanged( int _vehicleType );
    void subsTypeChanged( int _subsType );
    void subsIDChanged( int _subsID );
    void subsConsentrationChanged( int _subsConsentration );

private:
    QGeoCoordinate _coordinate;
    int _vehicleType;
    int _subsType;
    int _subsID;
    int _subsConsentration;

};

#endif // CONTAMINANT_H
