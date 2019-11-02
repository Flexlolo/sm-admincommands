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
