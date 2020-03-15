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
		if (client) QPrintToChat(client, "%s %s%s", CHAT_SM, CHAT_ERROR, usage);
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

		QPrintToChat(client, "%s %sSet timeleft for %s%d %smin.", CHAT_SM, CHAT_SUCCESS, CHAT_VALUE, time, CHAT_SUCCESS);

		QPrintToChatAllExcept(client, "%s %s%s %set timeleft for %s%d %smin.", 	CHAT_SM, 
																			CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																			CHAT_VALUE, time, CHAT_SUCCESS);
	}
	else
	{
		sAdminName = CONSOLE_NAME;

		PrintToServer("%s Set timeleft  for %d min.", CONSOLE_SM, time);

		QPrintToChatAll("%s %s%s %sset timeleft  for %s%d %smin.", 	CHAT_SM, 
																	CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																	CHAT_VALUE, time, CHAT_SUCCESS);
	}

	return Plugin_Handled;
}
