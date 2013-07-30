/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *   Mupen64plus-input-MALInput - plugin.c                                 *
 *   Mupen64Plus homepage: http://code.google.com/p/mupen64plus/           *
 *   MacMupen homepage: https://github.com/Technochrome/MacMupen64/        *
 *   Copyright (C) 2013 John Pender                                        *
 *   Copyright (C) 2008-2011 Richard Goedeken                              *
 *   Copyright (C) 2008 Tillin9                                            *
 *   Copyright (C) 2002 Blight                                             *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.          *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define M64P_PLUGIN_PROTOTYPES 1
#include "m64p_types.h"
#include "m64p_plugin.h"
#include "m64p_common.h"
#include "m64p_config.h"

#include "plugin.h"
#include "version.h"

#import <Foundation/Foundation.h>
#import <MacMupen/MALMupenEngine.h>

#include <errno.h>

/* static data definitions */
static void (*l_DebugCallback)(void *, int, const char *) = NULL;
static void *l_DebugCallContext = NULL;
static int l_PluginInit = 0;

enum EButton
{
    R_DPAD          = 0,
    L_DPAD,
    D_DPAD,
    U_DPAD,
    START_BUTTON,
    Z_TRIG,
    B_BUTTON,
    A_BUTTON,
    R_CBUTTON,
    L_CBUTTON,
    D_CBUTTON,
    U_CBUTTON,
    R_TRIG,
    L_TRIG,
    MEMPAK,
    RUMBLEPAK,
    X_AXIS,
    Y_AXIS,
    NUM_BUTTONS
};

static unsigned short button_bits[] = {
    0x0001,  // R_DPAD
    0x0002,  // L_DPAD
    0x0004,  // D_DPAD
    0x0008,  // U_DPAD
    0x0010,  // START_BUTTON
    0x0020,  // Z_TRIG
    0x0040,  // B_BUTTON
    0x0080,  // A_BUTTON
    0x0100,  // R_CBUTTON
    0x0200,  // L_CBUTTON
    0x0400,  // D_CBUTTON
    0x0800,  // U_CBUTTON
    0x1000,  // R_TRIG
    0x2000,  // L_TRIG
    0x4000,  // Mempak switch
    0x8000   // Rumblepak switch
};

static int romopen = 0;         // is a rom opened

/* Global functions */
void DebugMessage(int level, const char *message, ...)
{
  char msgbuf[1024];
  va_list args;

  if (l_DebugCallback == NULL)
      return;

  va_start(args, message);
  vsprintf(msgbuf, message, args);

  (*l_DebugCallback)(l_DebugCallContext, level, msgbuf);

  va_end(args);
}

/* Mupen64Plus plugin functions */
EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle CoreLibHandle, void *Context,
                                   void (*DebugCallback)(void *, int, const char *))
{
	
    if (l_PluginInit)
        return M64ERR_ALREADY_INIT;

    /* first thing is to set the callback function for debug info */
    l_DebugCallback = DebugCallback;
    l_DebugCallContext = Context;

    l_PluginInit = 1;
    return M64ERR_SUCCESS;
}

EXPORT m64p_error CALL PluginShutdown(void)
{
    if (!l_PluginInit)
        return M64ERR_NOT_INIT;

    /* reset some local variables */
    l_DebugCallback = NULL;
    l_DebugCallContext = NULL;

    l_PluginInit = 0;
    return M64ERR_SUCCESS;
}

EXPORT m64p_error CALL PluginGetVersion(m64p_plugin_type *PluginType, int *PluginVersion, int *APIVersion, const char **PluginNamePtr, int *Capabilities)
{
#define safeSet(ref,value) if(ref != NULL) *ref = value
	
	safeSet(PluginType,    M64PLUGIN_INPUT);
	safeSet(PluginVersion, PLUGIN_VERSION);
	safeSet(APIVersion,    INPUT_PLUGIN_API_VERSION);
	safeSet(PluginNamePtr, PLUGIN_NAME);
	safeSet(Capabilities,  0);
	
                    
    return M64ERR_SUCCESS;
}

/******************************************************************
  Function: ControllerCommand
  Purpose:  To process the raw data that has just been sent to a
            specific controller.
  input:    - Controller Number (0 to 3) and -1 signalling end of
              processing the pif ram.
            - Pointer of data to be processed.
  output:   none

  note:     This function is only needed if the DLL is allowing raw
            data, or the plugin is set to raw

            the data that is being processed looks like this:
            initilize controller: 01 03 00 FF FF FF
            read controller:      01 04 01 FF FF FF FF
*******************************************************************/
EXPORT void CALL ControllerCommand(int Control, unsigned char *Command)
{
//    unsigned char *Data = &Command[5];

    if (Control == -1)
        return;

    switch (Command[2])
    {
        case RD_GETSTATUS:
#ifdef _DEBUG
            DebugMessage(M64MSG_INFO, "Get status");
#endif
            break;
        case RD_READKEYS:
#ifdef _DEBUG
            DebugMessage(M64MSG_INFO, "Read keys");
#endif
            break;
        case RD_READPAK:
#ifdef _DEBUG
            DebugMessage(M64MSG_INFO, "Read pak");
#endif
//            if (controller[Control].control->Plugin == PLUGIN_RAW)
//            {
//                unsigned int dwAddress = (Command[3] << 8) + (Command[4] & 0xE0);
//
//                if(( dwAddress >= 0x8000 ) && ( dwAddress < 0x9000 ) )
//                    memset( Data, 0x80, 32 );
//                else
//                    memset( Data, 0x00, 32 );
//
//                Data[32] = DataCRC( Data, 32 );
//            }
            break;
        case RD_WRITEPAK:
#ifdef _DEBUG
            DebugMessage(M64MSG_INFO, "Write pak");
#endif
//            if (controller[Control].control->Plugin == PLUGIN_RAW)
//            {
//                unsigned int dwAddress = (Command[3] << 8) + (Command[4] & 0xE0);
//              if (dwAddress == PAK_IO_RUMBLE && *Data)
//                    DebugMessage(M64MSG_VERBOSE, "Triggering rumble pack.");
//                Data[32] = DataCRC( Data, 32 );
//            }
            break;
        case RD_RESETCONTROLLER:
#ifdef _DEBUG
            DebugMessage(M64MSG_INFO, "Reset controller");
#endif
            break;
        case RD_READEEPROM:
#ifdef _DEBUG
            DebugMessage(M64MSG_INFO, "Read eeprom");
#endif
            break;
        case RD_WRITEEPROM:
#ifdef _DEBUG
            DebugMessage(M64MSG_INFO, "Write eeprom");
#endif
            break;
        }
}

const int n64joystickRange = 80;

/******************************************************************
  Function: GetKeys
  Purpose:  To get the current state of the controllers buttons.
  input:    - Controller Number (0 to 3)
            - A pointer to a BUTTONS structure to be filled with
            the controller state.
  output:   none
*******************************************************************/
EXPORT void CALL GetKeys( int controllerNumber, BUTTONS *Keys ) {
	
	NSArray * controllers = [[MALMupenEngine shared] controllerBindings];
	
	Keys->Value = 0;
	
	if(controllerNumber < [controllers count]) {
		MALInputDevice * controller = controllers[controllerNumber];
		
		NSArray * buttons = @[@"dpad.right",@"dpad.left",@"dpad.down",@"dpad.up",
						@"start",@"z",@"b",@"a",
						@"c.right",@"c.left",@"c.down",@"c.up",
						@"r",@"l"];
		NSDictionary * el = controller.elements;
		
		for(int button = 0; button < [buttons count]; button++) {
			if([el[buttons[button]] boolValue])
				Keys->Value |= button_bits[button];
		}
//		NSLog(@"%@",el);
		
#define joy(el) @"joy." el
#define CLAMP(x, low, high) MIN(MAX(x,low),high)
		Keys->X_AXIS = n64joystickRange * CLAMP([el[joy(@"right")] floatValue] - [el[joy(@"left")] floatValue],-1,1);
		Keys->Y_AXIS = n64joystickRange * CLAMP([el[joy(   @"up")] floatValue] - [el[joy(@"down")] floatValue],-1,1);
		
#undef joy
	} else {
		Keys->Value = 0;
	}
}

/******************************************************************
  Function: InitiateControllers
  Purpose:  This function initialises how each of the controllers
            should be handled.
  input:    - The handle to the main window.
            - A controller structure that needs to be filled for
              the emulator to know how to handle each controller.
  output:   none
*******************************************************************/
EXPORT void CALL InitiateControllers(CONTROL_INFO ControlInfo)
{
	for(int i=0; i<4; i++) {
		ControlInfo.Controls[i].Present = YES;
	}
}

/******************************************************************
  Function: ReadController
  Purpose:  To process the raw data in the pif ram that is about to
            be read.
  input:    - Controller Number (0 to 3) and -1 signalling end of
              processing the pif ram.
            - Pointer of data to be processed.
  output:   none
  note:     This function is only needed if the DLL is allowing raw
            data.
*******************************************************************/
EXPORT void CALL ReadController(int Control, unsigned char *Command)
{
#ifdef _DEBUG
    if (Command != NULL)
        DebugMessage(M64MSG_INFO, "Raw Read (cont=%d):  %02X %02X %02X %02X %02X %02X", Control,
                     Command[0], Command[1], Command[2], Command[3], Command[4], Command[5]);
#endif
}

/******************************************************************
  Function: RomClosed
  Purpose:  This function is called when a rom is closed.
  input:    none
  output:   none
*******************************************************************/
EXPORT void CALL RomClosed(void)
{
    romopen = 0;
}

/******************************************************************
  Function: RomOpen
  Purpose:  This function is called when a rom is open. (from the
            emulation thread)
  input:    none
  output:   none
*******************************************************************/
EXPORT int CALL RomOpen(void)
{
	if(NO) {
		[[MALInputCenter shared] setInputListener:^(MALInputElement* el) {
			if([[MALInputElement deviceIDFromFullID:el.fullID] isEqualToString:@"Key"]) {
				NSLog(@"%@",el);
				NSLog(@"%@",el->generalDevice);
			}
		}];
	}
    romopen = 1;
    return 1;
}

/******************************************************************
  Function: SDL_KeyDown
  Purpose:  To pass the SDL_KeyDown message from the emulator to the
            plugin.
  input:    keymod and keysym of the SDL_KEYDOWN message.
  output:   none
*******************************************************************/
EXPORT void CALL SDL_KeyDown(int keymod, int keysym)
{
}

/******************************************************************
  Function: SDL_KeyUp
  Purpose:  To pass the SDL_KeyUp message from the emulator to the
            plugin.
  input:    keymod and keysym of the SDL_KEYUP message.
  output:   none
*******************************************************************/
EXPORT void CALL SDL_KeyUp(int keymod, int keysym)
{
}

