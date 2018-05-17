#include "contaminant.h"

Contaminant::Contaminant(QObject *parent) : QObject(parent)
{

}

void Contaminant::setLatitude(float lati)
{
    _coordinate.setLatitude(lati);
}

void Contaminant::setLongitude(float longi)
{
    _coordinate.setLongitude(longi);
}

void Contaminant::setAltitude(float alti)
{
    _coordinate.setAltitude(alti);
}

void Contaminant::setVehicleType(int vehicleType)
{
    _vehicleType = vehicleType;
}

void Contaminant::setSubsType(int subsType)
{
    _subsType = subsType;
}

void Contaminant::setSubsID(int subsID)
{
    _subsID = subsID;
}

void Contaminant::setSubsConsentration(int subsConsentration)
{
    _subsConsentration = subsConsentration;
}
