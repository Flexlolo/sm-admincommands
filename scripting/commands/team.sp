public Action Command_Team(int client, int args)
{
	char[] usage = "usage: sm_team <target> <team name/index>";

	char sArgString[192];
	GetCmdArgString(sArgString, sizeof(sArgString));
	
	ArrayList hArgs = lolo_Args_Split(sArgString);
	
	if (hArgs != null)
	{
		int args_count = hArgs.Length;
		char[][] sArgs = new char[args_count][192];

		for (int i; i < args_count; i++)
		{
			hArgs.GetString(i, sArgs[i], 192);
		}

		lolo_CloseHandle(hArgs);

		if (args_count == 2)
		{
			ArrayList hTargets = lolo_Target_Process(client, sArgs[0]);
			int size = hTargets.Length;

			if (size)
			{
				int team = GetTeamIndex(sArgs[1]);
				char sTeam[16];
				bool team_valid;

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
								QPrintToChat(client, "%s %sMoved %s%s %sto %s%s", 	CHAT_SM, CHAT_SUCCESS, 
																					CHAT_VALUE, sName, CHAT_SUCCESS, 
																					CHAT_VALUE, sTeam);

								QPrintToChatAllExcept(client, "%s %s%s %smoved %s%s %sto %s%s", 	CHAT_SM, 
																								CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																								CHAT_VALUE, sName, CHAT_SUCCESS, 
																								CHAT_VALUE, sTeam);
							}
							else
							{
								PrintToServer("%s Moved %s to %s", CONSOLE_SM, sName, sTeam);

								QPrintToChatAll("%s %s%s %smoved %s%s %s to %s%s", 	CHAT_SM, 
																					CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																					CHAT_VALUE, sName, CHAT_SUCCESS, 
																					CHAT_VALUE, sTeam);
							}
						}
					}

					if (!target_valid)
					{
						if (client) QPrintToChat(client, "%s %sInvalid target to apply action.", CHAT_SM, CHAT_ERROR);
						else PrintToServer("%s Invaid target to apply action.", CONSOLE_SM);
					}

					return Plugin_Handled;
				}
				else
				{
					if (client) QPrintToChat(client, "%s %sInvalid team.", CHAT_SM, CHAT_ERROR);
					else PrintToServer("%s Invalid team.", CONSOLE_SM);

					return Plugin_Handled;
				}
			}

			if (client) QPrintToChat(client, "%s %sInvalid target.", CHAT_SM, CHAT_ERROR);
			else PrintToServer("%s Invalid target.", CONSOLE_SM);

			return Plugin_Handled;
		}
	}

	if (client) QPrintToChat(client, "%s %s%s", CHAT_SM, CHAT_ERROR, usage);
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
