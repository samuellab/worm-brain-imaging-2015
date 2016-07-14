#ifndef _LaserStatus_H
#define _LaserStatus_H

/**
 * the following interfaces exposes the functionality required for the
 * ALC_REV module that is to be used in the Micro Manager environment
 */

typedef enum ELaserState
{
  ALC_NOT_AVAILABLE,
  ALC_WARM_UP,
  ALC_READY,
  ALC_INTERLOCK_ERROR,
  ALC_POWER_ERROR
}TLaserState;


#endif
