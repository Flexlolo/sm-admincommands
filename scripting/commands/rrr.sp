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
			if (client) QPrintToChat(client, "%s %s%s", CHAT_SM, CHAT_ERROR, usage);
			else PrintToServer("%s %s", CONSOLE_SM, usage);

			return Plugin_Handled;
		}
	}

	ServerCommand("mp_restartgame %d", time);

	char sAdminName[32];

	if (client)
	{
		GetClientName(client, sAdminName, sizeof(sAdminName));

		QPrintToChat(client, "%s %sInitialized round restart in %s%d %ssec", CHAT_SM, CHAT_SUCCESS, CHAT_VALUE, time, CHAT_SUCCESS);

		QPrintToChatAllExcept(client, "%s %s%s %sinitialized round restart in %s%d %ssec", 	CHAT_SM, 
																						CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																						CHAT_VALUE, time, CHAT_SUCCESS);
	}
	else
	{
		sAdminName = CONSOLE_NAME;

		PrintToServer("%s Initialized round restart in %d sec", CONSOLE_SM, time);

		QPrintToChatAll("%s %s%s %sinitialized round restart in %s%d %ssec", CHAT_SM, 
																			CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																			CHAT_VALUE, time, CHAT_SUCCESS);
	}

	return Plugin_Handled;
}
