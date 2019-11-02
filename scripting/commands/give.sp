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