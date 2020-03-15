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
		if (client) QPrintToChat(client, "%s %s%s", CHAT_SM, CHAT_ERROR, usage);
		else PrintToServer("%s %s", CONSOLE_SM, usage);

		return Plugin_Handled;
	}

	ExtendMapTimeLimit(RoundToNearest(time * 60.0));

	char sAdminName[32];

	if (client)
	{
		GetClientName(client, sAdminName, sizeof(sAdminName));

		QPrintToChat(client, "%s %sExtended map for %s%.1f %smin.", CHAT_SM, CHAT_SUCCESS, CHAT_VALUE, time, CHAT_SUCCESS);

		QPrintToChatAllExcept(client, "%s %s%s %sextended map for %s%.1f %smin.", 	CHAT_SM, 
																					CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																					CHAT_VALUE, time, CHAT_SUCCESS);
	}
	else
	{
		sAdminName = CONSOLE_NAME;

		PrintToServer("%s Extended map for %.1f min.", CONSOLE_SM, time);

		QPrintToChatAll("%s %s%s %sextended map for %s%.1f %smin.", CHAT_SM, 
																	CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																	CHAT_VALUE, time, CHAT_SUCCESS);
	}

	return Plugin_Handled;
}
