/*
COMPILE OPTIONS
*/

#pragma semicolon 1
#pragma newdecls required

/*
INCLUDES
*/

#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <lololib>

/*
PLUGIN INFO
*/

public Plugin myinfo = 
{
	name			= "Admin commands",
	author			= "Flexlolo",
	description		= "Life-saving admin features",
	version			= "1.0.0",
	url				= "github.com/Flexlolo/"
}

/*
GLOBAL VARIABLES
*/

#define CONSOLE_SM 		"[SM]"
#define CONSOLE_NAME 	"Server"

#define CHAT_SM 		"\x01[SM]"
#define CHAT_SUCCESS 	"\x01"
#define CHAT_ERROR 		"\x01"
#define CHAT_VALUE 		"\x01"


#define INCLUDE_TEAM
#define INCLUDE_HEALTH
#define INCLUDE_GOD
#define INCLUDE_RESPAWN
#define INCLUDE_RRR
#define INCLUDE_RRM
#define INCLUDE_EXTEND
#define INCLUDE_TIMELEFT
#define INCLUDE_GIVE

/*
NATIVES AND FORWARDS
*/

public void OnPluginStart()
{
	// Check game
	char sGame[64];
	GetGameFolderName(sGame, sizeof(sGame));
	if (!StrEqual(sGame, "cstrike")) SetFailState("This game is not supported.");
	
	// Commands
	#if defined INCLUDE_TEAM
	RegAdminCmd("sm_team", 			Command_Team, 			ADMFLAG_BAN, 				"Change player team");
	#endif

	#if defined INCLUDE_HEALTH
	RegAdminCmd("sm_hp", 			Command_Health, 		ADMFLAG_BAN, 				"Change health");
	RegAdminCmd("sm_health", 		Command_Health, 		ADMFLAG_BAN, 				"Change health");
	#endif

	#if defined INCLUDE_GOD
	RegAdminCmd("sm_god", 			Command_God, 			ADMFLAG_BAN, 				"Change godmode");
	RegAdminCmd("sm_godmode", 		Command_God, 			ADMFLAG_BAN, 				"Change godmode");
	#endif

	#if defined INCLUDE_RESPAWN
	RegAdminCmd("sm_respawn", 		Command_Respawn, 		ADMFLAG_BAN, 				"Respawn player");
	#endif

	#if defined INCLUDE_RRR
	RegAdminCmd("sm_rrr", 			Command_RRR, 			ADMFLAG_CHANGEMAP, 			"Round restart");
	#endif

	#if defined INCLUDE_RRM
	RegAdminCmd("sm_rrm", 			Command_RRM, 			ADMFLAG_CHANGEMAP, 			"Map restart");
	#endif

	#if defined INCLUDE_EXTEND
	RegAdminCmd("sm_extend", 		Command_Extend, 		ADMFLAG_CHANGEMAP, 			"Map extend");
	#endif

	#if defined INCLUDE_TIMELEFT
	RegAdminCmd("sm_timeleft", 		Command_Timeleft, 		ADMFLAG_CHANGEMAP, 			"Change timeleft");
	#endif

	#if defined INCLUDE_GIVE
	RegAdminCmd("sm_give", 			Command_Give, 			ADMFLAG_BAN, 				"Give weapon");
	#endif
}

/*
COMMANDS
*/

stock void PrintToChatExcept(int client, const char[] sFormat, any ...)
{
	char sMessage[252];
	VFormat(sMessage, sizeof(sMessage), sFormat, 3);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (i != client)
		{
			if (lolo_IsClientValid(i))
			{
				PrintToChat(i, sMessage);
			}
		}
	}
}

#if defined INCLUDE_TEAM
#include "commands/team.sp"
#endif

#if defined INCLUDE_HEALTH
#include "commands/health.sp"
#endif

#if defined INCLUDE_GOD
#include "commands/god.sp"
#endif

#if defined INCLUDE_RESPAWN
#include "commands/respawn.sp"
#endif

#if defined INCLUDE_RRR
#include "commands/rrr.sp"
#endif

#if defined INCLUDE_RRM
#include "commands/rrm.sp"
#endif

#if defined INCLUDE_EXTEND
#include "commands/extend.sp"
#endif

#if defined INCLUDE_TIMELEFT
#include "commands/timeleft.sp"
#endif

#if defined INCLUDE_GIVE
#include "commands/give.sp"
#endif