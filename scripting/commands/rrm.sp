public Action Command_RRM(int client, int args)
{
	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));

	ServerCommand("sm_map %s", sMap);

	char sAdminName[32];

	if (client)
	{
		GetClientName(client, sAdminName, sizeof(sAdminName));

		QPrintToChat(client, "%s %sInitialized map restart.", CHAT_SM, CHAT_SUCCESS);
		QPrintToChatAllExcept(client, "%s %s%s %sinitialized map restart.", CHAT_SM, CHAT_VALUE, sAdminName, CHAT_SUCCESS);
	}
	else
	{
		sAdminName = CONSOLE_NAME;

		PrintToServer("%s Initialized map restart.", CONSOLE_SM);
		QPrintToChatAll("%s %s%s %sinitialized map restart.", CHAT_SM, CHAT_VALUE, sAdminName, CHAT_SUCCESS);
	}
}
