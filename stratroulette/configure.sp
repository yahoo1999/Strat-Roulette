public ConfigureThirdPerson() {
    if (StrEqual(ThirdPerson, "1")) {
		SetConVarInt(sv_allow_thirdperson, 1, true, false);
		CreateTimer(0.1, EnableThirdPerson);
	} else {
        SetConVarInt(sv_allow_thirdperson, 0, true, false);
	}
}

public ConfigureWeapons() {
    // First remove weapons
    RemoveWeapons();
    RemoveNades();

    // For random weapon generate first whether it
    // should be primary of secondary
    new randomIntCat = -1;
    if (StrEqual(Weapon, "weapon_random")) {
        randomIntCat = GetRandomInt(0, 1);
    }

    char primary[256];
    char secondary[256];

    if (StrContains(Weapon, "weapon_primary_random") != -1 || randomIntCat == 0) {
        new randomInt = GetRandomInt(0, PRIMARY_LENGTH - 1);
        Format(primary, sizeof(primary), WeaponPrimary[randomInt]);
    }
    if (StrContains(Weapon, "weapon_secondary_random") != -1 || randomIntCat == 1) {
        new randomInt = GetRandomInt(0, SECONDARY_LENGTH - 1);
        Format(secondary, sizeof(secondary), WeaponSecondary[randomInt]);
    }

    // If we need to give a weapon
    if (!StrEqual(Weapon, "none")) {
		decl String:bit[10][80];
		new SumOfStrings = ExplodeString(Weapon, ";", bit, sizeof bit, sizeof bit[]);

		for (int string = 0; string < SumOfStrings; string++) {
            for (int j = 1; j < MaxClients; j++) {
                if (IsClientInGame(j) && IsPlayerAlive(j) && !IsFakeClient(j)) {
                    if (!g_Zombies || GetClientTeam(j) == CS_TEAM_CT) {
                        if (StrEqual(bit[string], "weapon_primary_random")
                         || (StrEqual(bit[string], "weapon_random") && randomIntCat == 0)) {
                            GivePlayerItem(j, primary);
                        } else if (StrEqual(bit[string], "weapon_secondary_random")
                         || (StrEqual(bit[string], "weapon_random") && randomIntCat == 1)) {
                            GivePlayerItem(j, secondary);
                        } else {
                            GivePlayerItem(j, bit[string]);
                        }
                    }
                }
            }
        }
    }

    return 1;
}

public ConfigureArmorDefuser() {
    // Defuser
    for (int client = 1; client < MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            if (GetClientTeam(client) == CS_TEAM_CT) {
                if (StrEqual(Defuser, "1")) {
                    SetEntProp(client, Prop_Send, "m_bHasDefuser", 1);
                } else {
                    SetEntProp(client, Prop_Send, "m_bHasDefuser", 0);
                }
            }
            if (StrEqual(Armor, "0")) {
                Client_SetArmor(client, 0);
            } else {
                new armorInt = StringToInt(Armor);
                Client_SetArmor(client, armorInt);
            }
            if (StrEqual(Helmet, "1")) {
                SetEntData(client, FindSendPropInfo("CCSPlayer", "m_bHasHelmet"), 1);
            } else {
                SetEntData(client, FindSendPropInfo("CCSPlayer", "m_bHasHelmet"), 0);
            }
        }
    }
}

public ConfigureHealth() {
    int HealthInt = StringToInt(Health);
    if (HealthInt != 100) {
        for (int client = 1; client < MaxClients; client++) {
            if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                if (!g_Zombies || GetClientTeam(client) == CS_TEAM_T) {
                    SetEntityHealth(client, HealthInt);
                }
            }
        }
    } else {
        for (int client = 1; client < MaxClients; client++) {
            if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                int actualHealth = GetEntProp(client, Prop_Send, "m_iHealth");
                if (actualHealth != 100) {
                    SetEntityHealth(client, 100);
                }
            }
        }
    }
}

public ConfigureDecoySound() {
    if (StrEqual(DecoySound, "1")) {
		g_DecoySound = true;
	} else {
		g_DecoySound = false;
	}
}

public ConfigureNoKnife() {
    if (StrEqual(NoKnife, "1")) {
        SetKnife(false);
    } else {
        SetKnife(true);
    }
}

public ConfigureInfiniteAmmo() {
    if (StrEqual(InfiniteAmmo, "1") || StrEqual(InfiniteAmmo, "2")) {
		new SetAmmoInt = StringToInt(InfiniteAmmo);
		SetConVarInt(sv_infinite_ammo, SetAmmoInt, true, false);
	} else {
		new currentInfiniteAmmo = GetConVarInt(sv_infinite_ammo);
		if (currentInfiniteAmmo > 0) {
			SetConVarInt(sv_infinite_ammo, 0, true, false);
		}
	}
}

public ConfigureInfiniteNades() {
    if (StrEqual(InfiniteNade, "1")) {
		g_InfiniteNade = true;
	} else {
		g_InfiniteNade = false;
	}
}

public ConfigureSpeed() {
    new Float:newPlayerSpeed = StringToFloat(PlayerSpeed);
    for (int client = 1; client < MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", newPlayerSpeed);
        }
    }
}

public ConfigureGravity() {
    new newPlayerGravity = StringToInt(PlayerGravity);

	if (newPlayerGravity != 800) {
		SetConVarInt(sv_gravity, newPlayerGravity, true, false);
	} else {
		new currentGravity = GetConVarInt(sv_gravity);
		if (currentGravity != 800) {
			SetConVarInt(sv_gravity, 800, true, false);
		}
	}
}

public ConfigureNoRecoil() {
    if (StrEqual(NoRecoil, "1")) {
		if (weapon_accuracy_nospread != INVALID_HANDLE) {
			SetConVarInt(weapon_accuracy_nospread, 1, true, false);
			SetConVarInt(weapon_recoil_cooldown, 0, true, false);
			SetConVarInt(weapon_recoil_decay1_exp, 99999, true, false);
			SetConVarInt(weapon_recoil_decay2_exp, 99999, true, false);
			SetConVarInt(weapon_recoil_decay2_lin, 99999, true, false);
			SetConVarInt(weapon_recoil_scale, 0, true, false);
			SetConVarInt(weapon_recoil_suppression_shots, 500, true, false);
		}
	} else {
		new currentWeaponAccuracy = GetConVarInt(weapon_accuracy_nospread);
		if (currentWeaponAccuracy != 0) {
			SetConVarInt(weapon_accuracy_nospread, 0, true, false);
			SetConVarFloat(weapon_recoil_cooldown, 0.55, true, false);
			SetConVarFloat(weapon_recoil_decay1_exp, 3.5, true, false);
			SetConVarInt(weapon_recoil_decay2_exp, 8, true, false);
			SetConVarInt(weapon_recoil_decay2_lin, 18, true, false);
			SetConVarInt(weapon_recoil_scale, 2, true, false);
			SetConVarInt(weapon_recoil_suppression_shots, 4, true, false);
		}
	}
}

public ConfigureNoScope() {
    if (StrEqual(NoScope, "1")) {
		g_NoScope = true;
	} else {
		g_NoScope = false;
	}
}

public ConfigureVampire() {
    if (StrEqual(Vampire, "1")) {
		g_Vampire = true;
	} else {
		g_Vampire = false;
	}
}

public ConfigurePlayerColors() {
    int colorR = 255;
	int colorG = 255;
	int colorB = 255;

	bool setNewColor = false;
	if (StrEqual(PColor, "black")) {
		colorR = 0;
		colorG = 0;
		colorB = 0;
		setNewColor = true;
	} else if (StrEqual(PColor, "pink")) {
		colorR = 255;
		colorG = 0;
		colorB = 255;
		setNewColor = true;
	}

	for (int client = 1; client < MaxClients; client++) {
		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            if (setNewColor) {
                SetEntityRenderColor(client, colorR, colorG, colorB, 0);
            } else {
                SetEntityRenderColor(client, 255, 255, 255, 0);
            }
		}
	}
}

public ConfigureBackwards() {
    if (StrEqual(Backwards, "1")) {
		SetConVarInt(sv_accelerate, -5, true, false);
        SetConVarFloat(sv_airaccelerate, -0.5, true, false);
	} else {
		new currentAccelerate = GetConVarInt(sv_accelerate);
		if (currentAccelerate != 5.5) {
			SetConVarFloat(sv_accelerate, 5.5, true, false);
            SetConVarInt(sv_airaccelerate, 12, true, false);
		}
	}
}

public ConfigureFov() {
    new newFov = StringToInt(Fov);

    for (int client = 1; client < MaxClients; client++) {
        if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
            SetEntProp(client, Prop_Send, "m_iDefaultFOV", newFov);
			SetEntProp(client, Prop_Send, "m_iFOV", newFov);
        }
    }
}

public ConfigureChickenDefuse() {
    if (StrEqual(ChickenDefuse, "1")) {
		g_ChickenDefuse = true;
	} else {
		g_ChickenDefuse = false;
	}
}

public ConfigureHeadshotOnly() {
    if (StrEqual(HeadShot, "1")) {
		g_HeadShot = true;
	} else {
		g_HeadShot = false;
	}
}

public ConfigureSlowMotion() {
    if (StrEqual(SlowMotion, "1")) {
		g_SlowMotion = true;
        CreateTimer(1.0, SlowMotionTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	} else {
		g_SlowMotion = false;
	}
}

public ConfigureWeirdRecoilView() {
    new Float:newRecoilView = StringToFloat(RecoilView);

	SetConVarFloat(weapon_recoil_view_punch_extra, newRecoilView, true, false);
}

public ConfigureFriction() {
    if (StrEqual(AlwaysMove, "1")) {
		SetConVarInt(sv_friction, -1, true, false);
	} else {
		SetConVarFloat(sv_friction, 5.2, true, false);
	}
}

public ConfigureDropWeapons() {
    if (StrEqual(DropWeapons, "1")) {
        g_DropWeapons = true;
        for (int client = 1; client < MaxClients; client++) {
            if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                CreateNewDropWeaponsTimer(client);
            }
        }
        CreateTimer(5.0, DropWeaponsTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    } else {
        g_DropWeapons = false;
    }
}

public ConfigureOneInTheChamber() {
    if (StrEqual(OneInTheChamber, "1")) {
        g_OneInTheChamber = true;
        for (int client = 1; client < MaxClients; client++) {
            if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                SetClipAmmo(client, 1);
            }
        }
        CreateTimer(0.1, SetWeaponAmmo, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    } else {
        g_OneInTheChamber = false;
    }
}

public ConfigureLeader() {
    if (StrEqual(Leader, "1")) {
        g_Leader = true;
        SetLeader(CS_TEAM_CT);
        SetLeader(CS_TEAM_T);
        SendLeaderMessage(CS_TEAM_CT);
        SendLeaderMessage(CS_TEAM_T);

        int freezeTime = GetConVarInt(mp_freezetime);
        CreateTimer(freezeTime + 3.0, StartLeaderTimer);
    } else {
        g_Leader = false;
    }
}

public ConfigureAllOnMap() {
    if (StrEqual(AllOnMap, "1")) {
        SetConVarInt(mp_radar_showall, 1, true, false);
    } else {
        SetConVarInt(mp_radar_showall, 0, true, false);
    }
}

public ConfigureInvisible() {
    if (StrEqual(Invisible, "1")) {
        for (int client = 1; client < MaxClients; client++) {
    		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                SetEntityRenderMode(client, RENDER_NONE);
            }
        }
    } else {
        for (int client = 1; client < MaxClients; client++) {
    		if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                SetEntityRenderMode(client, RENDER_NORMAL);
            }
        }
    }
}

public ConfigureAxeFists() {
    if (StrEqual(Axe, "1")) {
        g_Axe = true;
        CreateTimer(1.0, CheckAxeFistsTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    } else if (StrEqual(Fists, "1")) {
        g_Fists = true;
        CreateTimer(1.0, CheckAxeFistsTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    } else {
        g_Axe = false;
        g_Fists = false;
    }
}

public ConfigureBuddySystem() {
    if (StrEqual(BuddySystem, "1")) {
        g_BuddySystem = true;
        for (int client = 1; client < MaxClients; client++) {
            if (IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client)) {
                new chicken = CreateEntityByName("chicken");
                float playerPos[3];
                GetEntPropVector(client, Prop_Send, "m_vecOrigin", playerPos);

                DispatchSpawn(chicken);
                SetEntProp(chicken, Prop_Send, "m_fEffects", 0);
                // Teleport chicken to player
                TeleportEntity(chicken, playerPos, NULL_VECTOR, NULL_VECTOR);

                // Set chicken to follow player
                SetEntPropEnt(chicken, Prop_Send, "m_leader", client);

                // Store client and chicken
                new String:playerIdString[64];
                IntToString(client, playerIdString, sizeof(playerIdString));
                chickenMap.SetValue(playerIdString, chicken);
            }
        }
        // Create timer to enforce leader of chicken
        CreateTimer(0.1, BuddyTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    } else {
        g_BuddySystem = false;
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, "chicken")) != -1) {
            int ref = EntIndexToEntRef(ent);

            /* Fire an input on this entity - We use the reference version since this includes a serial check */
            AcceptEntityInput(ref, "Kill");
        }
        chickenMap.Clear();
    }
}

public ConfigureRandomNade() {
    if (StrEqual(RandomNade, "1")) {
        g_RandomNade = true;
    } else {
        g_RandomNade = false;
    }
}

public ConfigureZombies() {
    if (StrEqual(Zombies, "1")) {
        g_Zombies = true;
    } else {
        g_Zombies = false;
    }
}

public ConfigureTeleport() {
    if (StrEqual(Teleport, "1")) {
        g_Teleport = true;
    } else {
        g_Teleport = false;
    }
}

public ConfigureRedGreen() {
    if (StrEqual(RedGreen, "1")) {
        g_RedGreen = true;
        CreateTimer(0.5, RedGreenDamageTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
        CreateNewRedGreenTimer();
    } else {
        g_RedGreen = false;
        g_RedLight = false;
        positionMap.Clear();
    }
}

public ConfigureManhunt() {
    if (StrEqual(Manhunt, "1")) {
        g_Manhunt = true;
        SetLeader(CS_TEAM_CT);
        SetLeader(CS_TEAM_T);
        SendManhuntMessage(CS_TEAM_CT);
        SendManhuntMessage(CS_TEAM_T);
    } else {
        g_Manhunt = false;
    }
}

public ConfigureWinner() {
    if (StrEqual(Winner, "t")) {
        SetConVarInt(mp_default_team_winner_no_objective, 2, true, false);
    } else if (StrEqual(Winner, "draw")) {
        SetConVarInt(mp_default_team_winner_no_objective, 1, true, false);
    } else {
        SetConVarInt(mp_default_team_winner_no_objective, 3, true, false);
    }
}

public ConfigureHotPotato() {
    if (StrEqual(HotPotato, "1")) {
        g_HotPotato = true;
        ctLeader = -1;
        int freezeTime = GetConVarInt(mp_freezetime);

        CreateTimer(freezeTime + 10.0, NewHotPotatoTimer);
    } else {
        g_HotPotato = false;
    }
}

public ConfigureKillRound() {
    if (StrEqual(KillRound, "1")) {
        g_KillRound = true;
        SetConVarInt(mp_ignore_round_win_conditions, 1, true, false);
    } else {
        g_KillRound = false;
        SetConVarInt(mp_ignore_round_win_conditions, 0, true, false);
    }
}
