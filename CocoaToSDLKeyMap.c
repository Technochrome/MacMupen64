#include "CocoaToSDLKeyMap.h"

/* These are the Macintosh key scancode constants -- from Inside Macintosh */
#define MK_ESCAPE		0x35
#define MK_F1			0x7A
#define MK_F2			0x78
#define MK_F3			0x63
#define MK_F4			0x76
#define MK_F5			0x60
#define MK_F6			0x61
#define MK_F7			0x62
#define MK_F8			0x64
#define MK_F9			0x65
#define MK_F10			0x6D
#define MK_F11			0x67
#define MK_F12			0x6F
#define MK_PRINT		0x69
#define MK_SCROLLOCK		0x6B
#define MK_PAUSE		0x71
#define MK_POWER		0x7F
#define MK_BACKQUOTE		0x32
#define MK_1			0x12
#define MK_2			0x13
#define MK_3			0x14
#define MK_4			0x15
#define MK_5			0x17
#define MK_6			0x16
#define MK_7			0x1A
#define MK_8			0x1C
#define MK_9			0x19
#define MK_0			0x1D
#define MK_MINUS		0x1B
#define MK_EQUALS		0x18
#define MK_BACKSPACE		0x33
#define MK_INSERT		0x72
#define MK_HOME			0x73
#define MK_PAGEUP		0x74
#define MK_NUMLOCK		0x47
#define MK_KP_EQUALS		0x51
#define MK_KP_DIVIDE		0x4B
#define MK_KP_MULTIPLY		0x43
#define MK_TAB			0x30
#define MK_q			0x0C
#define MK_w			0x0D
#define MK_e			0x0E
#define MK_r			0x0F
#define MK_t			0x11
#define MK_y			0x10
#define MK_u			0x20
#define MK_i			0x22
#define MK_o			0x1F
#define MK_p			0x23
#define MK_LEFTBRACKET		0x21
#define MK_RIGHTBRACKET		0x1E
#define MK_BACKSLASH		0x2A
#define MK_DELETE		0x75
#define MK_END			0x77
#define MK_PAGEDOWN		0x79
#define MK_KP7			0x59
#define MK_KP8			0x5B
#define MK_KP9			0x5C
#define MK_KP_MINUS		0x4E
#define MK_CAPSLOCK		0x39
#define MK_a			0x00
#define MK_s			0x01
#define MK_d			0x02
#define MK_f			0x03
#define MK_g			0x05
#define MK_h			0x04
#define MK_j			0x26
#define MK_k			0x28
#define MK_l			0x25
#define MK_SEMICOLON		0x29
#define MK_QUOTE		0x27
#define MK_RETURN		0x24
#define MK_KP4			0x56
#define MK_KP5			0x57
#define MK_KP6			0x58
#define MK_KP_PLUS		0x45
#define MK_LSHIFT		0x38
#define MK_z			0x06
#define MK_x			0x07
#define MK_c			0x08
#define MK_v			0x09
#define MK_b			0x0B
#define MK_n			0x2D
#define MK_m			0x2E
#define MK_COMMA		0x2B
#define MK_PERIOD		0x2F
#define MK_SLASH		0x2C
#if 0	/* These are the same as the left versions - use left by default */
#define MK_RSHIFT		0x38
#endif
#define MK_UP			0x7E
#define MK_KP1			0x53
#define MK_KP2			0x54
#define MK_KP3			0x55
#define MK_KP_ENTER		0x4C
#define MK_LCTRL		0x3B
#define MK_LALT			0x3A
#define MK_LMETA		0x37
#define MK_SPACE		0x31
#if 0	/* These are the same as the left versions - use left by default */
#define MK_RMETA		0x37
#define MK_RALT			0x3A
#define MK_RCTRL		0x3B
#endif
#define MK_LEFT			0x7B
#define MK_DOWN			0x7D
#define MK_RIGHT		0x7C
#define MK_KP0			0x52
#define MK_KP_PERIOD		0x41

/* Wierd, these keys are on my iBook under Mac OS X */
#define MK_IBOOK_ENTER		0x34
#define MK_IBOOK_LEFT		0x3B
#define MK_IBOOK_RIGHT		0x3C
#define MK_IBOOK_DOWN		0x3D
#define MK_IBOOK_UP		0x3E

SDLKey MAC_keymap[256];
int initialized = 0;

void initSDLKeyMap() {
	if(initialized == 1) return;
	
	/* Map the MAC keysyms */
	for (int i=0; i<SDL_arraysize(MAC_keymap); ++i )
		MAC_keymap[i] = SDLK_UNKNOWN;
		
	/* Defined MAC_* constants */
	MAC_keymap[MK_ESCAPE] = SDLK_ESCAPE;
	MAC_keymap[MK_F1] = SDLK_F1;
	MAC_keymap[MK_F2] = SDLK_F2;
	MAC_keymap[MK_F3] = SDLK_F3;
	MAC_keymap[MK_F4] = SDLK_F4;
	MAC_keymap[MK_F5] = SDLK_F5;
	MAC_keymap[MK_F6] = SDLK_F6;
	MAC_keymap[MK_F7] = SDLK_F7;
	MAC_keymap[MK_F8] = SDLK_F8;
	MAC_keymap[MK_F9] = SDLK_F9;
	MAC_keymap[MK_F10] = SDLK_F10;
	MAC_keymap[MK_F11] = SDLK_F11;
	MAC_keymap[MK_F12] = SDLK_F12;
	MAC_keymap[MK_PRINT] = SDLK_PRINT;
	MAC_keymap[MK_SCROLLOCK] = SDLK_SCROLLOCK;
	MAC_keymap[MK_PAUSE] = SDLK_PAUSE;
	MAC_keymap[MK_POWER] = SDLK_POWER;
	MAC_keymap[MK_BACKQUOTE] = SDLK_BACKQUOTE;
	MAC_keymap[MK_1] = SDLK_1;
	MAC_keymap[MK_2] = SDLK_2;
	MAC_keymap[MK_3] = SDLK_3;
	MAC_keymap[MK_4] = SDLK_4;
	MAC_keymap[MK_5] = SDLK_5;
	MAC_keymap[MK_6] = SDLK_6;
	MAC_keymap[MK_7] = SDLK_7;
	MAC_keymap[MK_8] = SDLK_8;
	MAC_keymap[MK_9] = SDLK_9;
	MAC_keymap[MK_0] = SDLK_0;
	MAC_keymap[MK_MINUS] = SDLK_MINUS;
	MAC_keymap[MK_EQUALS] = SDLK_EQUALS;
	MAC_keymap[MK_BACKSPACE] = SDLK_BACKSPACE;
	MAC_keymap[MK_INSERT] = SDLK_INSERT;
	MAC_keymap[MK_HOME] = SDLK_HOME;
	MAC_keymap[MK_PAGEUP] = SDLK_PAGEUP;
	MAC_keymap[MK_NUMLOCK] = SDLK_NUMLOCK;
	MAC_keymap[MK_KP_EQUALS] = SDLK_KP_EQUALS;
	MAC_keymap[MK_KP_DIVIDE] = SDLK_KP_DIVIDE;
	MAC_keymap[MK_KP_MULTIPLY] = SDLK_KP_MULTIPLY;
	MAC_keymap[MK_TAB] = SDLK_TAB;
	MAC_keymap[MK_q] = SDLK_q;
	MAC_keymap[MK_w] = SDLK_w;
	MAC_keymap[MK_e] = SDLK_e;
	MAC_keymap[MK_r] = SDLK_r;
	MAC_keymap[MK_t] = SDLK_t;
	MAC_keymap[MK_y] = SDLK_y;
	MAC_keymap[MK_u] = SDLK_u;
	MAC_keymap[MK_i] = SDLK_i;
	MAC_keymap[MK_o] = SDLK_o;
	MAC_keymap[MK_p] = SDLK_p;
	MAC_keymap[MK_LEFTBRACKET] = SDLK_LEFTBRACKET;
	MAC_keymap[MK_RIGHTBRACKET] = SDLK_RIGHTBRACKET;
	MAC_keymap[MK_BACKSLASH] = SDLK_BACKSLASH;
	MAC_keymap[MK_DELETE] = SDLK_DELETE;
	MAC_keymap[MK_END] = SDLK_END;
	MAC_keymap[MK_PAGEDOWN] = SDLK_PAGEDOWN;
	MAC_keymap[MK_KP7] = SDLK_KP7;
	MAC_keymap[MK_KP8] = SDLK_KP8;
	MAC_keymap[MK_KP9] = SDLK_KP9;
	MAC_keymap[MK_KP_MINUS] = SDLK_KP_MINUS;
	MAC_keymap[MK_CAPSLOCK] = SDLK_CAPSLOCK;
	MAC_keymap[MK_a] = SDLK_a;
	MAC_keymap[MK_s] = SDLK_s;
	MAC_keymap[MK_d] = SDLK_d;
	MAC_keymap[MK_f] = SDLK_f;
	MAC_keymap[MK_g] = SDLK_g;
	MAC_keymap[MK_h] = SDLK_h;
	MAC_keymap[MK_j] = SDLK_j;
	MAC_keymap[MK_k] = SDLK_k;
	MAC_keymap[MK_l] = SDLK_l;
	MAC_keymap[MK_SEMICOLON] = SDLK_SEMICOLON;
	MAC_keymap[MK_QUOTE] = SDLK_QUOTE;
	MAC_keymap[MK_RETURN] = SDLK_RETURN;
	MAC_keymap[MK_KP4] = SDLK_KP4;
	MAC_keymap[MK_KP5] = SDLK_KP5;
	MAC_keymap[MK_KP6] = SDLK_KP6;
	MAC_keymap[MK_KP_PLUS] = SDLK_KP_PLUS;
	MAC_keymap[MK_LSHIFT] = SDLK_LSHIFT;
	MAC_keymap[MK_z] = SDLK_z;
	MAC_keymap[MK_x] = SDLK_x;
	MAC_keymap[MK_c] = SDLK_c;
	MAC_keymap[MK_v] = SDLK_v;
	MAC_keymap[MK_b] = SDLK_b;
	MAC_keymap[MK_n] = SDLK_n;
	MAC_keymap[MK_m] = SDLK_m;
	MAC_keymap[MK_COMMA] = SDLK_COMMA;
	MAC_keymap[MK_PERIOD] = SDLK_PERIOD;
	MAC_keymap[MK_SLASH] = SDLK_SLASH;
	MAC_keymap[MK_UP] = SDLK_UP;
	MAC_keymap[MK_KP1] = SDLK_KP1;
	MAC_keymap[MK_KP2] = SDLK_KP2;
	MAC_keymap[MK_KP3] = SDLK_KP3;
	MAC_keymap[MK_KP_ENTER] = SDLK_KP_ENTER;
	MAC_keymap[MK_LCTRL] = SDLK_LCTRL;
	MAC_keymap[MK_LALT] = SDLK_LALT;
	MAC_keymap[MK_LMETA] = SDLK_LMETA;
	MAC_keymap[MK_SPACE] = SDLK_SPACE;
	MAC_keymap[MK_LEFT] = SDLK_LEFT;
	MAC_keymap[MK_DOWN] = SDLK_DOWN;
	MAC_keymap[MK_RIGHT] = SDLK_RIGHT;
	MAC_keymap[MK_KP0] = SDLK_KP0;
	MAC_keymap[MK_KP_PERIOD] = SDLK_KP_PERIOD;
	
	initialized = 1;
}