public Action:EnableThirdPerson(Handle:timer) {
	for (new i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
			ClientCommand(i, "thirdperson");
		}
	}
}

public Action:SlowMotionTimer(Handle timer) {
    if (!g_SlowMotion) {
        return Plugin_Stop;
    }
    int randomInt = GetRandomInt(0, 2);

    if (randomInt == 0) {
        for (new i = 1; i <= MaxClients; i++) {
            if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
                g_HighSpeed = !g_HighSpeed;
                if (g_HighSpeed) {
                    SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
                    SetConVarInt(sv_gravity, 800);
                } else {
                    SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.3);
                    SetConVarInt(sv_gravity, 400);
                }
            }
        }
    }

    return Plugin_Continue;
}

public Action:DropWeaponsTimer(Handle timer, DataPack data) {
    if (!g_DropWeapons) {
        return Plugin_Stop;
    }

    if (data == INVALID_HANDLE) {
        return Plugin_Stop;
    }

    data.Reset();
    new client = data.ReadCell();

    if (client == -1) {
        return Plugin_Stop;
    }

    new currentWeapon = GetPlayerWeaponSlot(client, 1);

    if (currentWeapon != -1) {
        CS_DropWeapon(client, currentWeapon, true, true);
    }

    CreateNewDropWeaponsTimer(client);

    return Plugin_Stop;
}

public Action:SetTinyMagsTimer(Handle timer) {
    if (!g_TinyMags) {
        return Plugin_Stop;
    }

    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            if (GetClipAmmo(i) > 1) {
                SetClipAmmo(i, 1);
            }

            SetReserveAmmo(i, 1);
        }
    }

    return Plugin_Continue;
}

/* public Action:RemoveReserveAmmoTimer(Handle timer) {
    if (!g_OneInTheChamber) {
        return Plugin_Stop;
    }

    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            SetReserveAmmo(i, 0);
        }
    }

    return Plugin_Continue;
} */

// Simply here to delay starting the timer
// so players can walk to their leader at
// start of the round
public Action:StartLeaderTimer(Handle timer) {
    CreateTimer(7.0, CheckLeaderTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:CheckLeaderTimer(Handle timer) {
    if (!g_Leader) {
        return Plugin_Stop;
    }

    ArrayList ctPlayers = new ArrayList();
    ArrayList tPlayers = new ArrayList();

    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            if (GetClientTeam(i) == CS_TEAM_CT) {
                ctPlayers.Push(i);
            } else if (GetClientTeam(i) == CS_TEAM_T) {
                tPlayers.Push(i);
            }
        }
    }

    if (ctPlayers.Length > 0 && ctLeader != -1) {
        float vec[3];
        GetClientEyePosition(ctLeader, vec);

        for (int i = 0; i < ctPlayers.Length; i++) {
            int client = ctPlayers.Get(i);

            float pos[3];
            GetClientEyePosition(client, pos);

            float distance = GetVectorDistance(vec, pos);

            if (distance > 300) {
                DamagePlayer(client, 5);
                new String:message[256];
                Format(message, sizeof(message), "{DARK_RED}Warning {NORMAL}too far from the {YELLOW}leader");
                Colorize(message, sizeof(message));
                CPrintToChat(client, message);
            }
        }
    }

    if (tPlayers.Length > 0 && tLeader != -1) {
        float vec[3];
        GetClientEyePosition(tLeader, vec);

        for (int i = 0; i < tPlayers.Length; i++) {
            int client = tPlayers.Get(i);

            float pos[3];
            GetClientEyePosition(client, pos);

            float distance = GetVectorDistance(vec, pos);

            if (distance > 300) {
                DamagePlayer(client, 5);
                new String:message[256];
                Format(message, sizeof(message), "{DARK_RED}Warning {NORMAL}too far from the {YELLOW}leader");
                Colorize(message, sizeof(message));
                CPrintToChat(client, message);
            }
        }
    }

    return Plugin_Continue;
}

public Action:CheckMonkeyTimer(Handle timer) {
    if (!g_MonkeySee) {
        return Plugin_Stop;
    }

    float ctPos[3];
    float tPos[3];

    GetClientEyePosition(ctLeader, ctPos);
    GetClientEyePosition(tLeader, tPos);

    int ctAlive = 0;
    int tAlive = 0;

    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            if (client != ctLeader && client != tLeader) {
                float pos[3];
                GetClientEyePosition(client, pos);
                float distance = -1;

                if (GetClientTeam(client) == CS_TEAM_CT) {
                    ctAlive++;
                    distance = GetVectorDistance(pos, tPos);
                } else if (GetClientTeam(client) == CS_TEAM_T) {
                    tAlive++;
                    distance = GetVectorDistance(pos, ctPos);
                }

                if (distance > 500) {
                    DamagePlayer(client, 5);
                    SendMessage(client, "{DARK_RED}Warning{NORMAL} too far from the {YELLOW}leader");
                }
            }
        }
    }

    if (ctAlive == 0) {
        KillPlayer(ctLeader, tLeader, "knife");
        return Plugin_Stop;
    } else if (tAlive == 0) {
        KillPlayer(tLeader, ctLeader, "knife");
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

public Action:StartMonkeyTimer(Handle timer) {
    float ctPos[3];
    float tPos[3];

    GetEntPropVector(ctLeader, Prop_Send, "m_vecOrigin", ctPos);
    GetEntPropVector(tLeader, Prop_Send, "m_vecOrigin", tPos);

    ctPos[2] += CLIENTHEIGHT * 2;
    tPos[2] += CLIENTHEIGHT * 2;

    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            if (GetClientTeam(client) == CS_TEAM_CT) {
                if (client == ctLeader) {
                    SendMessage(client, "Try to lose the {DARK_RED}Terrorists");
                    GivePlayerItem(client, "weapon_knife");
                } else {
                    SendMessage(client, "Try to keep up with the {DARK_RED}Terrorist{NORMAL} leader");
                    TeleportEntity(client, tPos, NULL_VECTOR, NULL_VECTOR);
                }
            } else if (GetClientTeam(client) == CS_TEAM_T) {
                if (client == tLeader) {
                    SendMessage(client, "Try to lose the {DARK_RED}Counter-Terrorists");
                    GivePlayerItem(client, "weapon_knife");
                } else {
                    SendMessage(client, "Try to keep up with the {DARK_RED}Counter-Terrorist{NORMAL} leader");
                    TeleportEntity(client, ctPos, NULL_VECTOR, NULL_VECTOR);
                }
            }
            SDKHook(client, SDKHook_SetTransmit, Hook_MonkeySeeTransmit);
        }
    }

    CreateTimer(0.5, CheckMonkeyTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:CheckAxeFistsTimer(Handle timer) {
    if (!g_Axe && !g_Fists) {
        return Plugin_Stop;
    }

    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            new meleeSlot = GetPlayerWeaponSlot(i, 2);

            if (meleeSlot < 0) {
                if (g_Axe) {
                    new axe = GivePlayerItem(i, "weapon_axe");
                    EquipPlayerWeapon(i, axe);
                } else if (g_Fists) {
                    new fists = GivePlayerItem(i, "weapon_fists");
                    EquipPlayerWeapon(i, fists);
                }
            }
        }
    }

    return Plugin_Continue;
}

public Action:BuddyTimer(Handle timer) {
    if (!g_BuddySystem) {
        return Plugin_Stop;
    }
    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            // Convert player id to string
            new String:playerIdString[64];
            IntToString(i, playerIdString, sizeof(playerIdString));
            // Get chicken that belongs to player
            new chicken;
            if (chickenMap.GetValue(playerIdString, chicken)) {
                if (chicken != 0) {
                    // Set the leader property again
                    SetEntPropEnt(chicken, Prop_Send, "m_leader", i);
                }
            }
        }
    }
    return Plugin_Continue;
}

public Action:RedGreenMessageTimer(Handle timer) {
    if (!g_RedGreen) {
        return Plugin_Stop;
    }
    new String:message[256];
    if (!g_RedLight) {
        Format(message, sizeof(message), "{DARK_RED}Red light{NORMAL}: Don't move!");
        // Only enforce no move after certain time
        CreateTimer(1.0, RedLightTimer);
    } else {
        Format(message, sizeof(message), "{GREEN}Green light{NORMAL}: You can move!");
        // Immediately enforce move period
        g_RedLight = false;
        CreateNewRedGreenTimer();
    }
    Colorize(message, sizeof(message));
    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && !IsFakeClient(i)) {
            CPrintToChat(i, message);
        }
    }

    return Plugin_Continue;
}

public Action:RedLightTimer(Handle timer) {
    g_RedLight = true;

    // Save player positions
    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            // Store client id in string
            new String:playerIdString[64];
            IntToString(i, playerIdString, sizeof(playerIdString));

            float playerPos[3];
            GetClientEyePosition(i, playerPos);
            positionMap.SetArray(playerIdString, playerPos, 3);
        }
    }

    CreateNewRedGreenTimer();

    return Plugin_Continue;
}

public Action:RedGreenDamageTimer(Handle timer) {
    if (!g_RedGreen) {
        return Plugin_Stop;
    }
    new String:message[256];
    Format(message, sizeof(message), "Don't {DARK_RED}move{NORMAL} during {DARK_RED}red{NORMAL} light");
    Colorize(message, sizeof(message));

    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            // Store client id in string
            new String:playerIdString[64];
            IntToString(i, playerIdString, sizeof(playerIdString));

            float playerPos[3];
            GetClientEyePosition(i, playerPos);

            float oldPlayerPos[3];
            if (positionMap.GetArray(playerIdString, oldPlayerPos, sizeof(oldPlayerPos))) {

                float distance = GetVectorDistance(oldPlayerPos, playerPos);

                if (g_RedLight && distance > 10) {
                    new currentHealth = GetEntProp(i, Prop_Send, "m_iHealth");
                    if (currentHealth > 5) {
                        SetEntityHealth(i, currentHealth - 5);
                    } else {
                        ForcePlayerSuicide(i);
                    }
                    CPrintToChat(i, message);
                }
            }

            positionMap.SetArray(playerIdString, playerPos, 3);
        }
    }

    return Plugin_Continue;
}

public Action:NewHotPotatoTimer(Handle timer) {
    if (!g_HotPotato) {
        return Plugin_Stop;
    }

    SelectHotPotato();
    CreateTimer(5.0, HotPotatoMessage1Timer);
    CreateTimer(10.0, HotPotatoMessage2Timer);
    CreateTimer(15.0, HotPotatoTimer);

    return Plugin_Continue;
}

public Action:HotPotatoMessage1Timer(Handle timer) {
    if (ctLeader != -1) {
        new String:message[256];
        Format(message, sizeof(message), "That is one {DARK_RED}hot potato{NORMAL}!", ctLeaderName);
        Colorize(message, sizeof(message));
        CPrintToChat(ctLeader, message);
    }
}

public Action:HotPotatoMessage2Timer(Handle timer) {
    if (ctLeader != -1) {
        new String:message[256];
        Format(message, sizeof(message), "I can't hold this {DARK_RED}hot potato{NORMAL} much longer!", ctLeaderName);
        Colorize(message, sizeof(message));
        CPrintToChat(ctLeader, message);
    }
}

public Action:HotPotatoTimer(Handle timer) {
    if (!g_HotPotato) {
        return Plugin_Stop;
    }

    RemoveWeapons();
    if (ctLeader != -1) {
        ForcePlayerSuicide(ctLeader);

        new String:message[256];
        Format(message, sizeof(message), "{YELLOW}%s died with the {DARK_RED}hot potato{NORMAL}!", ctLeaderName);
        Colorize(message, sizeof(message));
        for (new i = 1; i <= MaxClients; i++) {
            if (IsClientInGame(i) && !IsFakeClient(i)) {
                CPrintToChat(i, message);
            }
        }

        bool ctWiped = true;
        bool tWiped = true;

        for (int client = 1; client <= MaxClients; client++) {
            if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                if (GetClientTeam(client) == CS_TEAM_CT) {
                    ctWiped = false;
                } else if (GetClientTeam(client) == CS_TEAM_T) {
                    tWiped = false;
                }
            }
        }

        if (ctWiped || tWiped) {
            return Plugin_Stop;
        }
    }

    CreateTimer(3.0, NewHotPotatoTimer);

    return Plugin_Continue;
}

public Action:CheckC4Timer(Handle timer) {
    if (!g_Bomberman) {
        return Plugin_Stop;
    }

    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i)) {
            new c4Slot = GetPlayerWeaponSlot(i, 4);

            if (c4Slot < 0) {
                new c4 = GivePlayerItem(i, "weapon_c4");
                EquipPlayerWeapon(i, c4);
            }
        }
    }

    return Plugin_Continue;
}

public Action:WipeTeamTimer(Handle timer, DataPack data) {
    SetConVarInt(mp_ignore_round_win_conditions, 0, true, false);

    data.Reset();

    int team = data.ReadCell();

    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && !IsFakeClient(client)) {
            if (GetClientTeam(client) == team) {
                KillPlayer(client, client);
            }
        }
    }
}

public Action:DontMissDamageTimer(Handle timer, DataPack data) {
    data.Reset();

    int client = data.ReadCell();
    int damage = data.ReadCell();

    DamagePlayer(client, damage);
}

public Action:RandomGunsTimer(Handle timer) {
    if (!g_RandomGuns) {
        return Plugin_Stop;
    }

    RemoveWeapons();

    for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            new randomIntCat = GetRandomInt(0, 1);

            char weapon[256];
            if (randomIntCat == 0) {
                new randomInt = GetRandomInt(0, PRIMARY_LENGTH - 1);
                Format(weapon, sizeof(weapon), WeaponPrimary[randomInt]);
            } else {
                new randomInt = GetRandomInt(0, SECONDARY_LENGTH - 1);
                Format(weapon, sizeof(weapon), WeaponSecondary[randomInt]);
            }
            GivePlayerItem(client, weapon);
        }
    }

    float randomFloat = GetRandomFloat(5.0, 9.0);

    CreateTimer(randomFloat, RandomGunsTimer);

    return Plugin_Continue;
}

public Action:PoisonDamageTimer(Handle timer) {
    if (!g_Poison) {
        return Plugin_Stop;
    }

    for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            float playerPos[3];
            GetClientEyePosition(client, playerPos);

            StringMapSnapshot snapshot = smokeMap.Snapshot();
            for (int i = 0; i < snapshot.Length; i++) {
                char key[64];
                snapshot.GetKey(i, key, sizeof(key));

                float smokePos[3];
                smokeMap.GetArray(key, smokePos, sizeof(smokePos));

                float distance = GetVectorDistance(playerPos, smokePos);

                if (distance < SMOKE_RADIUS) {
                    DamagePlayer(client, 5);
                    new String:message[256];
                    Format(message, sizeof(message), "{DARK_RED}Warning {NORMAL}the smoke is {DARK_RED}toxic");
                    Colorize(message, sizeof(message));
                    CPrintToChat(client, message);
                }
            }
            // Free snapshot variable
            delete snapshot;
        }
    }

    return Plugin_Continue;
}

public Action:AwardZeusTimer(Handle timer, int client) {
    if (!g_ZeusRound) {
        return Plugin_Stop;
    }

    GivePlayerItem(client, "weapon_taser");

    return Plugin_Continue;
}

public Action:RemoveOITCWeapon(Handle timer, DataPack data) {
    if (!g_OneInTheChamber) {
        return Plugin_Stop;
    }

    data.Reset();
    int client = data.ReadCell();
    new weapon = data.ReadCell();

    RemovePlayerItem(client, weapon);
    RemoveEdict(weapon);

    return Plugin_Continue;
}

public Action:AwardOITCWeapon(Handle timer, int client) {
    if (!g_OneInTheChamber) {
        return Plugin_Stop;
    }

    char weaponname[128];
    Client_GetActiveWeaponName(client, weaponname, sizeof(weaponname));
    if (!StrEqual(weaponname, "weapon_knife") && GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon") > 0) {
        SetClipAmmo(client, GetClipAmmo(client) + 1);
    } else {
        if (!StrEqual(primaryWeapon, "")) {
            GivePlayerItem(client, primaryWeapon);
        }
        if (!StrEqual(secondaryWeapon, "")) {
            GivePlayerItem(client, secondaryWeapon);
        }
        SetClipAmmo(client, 1);
    }

    return Plugin_Continue;
}

public Action:SendCaptchaTimer(Handle timer) {
    if (!g_Captcha) {
        return Plugin_Stop;
    }

    int randomInt1 = GetRandomInt(5, 20);
    int randomInt2 = GetRandomInt(5, 20);

    IntToString(randomInt1 + randomInt2, captchaAnswer, sizeof(captchaAnswer));

    char message1[256];
    char message2[256];
    Format(message1, sizeof(message1),
        "{GREEN}Solve{NORMAL} %d + %d to get your {LIGHT_GREEN}weapons{NORMAL} back!",
        randomInt1, randomInt2);
    Format(message2, sizeof(message2), "Type the {LIGHT_GREEN}answer{NORMAL} in chat.");
    Colorize(message1, sizeof(message1));
    Colorize(message2, sizeof(message2));
    for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            CPrintToChat(client, message1);
            CPrintToChat(client, message2);
            // Client is not on list
            if (captchaClients.FindValue(client) == -1) {
                captchaClients.Push(client);
                RemoveWeaponsClient(client);
            }
        }
    }

    float randomFloat = GetRandomFloat(8.0, 15.0);
    CreateTimer(randomFloat, SendCaptchaTimer);

    return Plugin_Continue;
}
