new const PluginName[ ] =				"[API] Addon: Weapon Player Model";
new const PluginAuthor[ ] =				"Yoshioka Haruki";

/* ~ [ Includes ] ~ */
#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <api_weapon_player_model>

/**
 * If ur server can't use Re modules, just comment out or delete this line
 */
#include <reapi>

#if !defined _reapi_included
	#include <non_reapi_support>
#endif

/* ~ [ Plugin Settings ] ~ */
/**
 * Hide th Weapon Player Model each Deploy.
 * 
 * You will not have such that for some reason there is a model that you no longer have,
 * However, the call to the "CBasePlayer__WeaponPlayerModel" function will be called 1 time more.
 * 
 * When using this parameter, you will have to use the
 * native "api_wpn_player_model_hide" when removing the weapon you need.
 */
#define HidePlayerModelEachDeploy

/**
 * Hide the Weapon Player Model if the player is dead.
 */
#define HidePlayerModelWhenDie

/**
 * Allow third-person attachments to be moved
 * NB! Uses an additional model
 */
#define CanMoveAttachments

new const PluginPrefix[ ] =				"API:WPM";
new const EntityReference[ ] =			"info_target";
new const EntityClassName[ ] =			"ent_weapon_pmodel";

#if defined CanMoveAttachments
	new const WeaponPlayerModel[ ] =	"models/p_null.mdl";
	new const Float: AttachmentMoveMinMax[ ] = {
		-25.0, 25.0
	};
#endif

/* ~ [ Params ] ~ */
new gl_pWeaponPlayerModel[ MAX_PLAYERS + 1 ];

/* ~ [ Macroses ] ~ */
#if !defined MAX_RESOURCE_PATH_LENGTH
	#define MAX_RESOURCE_PATH_LENGTH	64
#endif

#define IsNullString(%0)				bool: ( %0[ 0 ] == EOS )

/* ~ [ AMX Mod X ] ~ */
public plugin_natives( )
{
	register_native( "api_wpn_player_model_set",	"native_wpn_player_model_set" );
	register_native( "api_wpn_player_model_get",	"native_wpn_player_model_get" );
	register_native( "api_wpn_player_model_hide",	"native_wpn_player_model_hide" );
	register_native( "api_wpn_player_model_show",	"native_wpn_player_model_show" );
	register_native( "api_wpn_player_model_remove",	"native_wpn_player_model_remove" );
}

#if defined CanMoveAttachments
	public plugin_precache( )
	{
		/* -> Precache Models <- */
		engfunc( EngFunc_PrecacheModel, WeaponPlayerModel );
	}
#endif

public plugin_init( )
{
	register_plugin( PluginName, WPM_VERSION_STRING, PluginAuthor );

#if defined _reapi_included
	/* -> ReGameDLL <- */
	#if defined HidePlayerModelEachDeploy
		RegisterHookChain( RG_CBasePlayerWeapon_DefaultDeploy, "CBasePlayerWeapon_Deploy_Pre", false );
	#endif

	#if defined HidePlayerModelWhenDie
		RegisterHookChain( RG_CBasePlayer_Killed, "CBasePlayer_Killed_Post", true );
	#endif
#else
	/* -> HamSandwich <- */
	#if defined HidePlayerModelEachDeploy
		new WeaponReferences[ ][ ] = {
			"weapon_p228", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4",
			"weapon_mac10", "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", 
			"weapon_ump45", "weapon_sg550", "weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", 
			"weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1", "weapon_tmp", 
			"weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", "weapon_ak47", 
			"weapon_knife", "weapon_p90"
		};

		for ( new i = 0, iIterations = sizeof WeaponReferences; i < iIterations; i++ )
			RegisterHam( Ham_Item_Deploy, WeaponReferences[ i ], "CBasePlayerWeapon_Deploy_Pre", false );
	#endif

	#if defined HidePlayerModelWhenDie
		RegisterHam( Ham_Killed, "player", "CBasePlayer_Killed_Post", true );
	#endif
#endif
}

public plugin_cfg( )
{
	/* -> Register Cvar's <- */
#if AMXX_VERSION_NUM <= 182
	register_cvar( "API_Weapon_Player_Model", WPM_VERSION_STRING, ( FCVAR_SERVER | FCVAR_SPONLY | FCVAR_UNLOGGED ) );
#else
	create_cvar( "API_Weapon_Player_Model", WPM_VERSION_STRING, ( FCVAR_SERVER | FCVAR_SPONLY | FCVAR_UNLOGGED ) );
#endif

	/* -> Check Version <- */
	new fwReturn;
	ExecuteForward( CreateMultiForward( "__wpm_version_check", ET_IGNORE, FP_CELL, FP_CELL ), fwReturn, WPM_VERSION_MAJOR, WPM_VERSION_MINOR );
}

public client_putinserver( pPlayer ) CBasePlayer__InitPlayerModel( pPlayer );

#if AMXX_VERSION_NUM <= 182
	public client_disconnect( pPlayer ) CBasePlayer__RemovePlayerModel( pPlayer );
#else
	public client_disconnected( pPlayer ) CBasePlayer__RemovePlayerModel( pPlayer );
#endif

/* ~ [ ReGameDLL / HamSandwich ] ~ */
#if defined HidePlayerModelEachDeploy
	public CBasePlayerWeapon_Deploy_Pre( const pItem )
	{
		new pPlayer = get_member( pItem, m_pPlayer );
		if ( !is_user_alive( pPlayer ) )
			return;

		CBasePlayer__WeaponPlayerModel( pPlayer );
	}
#endif

#if defined HidePlayerModelWhenDie
	public CBasePlayer_Killed_Post( const pVictim ) CBasePlayer__WeaponPlayerModel( pVictim );
#endif

/* ~ [ Other ] ~ */
public bool: CBasePlayer__InitPlayerModel( const pPlayer )
{
	gl_pWeaponPlayerModel[ pPlayer ] = rg_create_entity( EntityReference );

	if ( !is_nullent( gl_pWeaponPlayerModel[ pPlayer ] ) )
	{
		set_entvar( gl_pWeaponPlayerModel[ pPlayer ], var_classname, EntityClassName );
		set_entvar( gl_pWeaponPlayerModel[ pPlayer ], var_movetype, MOVETYPE_FOLLOW );
		set_entvar( gl_pWeaponPlayerModel[ pPlayer ], var_owner, pPlayer );
		set_entvar( gl_pWeaponPlayerModel[ pPlayer ], var_aiment, pPlayer );

		return true;
	}

	return false;
}

bool: CBasePlayer__WeaponPlayerModel( const pPlayer, const szModel[ ] = "", const iBody = 0, const iSkin = 0, const iSequence = 0, const Float: flAttachment[ ] = { 0.0, 0.0 } )
{
	if ( is_nullent( gl_pWeaponPlayerModel[ pPlayer ] ) )
	{
		if ( !CBasePlayer__InitPlayerModel( pPlayer ) )
			return false;
	}

	new bitsEffects = get_entvar( gl_pWeaponPlayerModel[ pPlayer ], var_effects );
	if ( Float: get_entvar( pPlayer, var_renderamt ) <= 0.0 || IsNullString( szModel ) )
		bitsEffects |= EF_NODRAW;
	else
	{
		bitsEffects &= ~EF_NODRAW;
		engfunc( EngFunc_SetModel, gl_pWeaponPlayerModel[ pPlayer ], szModel );

		set_entvar( gl_pWeaponPlayerModel[ pPlayer ], var_body, iBody );
		set_entvar( gl_pWeaponPlayerModel[ pPlayer ], var_skin, iSkin );
		set_entvar( gl_pWeaponPlayerModel[ pPlayer ], var_sequence, iSequence );
		set_entvar( gl_pWeaponPlayerModel[ pPlayer ], var_frame, 0.0 );
		set_entvar( gl_pWeaponPlayerModel[ pPlayer ], var_framerate, 1.0 );
		set_entvar( gl_pWeaponPlayerModel[ pPlayer ], var_animtime, get_gametime( ) );

	#if defined CanMoveAttachments
		set_entvar( pPlayer, var_weaponmodel, WeaponPlayerModel );

		UTIL_MoveController( pPlayer, 0, flAttachment[ 0 ], AttachmentMoveMinMax );
		UTIL_MoveController( pPlayer, 1, flAttachment[ 1 ], AttachmentMoveMinMax );
	#endif
	}

	set_entvar( gl_pWeaponPlayerModel[ pPlayer ], var_effects, bitsEffects );

	return true;
}

public bool: CBasePlayer__RemovePlayerModel( const pPlayer )
{
	new pEntity = gl_pWeaponPlayerModel[ pPlayer ];
	gl_pWeaponPlayerModel[ pPlayer ] = NULLENT;

	if ( !is_nullent( pEntity ) )
	{
		set_entvar( pEntity, var_flags, FL_KILLME );
		set_entvar( pEntity, var_nextthink, get_gametime( ) );
		
		return true;
	}

	return false;
}

/* ~ [ Natives ] ~ */
public bool: native_wpn_player_model_set( const iPlugin, const iParams )
{
	enum { arg_player = 1, arg_model, arg_body, arg_skin, arg_sequence, arg_attachment };

	new pPlayer = get_param( arg_player );
	if ( !is_user_alive( pPlayer ) )
	{
		log_error( AMX_ERR_NATIVE, "[%s | SET] Invalid Player (Id: %i)", PluginPrefix, pPlayer );
		return false;
	}

	new szModel[ MAX_RESOURCE_PATH_LENGTH ];
	get_string( arg_model, szModel, charsmax( szModel ) );

	new Float: flAttachment[ 2 ];
	get_array_f( arg_attachment, flAttachment, 2 );

	return CBasePlayer__WeaponPlayerModel( pPlayer, szModel, get_param( arg_body ), get_param( arg_skin ), get_param( arg_sequence ), flAttachment );
}

public native_wpn_player_model_get( const iPlugin, const iParams )
{
	enum { arg_player = 1 };

	new pPlayer = get_param( arg_player );
	if ( !is_user_alive( pPlayer ) )
	{
		log_error( AMX_ERR_NATIVE, "[%s | GET] Invalid Player (Id: %i)", PluginPrefix, pPlayer );
		return -1;
	}

	return gl_pWeaponPlayerModel[ pPlayer ];
}

public bool: native_wpn_player_model_hide( const iPlugin, const iParams )
{
	enum { arg_player = 1 };

	new pPlayer = get_param( arg_player );
	if ( !is_user_alive( pPlayer ) )
	{
		log_error( AMX_ERR_NATIVE, "[%s | HIDE] Invalid Player (Id: %i)", PluginPrefix, pPlayer );
		return false;
	}

	return CBasePlayer__WeaponPlayerModel( pPlayer );
}

public bool: native_wpn_player_model_show( const iPlugin, const iParams )
{
	enum { arg_player = 1 };

	new pPlayer = get_param( arg_player );
	if ( !is_user_alive( pPlayer ) )
	{
		log_error( AMX_ERR_NATIVE, "[%s | SHOW] Invalid Player (Id: %i)", PluginPrefix, pPlayer );
		return false;
	}

	if ( is_nullent( gl_pWeaponPlayerModel[ pPlayer ] ) )
		return false;

	set_entvar( gl_pWeaponPlayerModel[ pPlayer ], var_effects, get_entvar( gl_pWeaponPlayerModel[ pPlayer ], var_effects ) & ~EF_NODRAW );
	return true;
}

public bool: native_wpn_player_model_remove( const iPlugin, const iParams )
{
	enum { arg_player = 1 };

	new pPlayer = get_param( arg_player );
	if ( !is_user_alive( pPlayer ) )
	{
		log_error( AMX_ERR_NATIVE, "[%s | REMOVE] Invalid Player (Id: %i)", PluginPrefix, pPlayer );
		return false;
	}

	return CBasePlayer__RemovePlayerModel( pPlayer );
}

/* ~ [ Stocks ] ~ */
/* -> Move controller by values from model <- */
stock bool: UTIL_MoveController( const pEntity, const iController, Float: flValue = 0.0, const Float: flMinMaxValue[ 2 ] = { 0.0, 255.0 } )
{
	if ( is_nullent( pEntity ) )
		return false;

	flValue = floatclamp( flValue, flMinMaxValue[ 0 ], flMinMaxValue[ 1 ] );

	new Float: flLength = floatabs( flMinMaxValue[ 0 ] ) + flMinMaxValue[ 1 ];
	flValue = ( ( flLength / 2.0 + flValue ) / flLength ) * 255.0;

#if defined _reapi_included
	set_entvar( pEntity, var_controller, floatround( flValue ), iController );
#else
	set_pev( pEntity, pev_controller_0 + iController, floatround( flValue ) );
#endif

	return true;
}