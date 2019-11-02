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
