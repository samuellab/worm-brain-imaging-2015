#include "LaserState.h"

int Initialize( int hALC_REV_Laser);
int GetNumberOfLasers( int hALC_REV_Laser);
int GetWavelength( int hALC_REV_Laser, int LaserIndex, int *Wavelength);
int GetPower( int hALC_REV_Laser, int LaserIndex, int *Power);
int IsLaserOutputLinearised( int hALC_REVObject, int LaserIndex, int *Linearised);


int IsEnabled( int hALC_REVObject, int LaserIndex, int *Enabled);
int Enable( int hALC_REVObject, int LaserIndex);
int Disable( int hALC_REVObject, int LaserIndex);

int IsControlModeAvailable( int hALC_REVObject, int LaserIndex, int *Available);
int GetControlMode( int hALC_REVObject, int LaserIndex, int *ControlMode);
int SetControlMode( int hALC_REVObject, int LaserIndex, int Mode);


int GetLaserState( int hALC_REV_Laser, int LaserIndex, int *LaserState);
int GetLaserHours( int hALC_REV_Laser, int LaserIndex, int *Hours);
int GetCurrentPower( int hALC_REV_Laser, int LaserIndex, double *CurrentPower);
int SetLas_W( int hALC_REV_Laser, int Wavelength, double Power, int On);
int SetLas_I( int hALC_REV_Laser, int LaserIndex, double Power, int On);
int GetLas_W( int hALC_REV_Laser, int Wavelength, double *Power, int *On);
int GetLas_I( int hALC_REV_Laser, int LaserIndex, double *Power, int *On);
int SetLas_Shutter( int hALC_REV_Laser, int Open);

int GetNumberOfPorts( int hALC_REVObject, int *NumberOfPorts);
int GetPowerLimit( int hALC_REVObject, int PortIndex, double *PowerLimit_mW);

int GetPortForPowerLimit( int hALC_REVObject, int *Port); 

int SetPortForPowerLimit( int hALC_REVObject, int Port); 

int GetCurrentPowerIntoFiber( int hALC_REVObject, double *Power_mW);
int CalculatePowerIntoFibre( int hALC_REVObject, int LaserIndex, double PercentPower, double *Power_mW);

int GetPowerStatus( int hALC_REVObject, int *PowerStatus);
int WasLaserIlluminationProhibitedOnLastChange( int hALC_REVObject, int LaserIndex, int *Prohibited);
int IsLaserIlluminationProhibited( int hALC_REVObject, int LaserIndex, int *Prohibited);
int InitializePiezo( int hALC_REV_Piezo);
int GetRange( int hALC_REV_Piezo, double *Range_um);
int SetRange( int hALC_REV_Piezo, double Range_um);
int GetPosition( int hALC_REV_Piezo, double *Position_um);
int SetPosition( int hALC_REV_Piezo, double Position_um);
int InitializeDIO( int hALC_REV_DIO);
int GetDIN( int hALC_REV_DIO, unsigned char *InputByte);
int SetDOUT( int hALC_REV_DIO, unsigned char OutputByte);
int Create_ALC_REV_C( int *hALC_REV);
int Create_ALC_REV_NoDAC_C( int *hALC_REV);

int Delete_ALC_REV_C( int hALC_REV);