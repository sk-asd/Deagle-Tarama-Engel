#include <sdktools>
#include <sdkhooks>
#include <cstrike>
ConVar g_HS_Aktif = null, g_QQ_Aktif = null;
public Plugin myinfo = 
{
	name = "Deagle QQ - Sadece HS", 
	description = "Deagle QQ - Sadece HS", 
	author = "phiso", 
	version = "3.1", 
	url = "forum.pluginmerkezi.com"
};
public void OnMapStart()
{
	char mapname[512];
	GetCurrentMap(mapname, sizeof(mapname));
	if (StrContains(mapname, "awp", false))
	{
		SetFailState("[DEAGLE QQ - SADECE HS] Bu eklenti sadece awp maplerinde calismaktadir.");
	}
}
public void OnPluginStart()
{
	HookEvent("weapon_fire", Weapon_Fire, EventHookMode_Post);
	g_QQ_Aktif = CreateConVar("qq", "1", "Deaglede QQ Olup Olmadığını ayarlamanıza yarar.", 0, true, 0.0, true, 1.0);
	g_HS_Aktif = CreateConVar("sadecehs", "0", "Deaglede Sadece HS Olup Olmadığını ayarlamanıza yarar.", 0, true, 0.0, true, 1.0);
	AutoExecConfig(true, "deagle_tarama");
}
public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
public Action Weapon_Fire(Event event, const char[] name, bool dontBroadcast)
{
	if (g_QQ_Aktif.BoolValue)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		if (IsValidClient(client))
		{
			char SilahIsmi[64];
			GetClientWeapon(client, SilahIsmi, sizeof(SilahIsmi));
			if (StrEqual(SilahIsmi, "weapon_deagle", true))
			{
				ClientCommand(client, "lastinv");
				CreateTimer(0.05, Lastinv, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}
public Action Lastinv(Handle Timer, any data)
{
	int client = GetClientOfUserId(data);
	ClientCommand(client, "lastinv");
}
public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (IsValidClient(victim) && IsValidClient(attacker))
	{
		if (g_HS_Aktif.BoolValue)
		{
			char SilahIsmi[64];
			GetClientWeapon(attacker, SilahIsmi, sizeof(SilahIsmi));
			if (StrEqual(SilahIsmi, "weapon_deagle", true))
			{
				if (!(damagetype & CS_DMG_HEADSHOT))
				{
					damage = 0.0;
					return Plugin_Changed;
				}
			}
		}
	}
	return Plugin_Continue;
}
bool IsValidClient(int client)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client)) || IsClientSourceTV(client) || IsClientReplay(client))
	{
		return false;
	}
	return true;
}