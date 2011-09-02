/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *   Mupen64plus-ui-console - core_interface.c                             *
 *   Mupen64Plus homepage: http://code.google.com/p/mupen64plus/           *
 *   Copyright (C) 2009 Richard Goedeken                                   *
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

/* This file contains the routines for attaching to the Mupen64Plus core
 * library and pointers to the core functions
 */

#include <stdio.h>

#include "m64p_types.h"
#include "m64p_common.h"
#include "m64p_frontend.h"
#include "m64p_config.h"
#include "m64p_debugger.h"

#include "osal_preproc.h"
#include "osal_dynamiclib.h"

#include "version.h"

/* global data definitions */
int g_CoreCapabilities;

/* definitions of pointers to Core common functions */
ptr_CoreErrorMessage    CoreErrorMessage = NULL;

/* definitions of pointers to Core front-end functions */
ptr_CoreStartup         CoreStartup = NULL;
ptr_CoreShutdown        CoreShutdown = NULL;
ptr_CoreAttachPlugin    CoreAttachPlugin = NULL;
ptr_CoreDetachPlugin    CoreDetachPlugin = NULL;
ptr_CoreDoCommand       CoreDoCommand = NULL;
ptr_CoreOverrideVidExt  CoreOverrideVidExt = NULL;
ptr_CoreAddCheat        CoreAddCheat = NULL;
ptr_CoreCheatEnabled    CoreCheatEnabled = NULL;
ptr_CoreGetRomSettings  CoreGetRomSettings = NULL;

/* definitions of pointers to Core config functions */
ptr_ConfigListSections     ConfigListSections = NULL;
ptr_ConfigOpenSection      ConfigOpenSection = NULL;
ptr_ConfigListParameters   ConfigListParameters = NULL;
ptr_ConfigSaveFile         ConfigSaveFile = NULL;
ptr_ConfigSetParameter     ConfigSetParameter = NULL;
ptr_ConfigGetParameter     ConfigGetParameter = NULL;
ptr_ConfigGetParameterType ConfigGetParameterType = NULL;
ptr_ConfigGetParameterHelp ConfigGetParameterHelp = NULL;
ptr_ConfigSetDefaultInt    ConfigSetDefaultInt = NULL;
ptr_ConfigSetDefaultFloat  ConfigSetDefaultFloat = NULL;
ptr_ConfigSetDefaultBool   ConfigSetDefaultBool = NULL;
ptr_ConfigSetDefaultString ConfigSetDefaultString = NULL;
ptr_ConfigGetParamInt      ConfigGetParamInt = NULL;
ptr_ConfigGetParamFloat    ConfigGetParamFloat = NULL;
ptr_ConfigGetParamBool     ConfigGetParamBool = NULL;
ptr_ConfigGetParamString   ConfigGetParamString = NULL;

ptr_ConfigGetSharedDataFilepath ConfigGetSharedDataFilepath = NULL;
ptr_ConfigGetUserConfigPath     ConfigGetUserConfigPath = NULL;
ptr_ConfigGetUserDataPath       ConfigGetUserDataPath = NULL;
ptr_ConfigGetUserCachePath      ConfigGetUserCachePath = NULL;

/* definitions of pointers to Core debugger functions */
ptr_DebugSetCallbacks      DebugSetCallbacks = NULL;
ptr_DebugSetCoreCompare    DebugSetCoreCompare = NULL;
ptr_DebugSetRunState       DebugSetRunState = NULL;
ptr_DebugGetState          DebugGetState = NULL;
ptr_DebugStep              DebugStep = NULL;
ptr_DebugDecodeOp          DebugDecodeOp = NULL;
ptr_DebugMemGetRecompInfo  DebugMemGetRecompInfo = NULL;
ptr_DebugMemGetMemInfo     DebugMemGetMemInfo = NULL;
ptr_DebugMemGetPointer     DebugMemGetPointer = NULL;

ptr_DebugMemRead64         DebugMemRead64 = NULL;
ptr_DebugMemRead32         DebugMemRead32 = NULL;
ptr_DebugMemRead16         DebugMemRead16 = NULL;
ptr_DebugMemRead8          DebugMemRead8 = NULL;

ptr_DebugMemWrite64        DebugMemWrite64 = NULL;
ptr_DebugMemWrite32        DebugMemWrite32 = NULL;
ptr_DebugMemWrite16        DebugMemWrite16 = NULL;
ptr_DebugMemWrite8         DebugMemWrite8 = NULL;

ptr_DebugGetCPUDataPtr     DebugGetCPUDataPtr = NULL;
ptr_DebugBreakpointLookup  DebugBreakpointLookup = NULL;
ptr_DebugBreakpointCommand DebugBreakpointCommand = NULL;

/* functions */
m64p_error getCoreFunctionPointers(m64p_dynlib_handle coreHandle) {
	/* get function pointers to the common and front-end functions */
	CoreErrorMessage = (ptr_CoreErrorMessage) osal_dynlib_getproc(coreHandle, "CoreErrorMessage");
	CoreStartup = (ptr_CoreStartup) osal_dynlib_getproc(coreHandle, "CoreStartup");
	CoreShutdown = (ptr_CoreShutdown) osal_dynlib_getproc(coreHandle, "CoreShutdown");
	CoreAttachPlugin = (ptr_CoreAttachPlugin) osal_dynlib_getproc(coreHandle, "CoreAttachPlugin");
	CoreDetachPlugin = (ptr_CoreDetachPlugin) osal_dynlib_getproc(coreHandle, "CoreDetachPlugin");
	CoreDoCommand = (ptr_CoreDoCommand) osal_dynlib_getproc(coreHandle, "CoreDoCommand");
	CoreOverrideVidExt = (ptr_CoreOverrideVidExt) osal_dynlib_getproc(coreHandle, "CoreOverrideVidExt");
	CoreAddCheat = (ptr_CoreAddCheat) osal_dynlib_getproc(coreHandle, "CoreAddCheat");
	CoreCheatEnabled = (ptr_CoreCheatEnabled) osal_dynlib_getproc(coreHandle, "CoreCheatEnabled");
	CoreGetRomSettings = (ptr_CoreGetRomSettings) osal_dynlib_getproc(coreHandle, "CoreGetRomSettings");

	/* get function pointers to the configuration functions */
	ConfigListSections = (ptr_ConfigListSections) osal_dynlib_getproc(coreHandle, "ConfigListSections");
	ConfigOpenSection = (ptr_ConfigOpenSection) osal_dynlib_getproc(coreHandle, "ConfigOpenSection");
	ConfigListParameters = (ptr_ConfigListParameters) osal_dynlib_getproc(coreHandle, "ConfigListParameters");
	ConfigSaveFile = (ptr_ConfigSaveFile) osal_dynlib_getproc(coreHandle, "ConfigSaveFile");
	ConfigSetParameter = (ptr_ConfigSetParameter) osal_dynlib_getproc(coreHandle, "ConfigSetParameter");
	ConfigGetParameter = (ptr_ConfigGetParameter) osal_dynlib_getproc(coreHandle, "ConfigGetParameter");
	ConfigGetParameterType = (ptr_ConfigGetParameterType) osal_dynlib_getproc(coreHandle, "ConfigGetParameterType");
	ConfigGetParameterHelp = (ptr_ConfigGetParameterHelp) osal_dynlib_getproc(coreHandle, "ConfigGetParameterHelp");
	ConfigSetDefaultInt = (ptr_ConfigSetDefaultInt) osal_dynlib_getproc(coreHandle, "ConfigSetDefaultInt");
	ConfigSetDefaultFloat = (ptr_ConfigSetDefaultFloat) osal_dynlib_getproc(coreHandle, "ConfigSetDefaultFloat");
	ConfigSetDefaultBool = (ptr_ConfigSetDefaultBool) osal_dynlib_getproc(coreHandle, "ConfigSetDefaultBool");
	ConfigSetDefaultString = (ptr_ConfigSetDefaultString) osal_dynlib_getproc(coreHandle, "ConfigSetDefaultString");
	ConfigGetParamInt = (ptr_ConfigGetParamInt) osal_dynlib_getproc(coreHandle, "ConfigGetParamInt");
	ConfigGetParamFloat = (ptr_ConfigGetParamFloat) osal_dynlib_getproc(coreHandle, "ConfigGetParamFloat");
	ConfigGetParamBool = (ptr_ConfigGetParamBool) osal_dynlib_getproc(coreHandle, "ConfigGetParamBool");
	ConfigGetParamString = (ptr_ConfigGetParamString) osal_dynlib_getproc(coreHandle, "ConfigGetParamString");

	ConfigGetSharedDataFilepath = (ptr_ConfigGetSharedDataFilepath) osal_dynlib_getproc(coreHandle, "ConfigGetSharedDataFilepath");
	ConfigGetUserConfigPath = (ptr_ConfigGetUserConfigPath) osal_dynlib_getproc(coreHandle, "ConfigGetUserConfigPath");
	ConfigGetUserDataPath = (ptr_ConfigGetUserDataPath) osal_dynlib_getproc(coreHandle, "ConfigGetUserDataPath");
	ConfigGetUserCachePath = (ptr_ConfigGetUserCachePath) osal_dynlib_getproc(coreHandle, "ConfigGetUserCachePath");

	/* get function pointers to the debugger functions */
	DebugSetCallbacks = (ptr_DebugSetCallbacks) osal_dynlib_getproc(coreHandle, "DebugSetCallbacks");
	DebugSetCoreCompare = (ptr_DebugSetCoreCompare) osal_dynlib_getproc(coreHandle, "DebugSetCoreCompare");
	DebugSetRunState = (ptr_DebugSetRunState) osal_dynlib_getproc(coreHandle, "DebugSetRunState");
	DebugGetState = (ptr_DebugGetState) osal_dynlib_getproc(coreHandle, "DebugGetState");
	DebugStep = (ptr_DebugStep) osal_dynlib_getproc(coreHandle, "DebugStep");
	DebugDecodeOp = (ptr_DebugDecodeOp) osal_dynlib_getproc(coreHandle, "DebugDecodeOp");
	DebugMemGetRecompInfo = (ptr_DebugMemGetRecompInfo) osal_dynlib_getproc(coreHandle, "DebugMemGetRecompInfo");
	DebugMemGetMemInfo = (ptr_DebugMemGetMemInfo) osal_dynlib_getproc(coreHandle, "DebugMemGetMemInfo");
	DebugMemGetPointer = (ptr_DebugMemGetPointer) osal_dynlib_getproc(coreHandle, "DebugMemGetPointer");

	DebugMemRead64 = (ptr_DebugMemRead64) osal_dynlib_getproc(coreHandle, "DebugMemRead64");
	DebugMemRead32 = (ptr_DebugMemRead32) osal_dynlib_getproc(coreHandle, "DebugMemRead32");
	DebugMemRead16 = (ptr_DebugMemRead16) osal_dynlib_getproc(coreHandle, "DebugMemRead16");
	DebugMemRead8 = (ptr_DebugMemRead8) osal_dynlib_getproc(coreHandle, "DebugMemRead8");

	DebugMemWrite64 = (ptr_DebugMemWrite64) osal_dynlib_getproc(coreHandle, "DebugMemRead64");
	DebugMemWrite32 = (ptr_DebugMemWrite32) osal_dynlib_getproc(coreHandle, "DebugMemRead32");
	DebugMemWrite16 = (ptr_DebugMemWrite16) osal_dynlib_getproc(coreHandle, "DebugMemRead16");
	DebugMemWrite8 = (ptr_DebugMemWrite8) osal_dynlib_getproc(coreHandle, "DebugMemRead8");

	DebugGetCPUDataPtr = (ptr_DebugGetCPUDataPtr) osal_dynlib_getproc(coreHandle, "DebugGetCPUDataPtr");
	DebugBreakpointLookup = (ptr_DebugBreakpointLookup) osal_dynlib_getproc(coreHandle, "DebugBreakpointLookup");
	DebugBreakpointCommand = (ptr_DebugBreakpointCommand) osal_dynlib_getproc(coreHandle, "DebugBreakpointCommand");

	return M64ERR_SUCCESS;
}

m64p_error zeroCoreFunctionPointers(void) {
	/* set the core function pointers to NULL */
	CoreErrorMessage = NULL;
	CoreStartup = NULL;
	CoreShutdown = NULL;
	CoreAttachPlugin = NULL;
	CoreDetachPlugin = NULL;
	CoreDoCommand = NULL;
	CoreOverrideVidExt = NULL;
	CoreAddCheat = NULL;
	CoreCheatEnabled = NULL;
	CoreGetRomSettings = NULL;

	ConfigListSections = NULL;
	ConfigOpenSection = NULL;
	ConfigListParameters = NULL;
	ConfigSetParameter = NULL;
	ConfigGetParameter = NULL;
	ConfigGetParameterType = NULL;
	ConfigGetParameterHelp = NULL;
	ConfigSetDefaultInt = NULL;
	ConfigSetDefaultBool = NULL;
	ConfigSetDefaultString = NULL;
	ConfigGetParamInt = NULL;
	ConfigGetParamBool = NULL;
	ConfigGetParamString = NULL;

	ConfigGetSharedDataFilepath = NULL;
	ConfigGetUserDataPath = NULL;
	ConfigGetUserCachePath = NULL;

	DebugSetCallbacks = NULL;
	DebugSetCoreCompare = NULL;
	DebugSetRunState = NULL;
	DebugGetState = NULL;
	DebugStep = NULL;
	DebugDecodeOp = NULL;
	DebugMemGetRecompInfo = NULL;
	DebugMemGetMemInfo = NULL;
	DebugMemGetPointer = NULL;

	DebugMemRead64 = NULL;
	DebugMemRead32 = NULL;
	DebugMemRead16 = NULL;
	DebugMemRead8 = NULL;

	DebugMemWrite64 = NULL;
	DebugMemWrite32 = NULL;
	DebugMemWrite16 = NULL;
	DebugMemWrite8 = NULL;

	DebugGetCPUDataPtr = NULL;
	DebugBreakpointLookup = NULL;
	DebugBreakpointCommand = NULL;

	return M64ERR_SUCCESS;
}


