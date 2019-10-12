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

char g_sWeapons[][] = 
{
	"glock", "usp", "p228", "deagle", "elite", "fiveseven",
	"m3", "xm1014",
	"mac10", "tmp", "mp5navy", "ump45", "p90",
	"galil", "ak47", "scout", "sg552", "awp", "g3sg1", "famas", "m4a1", "aug", "sg550",
	"m249",
	"flashbang", "hegrenade", "smokegrenade",
	"c4"
};

char g_sItems[][] = 
{
	"assaultsuit", "defuser", "nvgs"
};

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
	RegAdminCmd("sm_team", 			Command_Team, 			ADMFLAG_BAN, 				"Change player team");

	RegAdminCmd("sm_hp", 			Command_Health, 		ADMFLAG_BAN, 				"Change health");
	RegAdminCmd("sm_health", 		Command_Health, 		ADMFLAG_BAN, 				"Change health");

	RegAdminCmd("sm_god", 			Command_God, 			ADMFLAG_BAN, 				"Change godmode");
	RegAdminCmd("sm_godmode", 		Command_God, 			ADMFLAG_BAN, 				"Change godmode");

	RegAdminCmd("sm_respawn", 		Command_Respawn, 		ADMFLAG_BAN, 				"Respawn player");

	RegAdminCmd("sm_rrr", 			Command_RRR, 			ADMFLAG_CHANGEMAP, 			"Round restart");

	RegAdminCmd("sm_rrm", 			Command_RRM, 			ADMFLAG_CHANGEMAP, 			"Map restart");

	RegAdminCmd("sm_extend", 		Command_Extend, 		ADMFLAG_CHANGEMAP, 			"Map extend");

	RegAdminCmd("sm_timeleft", 		Command_Timeleft, 		ADMFLAG_CHANGEMAP, 			"Change timeleft");

	RegAdminCmd("sm_give", 			Command_Give, 			ADMFLAG_BAN, 				"Give weapon");
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



public Action Command_Team(int client, int args)
{
	char[] usage = "usage: sm_team <target> (<team_name>|<team_index>)";

	if (args)
	{
		char sArgs[192];
		GetCmdArgString(sArgs, sizeof(sArgs));

		if (StrContains(sArgs, " ", false) != -1)
		{
			char sArg[2][64];
			ExplodeString(sArgs, " ", sArg, sizeof(sArg), sizeof(sArg[]), true);

			if (strlen(sArg[0]))
			{
				ArrayList hTargets = lolo_Target_Process(client, sArg[0]);

				if (hTargets != null)
				{
					int size = hTargets.Length;

					if (size)
					{
						int team = -1;
						char sTeam[16];

						bool team_valid;

						if (strlen(sArg[1]))
						{
							team = GetTeamIndex(sArg[1]);
						}

						if (team != -1)
						{
							team_valid = true;
							GetTeamNameShort(team, sTeam, sizeof(sTeam));
						}

						if (team_valid)
						{
							char sAdminName[32];

							if (client)
							{
								GetClientName(client, sAdminName, sizeof(sAdminName));
							}
							else
							{
								sAdminName = CONSOLE_NAME;
							}

							char sName[32];

							bool target_valid;

							for (int i; i < size; i++)
							{
								int target = hTargets.Get(i);

								if (GetClientTeam(target) != team)
								{
									target_valid = true;
									
									GetClientName(target, sName, sizeof(sName));

									MoveToTeam(target, team);

									if (client)
									{
										PrintToChat(client, "%s %sMoved %s%s %sto %s%s", 	CHAT_SM, CHAT_SUCCESS, 
																							CHAT_VALUE, sName, CHAT_SUCCESS, 
																							CHAT_VALUE, sTeam);

										PrintToChatExcept(client, "%s %s%s %smoved %s%s %sto %s%s", 	CHAT_SM, 
																										CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																										CHAT_VALUE, sName, CHAT_SUCCESS, 
																										CHAT_VALUE, sTeam);
									}
									else
									{
										PrintToServer("%s Moved %s to %s", CONSOLE_SM, sName, sTeam);

										PrintToChatAll("%s %s%s %smoved %s%s %s to %s%s", 	CHAT_SM, 
																							CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																							CHAT_VALUE, sName, CHAT_SUCCESS, 
																							CHAT_VALUE, sTeam);
									}
								}
							}

							if (!target_valid)
							{
								if (client) PrintToChat(client, "%s %sInvalid target to apply action.", CHAT_SM, CHAT_ERROR);
								else PrintToServer("%s Invaid target to apply action.", CONSOLE_SM);
							}

							return Plugin_Handled;
						}
						else
						{
							if (client) PrintToChat(client, "%s %sInvalid team.", CHAT_SM, CHAT_ERROR);
							else PrintToServer("%s Invalid team.", CONSOLE_SM);

							return Plugin_Handled;
						}
					}
				}

				if (client) PrintToChat(client, "%s %sInvalid target.", CHAT_SM, CHAT_ERROR);
				else PrintToServer("%s Invalid target.", CONSOLE_SM);

				return Plugin_Handled;
			}
		}
	}

	if (client) PrintToChat(client, "%s %s%s", CHAT_SM, CHAT_ERROR, usage);
	else PrintToServer("%s %s", CONSOLE_SM, usage);

	return Plugin_Handled;
}

stock int GetTeamIndex(const char[] sTeam)
{
	if (StrEqual(sTeam, "spec", true)) return 1;
	else if (StrEqual(sTeam, "t", true)) return 2;
	else if (StrEqual(sTeam, "ct", true)) return 3;
	else
	{
		int team = StringToInt(sTeam);

		if (team >= 1 && team <= 3)
		{
			return team;
		}
	}

	return -1;
}

stock int GetTeamNameShort(int team, char[] sTeam, int maxlength)
{
	if (team == 1) Format(sTeam, maxlength, "spec");
	else if (team == 2)	Format(sTeam, maxlength, "t");
	else if (team == 3)	Format(sTeam, maxlength, "ct");
}

stock void MoveToTeam(int client, int team)
{
	ForcePlayerSuicide(client);
	ChangeClientTeam(client, team);
}



public Action Command_Health(int client, int args)
{
	char[] usage = "usage: sm_hp <target> (<health>|<+/-health>)";

	if (args)
	{
		char sArgs[192];
		GetCmdArgString(sArgs, sizeof(sArgs));

		if (StrContains(sArgs, " ", false) != -1)
		{
			char sArg[2][64];
			ExplodeString(sArgs, " ", sArg, sizeof(sArg), sizeof(sArg[]), true);

			if (strlen(sArg[0]))
			{
				ArrayList hTargets = lolo_Target_Process(client, sArg[0]);

				if (hTargets != null)
				{
					int size = hTargets.Length;

					if (size)
					{
						int health;
						bool health_set;
						bool health_valid;

						if (strlen(sArg[1]))
						{
							health = StringToInt(sArg[1]);

							if (sArg[1][0] != '+' && sArg[1][0] != '-')
							{
								health_set = true;
							}
						}

						if (health != 0)
						{
							if (!(health_set && health < 0))
							{
								health_valid = true;
							}
						}

						//PrintToChatAll("%s | %d %d %d", sArg[1], health, health_set, health_valid);

						if (health_valid)
						{
							bool target_valid;

							char sAdminName[32];

							if (client)
							{
								GetClientName(client, sAdminName, sizeof(sAdminName));
							}
							else
							{
								sAdminName = CONSOLE_NAME;
							}

							char sName[32];

							for (int i; i < size; i++)
							{
								int target = hTargets.Get(i);

								if (IsPlayerAlive(target))
								{
									GetClientName(target, sName, sizeof(sName));

									if (health_set)
									{
										lolo_SetClientHealth(target, health);
										target_valid = true;

										if (client)
										{
											PrintToChat(client, "%s %sSet %s%s %shp to %s%d", 	CHAT_SM, CHAT_SUCCESS, 
																								CHAT_VALUE, sName, CHAT_SUCCESS, 
																								CHAT_VALUE, health);

											PrintToChatExcept(client, "%s %s%s %sset %s%s %shp to %s%d", 	CHAT_SM, 
																											CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																											CHAT_VALUE, sName, CHAT_SUCCESS, 
																											CHAT_VALUE, health);
										}
										else
										{
											PrintToServer("%s Set %s hp to %d", CONSOLE_SM, sName, health);

											PrintToChatAll("%s %s%s %sset %s%s %shp to %s%d", 	CHAT_SM, 
																								CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																								CHAT_VALUE, sName, CHAT_SUCCESS, 
																								CHAT_VALUE, health);
										}
									}
									else
									{
										int target_health = GetClientHealth(target);
										int health_result = target_health + health;

										if (health_result > 0)
										{
											lolo_SetClientHealth(target, health_result);
											target_valid = true;

											if (health > 0)
											{
												if (client)
												{
													PrintToChat(client, "%s %sAdded %s%d %shp to %s%s", 	CHAT_SM, CHAT_SUCCESS, 
																											CHAT_VALUE, health, CHAT_SUCCESS, 
																											CHAT_VALUE, sName);

													PrintToChatExcept(client, "%s %s%s %sadded %s%d %shp to %s%s", 	CHAT_SM, 
																													CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																													CHAT_VALUE, health, CHAT_SUCCESS, 
																													CHAT_VALUE, sName);
												}
												else
												{
													PrintToServer("%s Added %d hp to %s", CONSOLE_SM, health, sName);

													PrintToChatAll("%s %s%s %sadded %s%d %shp to %s%s", 	CHAT_SM, 
																											CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																											CHAT_VALUE, health, CHAT_SUCCESS, 
																											CHAT_VALUE, sName);
												}
											}
											else
											{
												if (client)
												{
													PrintToChat(client, "%s %sRemoved %s%d %shp from %s%s", 	CHAT_SM, CHAT_SUCCESS, 
																												CHAT_VALUE, -health, CHAT_SUCCESS, 
																												CHAT_VALUE, sName);

													PrintToChatExcept(client, "%s %s%s %sremoved %s%d %shp from %s%s", 	CHAT_SM, 
																														CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																														CHAT_VALUE, -health, CHAT_SUCCESS, 
																														CHAT_VALUE, sName);
												}
												else
												{
													PrintToServer("%s Removed %d hp from %s", CONSOLE_SM, health, sName);

													PrintToChatAll("%s %s%s %sremoved %s%d %shp from %s%s", CHAT_SM, 
																											CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																											CHAT_VALUE, -health, CHAT_SUCCESS, 
																											CHAT_VALUE, sName);
												}
											}
										}
									}
								}
							}

							if (!target_valid)
							{
								if (client) PrintToChat(client, "%s %sInvalid target to apply action.", CHAT_SM, CHAT_ERROR);
								else PrintToServer("%s Invaid target to apply action.", CONSOLE_SM);
							}

							return Plugin_Handled;
						}
						else
						{
							if (client) PrintToChat(client, "%s %sInvalid health value.", CHAT_SM, CHAT_ERROR);
							else PrintToServer("%s Invalid health value.", CONSOLE_SM);

							return Plugin_Handled;
						}
					}
				}

				if (client) PrintToChat(client, "%s %sInvalid target.", CHAT_SM, CHAT_ERROR);
				else PrintToServer("%s Invalid target.", CONSOLE_SM);

				return Plugin_Handled;
			}
		}
	}

	if (client) PrintToChat(client, "%s %s%s", CHAT_SM, CHAT_ERROR, usage);
	else PrintToServer("%s %s", CONSOLE_SM, usage);

	return Plugin_Handled;
}

public Action Command_God(int client, int args)
{
	char[] usage = "usage: sm_god <target> [<on>|<off>]";
	
	if (args)
	{
		char sArgs[192];
		GetCmdArgString(sArgs, sizeof(sArgs));

		char sArg[2][64];
		ExplodeString(sArgs, " ", sArg, sizeof(sArg), sizeof(sArg[]), true);

		if (strlen(sArg[0]))
		{
			ArrayList hTargets = lolo_Target_Process(client, sArg[0]);

			if (hTargets != null)
			{
				int size = hTargets.Length;

				if (size)
				{
					bool toggle = true;
					bool action;

					if (strlen(sArg[1]))
					{
						if (StrEqual(sArg[1], "1", true) || StrEqual(sArg[1], "on", true))
						{
							toggle = false;
							action = true;
						}
						else if (StrEqual(sArg[1], "0", true) || StrEqual(sArg[1], "off", true))
						{
							toggle = false;
						}
					}

					bool target_valid;

					char sAdminName[32];

					if (client)
					{
						GetClientName(client, sAdminName, sizeof(sAdminName));
					}
					else
					{
						sAdminName = CONSOLE_NAME;
					}

					char sName[32];

					for (int i; i < size; i++)
					{
						int target = hTargets.Get(i);

						if (IsPlayerAlive(target))
						{
							GetClientName(target, sName, sizeof(sName));

							bool god_current = lolo_GetClientGod(target);
							bool god = action;

							if (toggle)
							{
								god = !lolo_GetClientGod(target);
							}

							//PrintToChatAll("%d %d", god_current, god);

							if (god_current != god)
							{
								lolo_SetClientGod(target, god);
								target_valid = true;

								if (god)
								{
									if (client)
									{
										PrintToChat(client, "%s %sEnabled godmode for %s%s", CHAT_SM, CHAT_SUCCESS, CHAT_VALUE, sName);

										PrintToChatExcept(client, "%s %s%s %senabled godmode for %s%s", 	CHAT_SM, 
																											CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																											CHAT_VALUE, sName, CHAT_SUCCESS);
									}
									else
									{
										PrintToServer("%s Enabled godmode for %s", CONSOLE_SM, sName);

										PrintToChatAll("%s %s%s %senabled godmode for %s%s", 	CHAT_SM, 
																								CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																								CHAT_VALUE, sName, CHAT_SUCCESS);
									}
								}
								else
								{
									if (client)
									{
										PrintToChat(client, "%s %sDisabled godmode for %s%s", CHAT_SM, CHAT_SUCCESS, CHAT_VALUE, sName);

										PrintToChatExcept(client, "%s %s%s %sdisabled godmode for %s%s", 	CHAT_SM, 
																											CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																											CHAT_VALUE, sName, CHAT_SUCCESS);
									}
									else
									{
										PrintToServer("%s Disabled godmode for %s", CONSOLE_SM, sName);

										PrintToChatAll("%s %s%s %sdisabled godmode for %s%s", 	CHAT_SM, 
																								CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																								CHAT_VALUE, sName, CHAT_SUCCESS);
									}
								}
							}
						}
					}

					if (!target_valid)
					{
						if (client) PrintToChat(client, "%s %sInvalid target to apply action.", CHAT_SM, CHAT_ERROR);
						else PrintToServer("%s Invaid target to apply action.", CONSOLE_SM);
					}

					return Plugin_Handled;
				}
			}

			if (client) PrintToChat(client, "%s %sInvalid target.", CHAT_SM, CHAT_ERROR);
			else PrintToServer("%s Invalid target.", CONSOLE_SM);

			return Plugin_Handled;
		}
	}

	if (client) PrintToChat(client, "%s %s%s", CHAT_SM, CHAT_ERROR, usage);
	else PrintToServer("%s %s", CONSOLE_SM, usage);

	return Plugin_Handled;
}

public Action Command_Respawn(int client, int args)
{
	char[] usage = "usage: sm_respawn <target>";

	if (args)
	{
		char sArgs[192];
		GetCmdArgString(sArgs, sizeof(sArgs));

		if (strlen(sArgs))
		{
			ArrayList hTargets = lolo_Target_Process(client, sArgs);

			if (hTargets != null)
			{
				int size = hTargets.Length;

				if (size)
				{
					bool target_valid;

					char sAdminName[32];

					if (client)
					{
						GetClientName(client, sAdminName, sizeof(sAdminName));
					}
					else
					{
						sAdminName = CONSOLE_NAME;
					}

					char sName[32];

					for (int i; i < size; i++)
					{
						int target = hTargets.Get(i);

						if (GetClientTeam(target) > 1)
						{
							GetClientName(target, sName, sizeof(sName));

							CS_RespawnPlayer(target);
							target_valid = true;

							if (client)
							{
								PrintToChat(client, "%s %sRespawned %s%s", CHAT_SM, CHAT_SUCCESS, CHAT_VALUE, sName);

								PrintToChatExcept(client, "%s %s%s %respawned %s%s", 	CHAT_SM, 
																						CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																						CHAT_VALUE, sName, CHAT_SUCCESS);
							}
							else
							{
								PrintToServer("%s Respawned %s", CONSOLE_SM, sName);

								PrintToChatAll("%s %s%s %srespawned %s%s", 	CHAT_SM, 
																			CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																			CHAT_VALUE, sName, CHAT_SUCCESS);
							}
						}
					}

					if (!target_valid)
					{
						if (client) PrintToChat(client, "%s %sInvalid target to apply action.", CHAT_SM, CHAT_ERROR);
						else PrintToServer("%s Invaid target to apply action.", CONSOLE_SM);
					}

					return Plugin_Handled;
				}
			}

			if (client) PrintToChat(client, "%s %sInvalid target.", CHAT_SM, CHAT_ERROR);
			else PrintToServer("%s Invalid target.", CONSOLE_SM);

			return Plugin_Handled;
		}
	}

	if (client) PrintToChat(client, "%s %s%s", CHAT_SM, CHAT_ERROR, usage);
	else PrintToServer("%s %s", CONSOLE_SM, usage);

	return Plugin_Handled;
}



public Action Command_RRR(int client, int args)
{
	char[] usage = "usage: sm_rrr [<time>]";

	int time = 1;

	if (args)
	{
		char sArgs[192];
		GetCmdArgString(sArgs, sizeof(sArgs));

		time = StringToInt(sArgs);

		if (time <= 0)
		{
			if (client) PrintToChat(client, "%s %s%s", CHAT_SM, CHAT_ERROR, usage);
			else PrintToServer("%s %s", CONSOLE_SM, usage);

			return Plugin_Handled;
		}
	}

	ServerCommand("mp_restartgame %d", time);

	char sAdminName[32];

	if (client)
	{
		GetClientName(client, sAdminName, sizeof(sAdminName));

		PrintToChat(client, "%s %sInitialized round restart in %s%d %ssec", CHAT_SM, CHAT_SUCCESS, CHAT_VALUE, time, CHAT_SUCCESS);

		PrintToChatExcept(client, "%s %s%s %sinitialized round restart in %s%d %ssec", 	CHAT_SM, 
																						CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																						CHAT_VALUE, time, CHAT_SUCCESS);
	}
	else
	{
		sAdminName = CONSOLE_NAME;

		PrintToServer("%s Initialized round restart in %d sec", CONSOLE_SM, time);

		PrintToChatAll("%s %s%s %sinitialized round restart in %s%d %ssec", CHAT_SM, 
																			CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																			CHAT_VALUE, time, CHAT_SUCCESS);
	}

	return Plugin_Handled;
}

public Action Command_RRM(int client, int args)
{
	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));

	ServerCommand("sm_map %s", sMap);

	char sAdminName[32];

	if (client)
	{
		GetClientName(client, sAdminName, sizeof(sAdminName));

		PrintToChat(client, "%s %sInitialized map restart.", CHAT_SM, CHAT_SUCCESS);

		PrintToChatExcept(client, "%s %s%s %sinitialized map restart.", CHAT_SM, CHAT_VALUE, sAdminName, CHAT_SUCCESS);
	}
	else
	{
		sAdminName = CONSOLE_NAME;

		PrintToServer("%s Initialized map restart.", CONSOLE_SM);

		PrintToChatAll("%s %s%s %sinitialized map restart.", CHAT_SM, CHAT_VALUE, sAdminName, CHAT_SUCCESS);
	}
}



public Action Command_Extend(int client, int args)
{
	char[] usage = "usage: sm_extend <time>";

	float time;

	if (args)
	{
		char sArgs[192];
		GetCmdArgString(sArgs, sizeof(sArgs));

		time = StringToFloat(sArgs);
	}

	if (time <= 0.0)
	{
		if (client) PrintToChat(client, "%s %s%s", CHAT_SM, CHAT_ERROR, usage);
		else PrintToServer("%s %s", CONSOLE_SM, usage);

		return Plugin_Handled;
	}

	ExtendMapTimeLimit(RoundToNearest(time * 60.0));

	char sAdminName[32];

	if (client)
	{
		GetClientName(client, sAdminName, sizeof(sAdminName));

		PrintToChat(client, "%s %sExtended map for %s%.1f %smin.", CHAT_SM, CHAT_SUCCESS, CHAT_VALUE, time, CHAT_SUCCESS);

		PrintToChatExcept(client, "%s %s%s %sextended map for %s%.1f %smin.", 	CHAT_SM, 
																				CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																				CHAT_VALUE, time, CHAT_SUCCESS);
	}
	else
	{
		sAdminName = CONSOLE_NAME;

		PrintToServer("%s Extended map for %.1f min.", CONSOLE_SM, time);

		PrintToChatAll("%s %s%s %sextended map for %s%.1f %smin.", 	CHAT_SM, 
																	CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																	CHAT_VALUE, time, CHAT_SUCCESS);
	}

	return Plugin_Handled;
}

public Action Command_Timeleft(int client, int args)
{
	char[] usage = "usage: sm_timeleft <time>";

	int time;

	if (args)
	{
		char sArgs[192];
		GetCmdArgString(sArgs, sizeof(sArgs));

		time = StringToInt(sArgs);
	}

	if (time <= 0)
	{
		if (client) PrintToChat(client, "%s %s%s", CHAT_SM, CHAT_ERROR, usage);
		else PrintToServer("%s %s", CONSOLE_SM, usage);

		return Plugin_Handled;
	}

	int timeleft;

	if (GetMapTimeLeft(timeleft))
	{
		int extend = time*60 - timeleft;

		ExtendMapTimeLimit(extend);
	}

	char sAdminName[32];

	if (client)
	{
		GetClientName(client, sAdminName, sizeof(sAdminName));

		PrintToChat(client, "%s %sSet timeleft for %s%d %smin.", CHAT_SM, CHAT_SUCCESS, CHAT_VALUE, time, CHAT_SUCCESS);

		PrintToChatExcept(client, "%s %s%s %set timeleft for %s%d %smin.", 	CHAT_SM, 
																			CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																			CHAT_VALUE, time, CHAT_SUCCESS);
	}
	else
	{
		sAdminName = CONSOLE_NAME;

		PrintToServer("%s Set timeleft  for %d min.", CONSOLE_SM, time);

		PrintToChatAll("%s %s%s %sset timeleft  for %s%d %smin.", 	CHAT_SM, 
																	CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																	CHAT_VALUE, time, CHAT_SUCCESS);
	}

	return Plugin_Handled;
}



public Action Command_Give(int client, int args)
{
	char[] usage = "usage: sm_give <target> (<weapon>|<item>)";

	if (args)
	{
		char sArgs[192];
		GetCmdArgString(sArgs, sizeof(sArgs));

		char sArg[2][64];
		ExplodeString(sArgs, " ", sArg, sizeof(sArg), sizeof(sArg[]), true);

		if (strlen(sArg[0]))
		{
			ArrayList hTargets = lolo_Target_Process(client, sArg[0]);

			if (hTargets != null)
			{
				int size = hTargets.Length;

				if (size)
				{
					bool weapon;
					bool item;
					char sWeapon[48];

					if (strlen(sArg[1]))
					{
						if (lolo_String_Startswith(sArg[1], "weapon_", true))
						{
							strcopy(sWeapon, sizeof(sWeapon), sArg[1][7]);
						}
						else
						{
							strcopy(sWeapon, sizeof(sWeapon), sArg[1]);
						}
						
						for (int i; i < sizeof(g_sWeapons); i++)
						{
							if (StrEqual(sWeapon, g_sWeapons[i], true))
							{
								weapon = true;
								break;
							}
						}

						if (!weapon)
						{
							for (int i; i < sizeof(g_sItems); i++)
							{
								if (StrEqual(sWeapon, g_sItems[i], true))
								{
									item = true;
									break;
								}
							}
						}
					}

					if (weapon || item)
					{
						char sEntity[48];

						if (weapon)
						{
							Format(sEntity, sizeof(sEntity), "weapon_%s", sWeapon);
						}
						else
						{
							Format(sEntity, sizeof(sEntity), "item_%s", sWeapon);
						}

						bool target_valid;

						char sAdminName[32];

						if (client)
						{
							GetClientName(client, sAdminName, sizeof(sAdminName));
						}
						else
						{
							sAdminName = CONSOLE_NAME;
						}

						char sName[32];

						for (int i; i < size; i++)
						{
							int target = hTargets.Get(i);

							if (IsPlayerAlive(target))
							{
								GetClientName(target, sName, sizeof(sName));

								GivePlayerItem(target, sEntity);
								target_valid = true;

								if (client)
								{
									PrintToChat(client, "%s %sGave %s%s %sto %s%s", CHAT_SM, CHAT_SUCCESS, CHAT_VALUE, sWeapon, CHAT_SUCCESS, 
																											CHAT_VALUE, sName);

									PrintToChatExcept(client, "%s %s%s %sgave %s%s %sto %s%s", CHAT_SM, CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																										CHAT_VALUE, sWeapon, CHAT_SUCCESS,
																										CHAT_VALUE, sName, CHAT_SUCCESS);
								}
								else
								{
									PrintToServer("%s Gave %s to %s", CONSOLE_SM, sName);

									PrintToChatAll("%s %s%s %sgave %s%s %sto %s%s", CHAT_SM, CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																							CHAT_VALUE, sWeapon, CHAT_SUCCESS,
																							CHAT_VALUE, sName, CHAT_SUCCESS);
								}
							}
						}

						if (!target_valid)
						{
							if (client) PrintToChat(client, "%s %sInvalid target to apply action.", CHAT_SM, CHAT_ERROR);
							else PrintToServer("%s Invaid target to apply action.", CONSOLE_SM);
						}

						return Plugin_Handled;
					}

					if (client) PrintToChat(client, "%s %sInvalid weapon.", CHAT_SM, CHAT_ERROR);
					else PrintToServer("%s Invalid weapon.", CONSOLE_SM);

					return Plugin_Handled;

				}
			}

			if (client) PrintToChat(client, "%s %sInvalid target.", CHAT_SM, CHAT_ERROR);
			else PrintToServer("%s Invalid target.", CONSOLE_SM);

			return Plugin_Handled;
		}
	}

	if (client) PrintToChat(client, "%s %s%s", CHAT_SM, CHAT_ERROR, usage);
	else PrintToServer("%s %s", CONSOLE_SM, usage);

	return Plugin_Handled;
}