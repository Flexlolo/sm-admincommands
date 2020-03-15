public Action Command_God(int client, int args)
{
	char[] usage = "usage: sm_god <target> [<on/off>]";
	
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

		if (args_count == 1 || args_count == 2)
		{
			ArrayList hTargets = lolo_Target_Process(client, sArgs[0]);
			int size = hTargets.Length;

			if (size)
			{
				bool toggle = true;
				bool action;

				if (args_count == 2)
				{
					if (StrEqual(sArgs[1], "1", true) || StrEqual(sArgs[1], "on", true))
					{
						toggle = false;
						action = true;
					}
					else if (StrEqual(sArgs[1], "0", true) || StrEqual(sArgs[1], "off", true))
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

						if (god_current != god)
						{
							lolo_SetClientGod(target, god);
							target_valid = true;

							if (god)
							{
								if (client)
								{
									QPrintToChat(client, "%s %sEnabled godmode for %s%s", CHAT_SM, CHAT_SUCCESS, CHAT_VALUE, sName);

									QPrintToChatAllExcept(client, "%s %s%s %senabled godmode for %s%s", 	CHAT_SM, 
																										CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																										CHAT_VALUE, sName, CHAT_SUCCESS);
								}
								else
								{
									PrintToServer("%s Enabled godmode for %s", CONSOLE_SM, sName);

									QPrintToChatAll("%s %s%s %senabled godmode for %s%s", 	CHAT_SM, 
																							CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																							CHAT_VALUE, sName, CHAT_SUCCESS);
								}
							}
							else
							{
								if (client)
								{
									QPrintToChat(client, "%s %sDisabled godmode for %s%s", CHAT_SM, CHAT_SUCCESS, CHAT_VALUE, sName);

									QPrintToChatAllExcept(client, "%s %s%s %sdisabled godmode for %s%s", 	CHAT_SM, 
																										CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																										CHAT_VALUE, sName, CHAT_SUCCESS);
								}
								else
								{
									PrintToServer("%s Disabled godmode for %s", CONSOLE_SM, sName);

									QPrintToChatAll("%s %s%s %sdisabled godmode for %s%s", 	CHAT_SM, 
																							CHAT_VALUE, sAdminName, CHAT_SUCCESS, 
																							CHAT_VALUE, sName, CHAT_SUCCESS);
								}
							}
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

			if (client) QPrintToChat(client, "%s %sInvalid target.", CHAT_SM, CHAT_ERROR);
			else PrintToServer("%s Invalid target.", CONSOLE_SM);

			return Plugin_Handled;
		}
	}

	if (client) QPrintToChat(client, "%s %s%s", CHAT_SM, CHAT_ERROR, usage);
	else PrintToServer("%s %s", CONSOLE_SM, usage);

	return Plugin_Handled;
}
