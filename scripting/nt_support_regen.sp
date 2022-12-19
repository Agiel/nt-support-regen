#include <sourcemod>
#include <sdktools>
#include <neotokyo>

#pragma semicolon 1

#define PLUGIN_VERSION "1.0.1"

#define NEO_MAX_PLAYERS 32

public Plugin myinfo =
{
    name = "NEOTOKYO° Support Regen",
    author = "Agiel",
    description = "Gives Supports regenrating HP",
    version = PLUGIN_VERSION,
    url = "https://github.com/Agiel/nt-support-regen"
};

ConVar g_cvSupportRegen;
ConVar g_cvSupportRegenSpeed;
ConVar g_cvSupportRegenCooldown;

float g_fLastDamage[NEO_MAX_PLAYERS+1];
float g_fPlayerHealth[NEO_MAX_PLAYERS+1];

public void OnPluginStart()
{
    g_cvSupportRegen = CreateConVar("sm_support_regen", "80", "Regen up to how much HP.", _, true, 0.0, true, 100.0);
    g_cvSupportRegenSpeed = CreateConVar("sm_support_regen_speed", "2", "How much HP to regen per second.", _, true, 0.0, true, 100.0);
    g_cvSupportRegenCooldown = CreateConVar("sm_support_regen_cooldown", "10", "How many seconds after taking damage the regen kicks in.", _, true, 0.0, true, 60.0);

    for(int i = 1; i <= MaxClients; i++)
    {
        g_fPlayerHealth[i] = 100.0;
    }

    HookEvent("game_round_start", Event_Round_Start);
    HookEvent("player_hurt", Event_Player_Hurt);

    AutoExecConfig();
}

public void OnGameFrame()
{
    float regen = g_cvSupportRegen.FloatValue;
    float speed = g_cvSupportRegenSpeed.FloatValue;
    float cooldown = g_cvSupportRegenCooldown.FloatValue;

    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsValidClient(i) || !IsPlayerAlive(i))
            continue;

        if (GetPlayerClass(i) == CLASS_SUPPORT)
        {
            if (g_fPlayerHealth[i] <= regen && g_fLastDamage[i] + cooldown < GetGameTime())
            {
                g_fPlayerHealth[i] += speed * GetTickInterval();
                SetEntityHealth(i, RoundToFloor(g_fPlayerHealth[i]));
            }
        }
    }
}

public void Event_Round_Start(Event event, const char[] name, bool dontBroadcast)
{
    for(int i = 1; i <= MaxClients; i++)
    {
        g_fPlayerHealth[i] = 100.0;
    }
}

public void Event_Player_Hurt(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int health = event.GetInt("health");
    g_fLastDamage[victim] = GetGameTime();
    g_fPlayerHealth[victim] = float(health);
}
