/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *   Mupen64plus-ui-console - main.c                                       *
 *   Mupen64Plus homepage: http://code.google.com/p/mupen64plus/           *
 *   Copyright (C) 2007-2009 Richard42                                     *
 *   Copyright (C) 2008 Ebenblues Nmn Okaygo Tillin9                       *
 *   Copyright (C) 2002 Hacktarux                                          *
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

/* This is the main application entry point for the console-only front-end
 * for Mupen64Plus v2.0. 
 */
 
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// The mac version of SDL requires inclusion of SDL_main in the executable
#ifdef __APPLE__
#include <SDL/SDL_main.h>
#endif

#include "cheat.h"
#include "main.h"
#include "version.h"
#include "core_interface.h"
#include "compare_core.h"
#include "osal_preproc.h"

#import "videoExtension.h"
#import "MALMupenCore.h"
#import "OBJprintf.h"

/** global variables **/
int    g_Verbose = 0;

/** static (local) variables **/
static m64p_handle l_ConfigCore = NULL;
static m64p_handle l_ConfigVideo = NULL;
static m64p_handle l_ConfigUI = NULL;

static const char *l_CoreLibPath = NULL;
static const char *l_ConfigDirPath = NULL;

#if defined(SHAREDIR)
  static const char *l_DataDirPath = SHAREDIR;
#else
  static const char *l_DataDirPath = NULL;
#endif

static int  *l_TestShotList = NULL;      // list of screenshots to take for regression test support
static int   l_TestShotIdx = 0;          // index of next screenshot frame in list
static int   l_SaveOptions = 0;          // save command-line options in configuration file
static int   l_CoreCompareMode = 0;      // 0 = disable, 1 = send, 2 = receive

static eCheatMode l_CheatMode = CHEAT_DISABLE;
static int       *l_CheatNumList = NULL;
static int        l_CheatListLength = 0;

/*********************************************************************************************************
 *  Callback functions from the core
 */

void DebugCallback(void *Context, int level, const char *message)
{
	if (level <= 1)
		OBJprintf(@"%@ Error: %s\n", (NSString *) Context, message);
	else if (level == 2)
		OBJprintf(@"%@ Warning: %s\n", (NSString *) Context, message);
//	else if (level == 3 || (level == 5 && g_Verbose))
//		OBJprintf(@"%@: %s\n", (NSString *) Context, message);
//	else if (level == 4)
//		OBJprintf(@"%@ Status: %s\n", (NSString *) Context, message);
}

static m64p_error OpenConfigurationHandles(void)
{
    m64p_error rval;

    /* Open Configuration sections for core library and console User Interface */
    rval = (*ConfigOpenSection)("Core", &l_ConfigCore);
    if (rval != M64ERR_SUCCESS)
    {
        fprintf(stderr, "Error: failed to open 'Core' configuration section\n");
        return rval;
    }

    rval = (*ConfigOpenSection)("Video-General", &l_ConfigVideo);
    if (rval != M64ERR_SUCCESS)
    {
        fprintf(stderr, "Error: failed to open 'Video-General' configuration section\n");
        return rval;
    }

    rval = (*ConfigOpenSection)("UI-Console", &l_ConfigUI);
    if (rval != M64ERR_SUCCESS)
    {
        fprintf(stderr, "Error: failed to open 'UI-Console' configuration section\n");
        return rval;
    }

    /* Set default values for my Config parameters */
    (*ConfigSetDefaultString)(l_ConfigUI, "PluginDir", OSAL_CURRENT_DIR, "Directory in which to search for plugins");
    (*ConfigSetDefaultString)(l_ConfigUI, "VideoPlugin", "m64p_video_rice" OSAL_DLL_EXTENSION, "Filename of video plugin");
    (*ConfigSetDefaultString)(l_ConfigUI, "AudioPlugin", "m64p_audio_jttl" OSAL_DLL_EXTENSION, "Filename of audio plugin");
    (*ConfigSetDefaultString)(l_ConfigUI, "InputPlugin", "m64p_input_blight" OSAL_DLL_EXTENSION, "Filename of input plugin");
    (*ConfigSetDefaultString)(l_ConfigUI, "RspPlugin", "m64p_rsp_hle" OSAL_DLL_EXTENSION, "Filename of RSP plugin");

    return M64ERR_SUCCESS;
}

static m64p_error SaveConfigurationOptions(void)
{
    /* if shared data directory was given on the command line, write it into the config file */
    if (l_DataDirPath != NULL)
        (*ConfigSetParameter)(l_ConfigCore, "SharedDataPath", M64TYPE_STRING, l_DataDirPath);

    /* if any plugin filepaths were given on the command line, write them into the config file */
/*    if (g_PluginDir != NULL)
        (*ConfigSetParameter)(l_ConfigUI, "PluginDir", M64TYPE_STRING, g_PluginDir);
    if (g_GfxPlugin != NULL)
        (*ConfigSetParameter)(l_ConfigUI, "VideoPlugin", M64TYPE_STRING, g_GfxPlugin);
    if (g_AudioPlugin != NULL)
        (*ConfigSetParameter)(l_ConfigUI, "AudioPlugin", M64TYPE_STRING, g_AudioPlugin);
    if (g_InputPlugin != NULL)
        (*ConfigSetParameter)(l_ConfigUI, "InputPlugin", M64TYPE_STRING, g_InputPlugin);
    if (g_RspPlugin != NULL)
        (*ConfigSetParameter)(l_ConfigUI, "RspPlugin", M64TYPE_STRING, g_RspPlugin);
*/
    return (*ConfigSaveFile)();
}

/*********************************************************************************************************
 *  Command-line parsing
 */

static void printUsage(const char *progname)
{
    printf("Usage: %s [parameters] [romfile]\n"
           "\n"
           "Parameters:\n"
           "    --noosd               : disable onscreen display\n"
           "    --osd                 : enable onscreen display\n"
           "    --fullscreen          : use fullscreen display mode\n"
           "    --windowed            : use windowed display mode\n"
           "    --resolution (res)    : display resolution (640x480, 800x600, 1024x768, etc)\n"
           "    --cheats (cheat-spec) : enable or list cheat codes for the given rom file\n"
           "    --corelib (filepath)  : use core library (filepath) (can be only filename or full path)\n"
           "    --configdir (dir)     : force configation directory to (dir); should contain mupen64plus.conf\n"
           "    --datadir (dir)       : search for shared data files (.ini files, languages, etc) in (dir)\n"
           "    --sshotdir (dir)      : set screenshot directory to (dir)\n"
           "    --emumode (mode)      : set emu mode to: 0=Pure Interpreter 1=Interpreter 2=DynaRec\n"
           "    --testshots (list)    : take screenshots at frames given in comma-separated (list), then quit\n"
           "    --set (param-spec)    : set a configuration variable, format: ParamSection[ParamName]=Value\n"
           "    --core-compare-send   : use the Core Comparison debugging feature, in data sending mode\n"
           "    --core-compare-recv   : use the Core Comparison debugging feature, in data receiving mode\n"
           "    --saveoptions         : save the given command-line options in configuration file for future\n"
           "    --verbose             : print lots of information\n"
           "    --help                : see this help message\n\n"
           "(cheat-spec):\n"
           "    'list'                : show all of the available cheat codes\n"
           "    'all'                 : enable all of the available cheat codes\n"
           "    (codelist)            : a comma-separated list of cheat code numbers to enable\n"
           "\n", progname);

    return;
}

static int SetConfigParameter(const char *ParamSpec)
{
    char *ParsedString, *VarName, *VarValue;
    m64p_handle ConfigSection;
    m64p_type VarType;
    m64p_error rval;

    if (ParamSpec == NULL)
    {
        fprintf(stderr, "UI-Console Error: ParamSpec is NULL in SetConfigParameter()\n");
        return 1;
    }

    /* make a copy of the input string */
    ParsedString = (char *) malloc(strlen(ParamSpec) + 1);
    if (ParsedString == NULL)
    {
        fprintf(stderr, "UI-Console Error: SetConfigParameter() couldn't allocate memory for temporary string.\n");
        return 2;
    }
    strcpy(ParsedString, ParamSpec);

    /* parse it for the simple section[name]=value format */
    VarName = strchr(ParsedString, '[');
    if (VarName != NULL)
    {
        *VarName++ = 0;
        VarValue = strchr(VarName, ']');
        if (VarValue != NULL)
        {
            *VarValue++ = 0;
        }
    }
    if (VarName == NULL || VarValue == NULL || *VarValue != '=')
    {
        fprintf(stderr, "UI-Console Error: invalid (param-spec) '%s'\n", ParamSpec);
        free(ParsedString);
        return 3;
    }
    VarValue++;

    /* then set the value */
    rval = (*ConfigOpenSection)(ParsedString, &ConfigSection);
    if (rval != M64ERR_SUCCESS)
    {
        fprintf(stderr, "UI-Console Error: SetConfigParameter failed to open config section '%s'\n", ParsedString);
        free(ParsedString);
        return 4;
    }
    if ((*ConfigGetParameterType)(ConfigSection, VarName, &VarType) == M64ERR_SUCCESS)
    {
        switch(VarType)
        {
            int ValueInt;
            float ValueFloat;
            case M64TYPE_INT:
                ValueInt = atoi(VarValue);
                ConfigSetParameter(ConfigSection, VarName, M64TYPE_INT, &ValueInt);
                break;
            case M64TYPE_FLOAT:
                ValueFloat = (float) atof(VarValue);
                ConfigSetParameter(ConfigSection, VarName, M64TYPE_FLOAT, &ValueFloat);
                break;
            case M64TYPE_BOOL:
                ValueInt = (int) (osal_insensitive_strcmp(VarValue, "true") == 0);
                ConfigSetParameter(ConfigSection, VarName, M64TYPE_BOOL, &ValueInt);
                break;
            case M64TYPE_STRING:
                ConfigSetParameter(ConfigSection, VarName, M64TYPE_STRING, VarValue);
                break;
            default:
                fprintf(stderr, "UI-Console Error: invalid VarType in SetConfigParameter()\n");
                return 5;
        }
    }
    else
    {
        ConfigSetParameter(ConfigSection, VarName, M64TYPE_STRING, VarValue);
    }

    free(ParsedString);
    return 0;
}

static int *ParseNumberList(const char *InputString, int *ValuesFound)
{
    const char *str;
    int *OutputList;

    /* count the number of integers in the list */
    int values = 1;
    str = InputString;
    while ((str = strchr(str, ',')) != NULL)
    {
        str++;
        values++;
    }

    /* create a list and populate it with the frame counter values at which to take screenshots */
    if ((OutputList = (int *) malloc(sizeof(int) * (values + 1))) != NULL)
    {
        int idx = 0;
        str = InputString;
        while (str != NULL)
        {
            OutputList[idx++] = atoi(str);
            str = strchr(str, ',');
            if (str != NULL) str++;
        }
        OutputList[idx] = 0;
    }

    if (ValuesFound != NULL)
        *ValuesFound = values;
    return OutputList;
}

static int ParseCommandLineInitial(int argc, const char **argv)
{
    int i;

    /* look through commandline options */
    for (i = 1; i < argc; i++)
    {
        int ArgsLeft = argc - i - 1;

        if (strcmp(argv[i], "--corelib") == 0 && ArgsLeft >= 1)
        {
            l_CoreLibPath = argv[i+1];
            i++;
        }
        else if (strcmp(argv[i], "--configdir") == 0 && ArgsLeft >= 1)
        {
            l_ConfigDirPath = argv[i+1];
            i++;
        }
        else if (strcmp(argv[i], "--datadir") == 0 && ArgsLeft >= 1)
        {
            l_DataDirPath = argv[i+1];
            i++;
        }
        else if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0)
        {
            printUsage(argv[0]);
            return 1;
        }
    }

    return 0;
}

static m64p_error ParseCommandLineFinal(int argc, const char **argv)
{
    int i;

    /* parse commandline options */
    for (i = 1; i < argc; i++)
    {
        int ArgsLeft = argc - i - 1;
        if (strcmp(argv[i], "--noosd") == 0)
        {
            int Osd = 0;
            (*ConfigSetParameter)(l_ConfigCore, "OnScreenDisplay", M64TYPE_BOOL, &Osd);
        }
        else if (strcmp(argv[i], "--osd") == 0)
        {
            int Osd = 1;
            (*ConfigSetParameter)(l_ConfigCore, "OnScreenDisplay", M64TYPE_BOOL, &Osd);
        }
        else if (strcmp(argv[i], "--fullscreen") == 0)
        {
            int Fullscreen = 1;
            (*ConfigSetParameter)(l_ConfigVideo, "Fullscreen", M64TYPE_BOOL, &Fullscreen);
        }
        else if (strcmp(argv[i], "--windowed") == 0)
        {
            int Fullscreen = 0;
            (*ConfigSetParameter)(l_ConfigVideo, "Fullscreen", M64TYPE_BOOL, &Fullscreen);
        }
        else if ((strcmp(argv[i], "--corelib") == 0 || strcmp(argv[i], "--configdir") == 0 ||
                  strcmp(argv[i], "--datadir") == 0) && ArgsLeft >= 1)
        {   /* these are handled in ParseCommandLineInitial */
            i++;
        }
        else if (strcmp(argv[i], "--resolution") == 0 && ArgsLeft >= 1)
        {
            const char *res = argv[i+1];
            int xres, yres;
            i++;
            if (sscanf(res, "%ix%i", &xres, &yres) != 2)
                fprintf(stderr, "Warning: couldn't parse resolution '%s'\n", res);
            else
            {
                (*ConfigSetParameter)(l_ConfigVideo, "ScreenWidth", M64TYPE_INT, &xres);
                (*ConfigSetParameter)(l_ConfigVideo, "ScreenHeight", M64TYPE_INT, &yres);
            }
        }
        else if (strcmp(argv[i], "--cheats") == 0 && ArgsLeft >= 1)
        {
            if (strcmp(argv[i+1], "all") == 0)
                l_CheatMode = CHEAT_ALL;
            else if (strcmp(argv[i+1], "list") == 0)
                l_CheatMode = CHEAT_SHOW_LIST;
            else
            {
                l_CheatMode = CHEAT_LIST;
                l_CheatNumList = ParseNumberList(argv[i+1], &l_CheatListLength);
            }
            i++;
        }
        else if (strcmp(argv[i], "--sshotdir") == 0 && ArgsLeft >= 1)
        {
            (*ConfigSetParameter)(l_ConfigCore, "ScreenshotPath", M64TYPE_STRING, argv[i+1]);
            i++;
        }
        else if (strcmp(argv[i], "--emumode") == 0 && ArgsLeft >= 1)
        {
            int emumode = atoi(argv[i+1]);
            (*ConfigSetParameter)(l_ConfigCore, "R4300Emulator", M64TYPE_INT, &emumode);
            i++;
        }
        else if (strcmp(argv[i], "--testshots") == 0 && ArgsLeft >= 1)
        {
            l_TestShotList = ParseNumberList(argv[i+1], NULL);
            i++;
        }
        else if (strcmp(argv[i], "--set") == 0 && ArgsLeft >= 1)
        {
            if (SetConfigParameter(argv[i+1]) != 0)
                return M64ERR_INPUT_INVALID;
            i++;
        }
        else if (strcmp(argv[i], "--core-compare-send") == 0)
        {
            l_CoreCompareMode = 1;
        }
        else if (strcmp(argv[i], "--core-compare-recv") == 0)
        {
            l_CoreCompareMode = 2;
        }
        else if (strcmp(argv[i], "--saveoptions") == 0)
        {
            l_SaveOptions = 1;
        }
        else if (strcmp(argv[i], "--verbose") == 0)
        {
            g_Verbose = 1;
        }
        else
        {
            fprintf(stderr, "Warning: unrecognized command-line parameter '%s'\n", argv[i]);
        }
        /* continue argv loop */
    }

    return M64ERR_SUCCESS;
}

void paramList(m64p_handle* null, const char*name, m64p_type type) {
//	if(type==4) NSLog(@"%s (%s)",name,(*ConfigGetParamString)(*null,name));
}

void configCallback(void* null, const char * SectionName) {
//	NSLog(@"%s",SectionName);
	m64p_handle ConfigSectionHandle;
	
	(*ConfigOpenSection)(SectionName, &ConfigSectionHandle);
	(*ConfigSetParameter)(ConfigSectionHandle, "A Button", M64TYPE_STRING, "key(116)");
	if(strcmp(SectionName, "Input-SDL-Control1")==0)
		(*ConfigListParameters)(ConfigSectionHandle, &ConfigSectionHandle, paramList);
}

int TestOtherMain() {
	m64p_error rval;
	
	/* Open configuration sections */
	rval = OpenConfigurationHandles();
	if (rval != M64ERR_SUCCESS)
	{
		return 4;
	}
//	(*ConfigSetParameter)(l_ConfigCore, "ScreenshotPath", M64TYPE_STRING, "/Users/rovolo/Desktop/");

	/* Handle the core comparison feature */
	if (l_CoreCompareMode != 0 && !(g_CoreCapabilities & M64CAPS_CORE_COMPARE))
	{
		printf("UI-console: can't use --core-compare feature with this Mupen64Plus core library.\n");
		return 6;
	}
	compare_core_init(l_CoreCompareMode);

	/* save the given command-line options in configuration file if requested */
	if (l_SaveOptions)
		SaveConfigurationOptions();
	

	/* handle the cheat codes */
	CheatStart(l_CheatMode, l_CheatNumList, l_CheatListLength);
	if (l_CheatMode == CHEAT_SHOW_LIST)
	{
		(*CoreDoCommand)(M64CMD_ROM_CLOSE, 0, NULL);
		return 11;
	}


	(*CoreOverrideVidExt)(&extensionFunctions);
	
	/* run the game */
	(*CoreDoCommand)(M64CMD_EXECUTE, 0, NULL);
	

	/* close the ROM image */
//	(*CoreDoCommand)(M64CMD_ROM_CLOSE, 0, NULL);
	

	/* save the configuration file again if --saveoptions was specified, to keep any updated parameters from the core/plugins */
	if (l_SaveOptions)
		SaveConfigurationOptions();

	/* free allocated memory */
	if (l_TestShotList != NULL)
		free(l_TestShotList);
	if (l_CheatNumList != NULL)
		free(l_CheatNumList);
	
	return 0;
}

