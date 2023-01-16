#if defined _api_weapon_player_model_included
	#endinput
#endif
#define _api_weapon_player_model_included

/**
 * Sets the Weapon Player Model
 * 
 * @param pPlayer			Player Index
 * @param szModel			Model Path
 * @param iBody				Body value on Model
 * @param iSkin				Skin value on Model
 * @param iSequence			Sequence value on Model
 * 
 * @return					Returns 'true' if the model has been updated 
 */
native bool: api_wpn_player_model_set( const pPlayer, const szModel[ ] = "", const iBody = 0, const iSkin = 0, const iSequence = 0 );

/**
 * @param pPlayer			Player Index
 * 
 * @return					Return index of Weapon Player Model
 */
native api_wpn_player_model_get( const pPlayer );

/**
 * Hide the Weapon Player Model
 * 
 * @param pPlayer			Player Index
 * 
 * @return					Returns 'true' if the model has been hided
 */
native bool: api_wpn_player_model_hide( const pPlayer );

/**
 * Show the Weapon Player Model
 * 
 * @param pPlayer           Player Index
 * 
 * @return                  Returns 'true' if the model has been showed
 */
native bool: api_wpn_player_model_show( const pPlayer );

/**
 * Remove the Weapon Player Model
 * 
 * @param pPlayer			Player Index
 * 
 * @return					Returns 'true' if the model has been removed
 */
native bool: api_wpn_player_model_remove( const pPlayer );
