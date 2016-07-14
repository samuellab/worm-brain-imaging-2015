%% Call ALC SDK 2.4 functions



loadlibrary('AB_ALC_REV64.dll', 'ALC_REV_C_full.h');

ref_val = -1;
alc_ptr = libpointer('int32Ptr', ref_val);
calllib('AB_ALC_REV64', 'Create_ALC_REV_NoDAC_C', alc_ptr);

LASERS = calllib('AB_ALC_REV64', 'Initialize', alc_ptr.Value);

%% Open serial communication with lasers

laser_1_COM = serial('COM201'); % 447
laser_2_COM = serial('COM202'); % Sapphire (488)
laser_3_COM = serial('COM203'); % Cobalt Jive (561)

laser_1_COM.Terminator = 'CR';
laser_1_COM.BaudRate = 19200;

laser_2_COM.Terminator = 'CR';
laser_2_COM.BaudRate = 19200;

laser_3_COM.Terminator = 'CR';
laser_3_COM.BaudRate = 115200;

fopen(laser_1_COM);
fopen(laser_2_COM);
fopen(laser_3_COM);

