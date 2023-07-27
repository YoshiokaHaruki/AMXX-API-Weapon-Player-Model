#if defined _api_wpn_player_included
	#endinput
#endif
#define _api_wpn_player_included

/**
 * Sets the Weapon Player Model
 * 
 * @param pPlayer			Player Index
 * @param szModel			Model Path
 * @param iBody				Body value on Model
 * @param iSkin				Skin value on Model
 * @param iSequence			Sequence value on Model
 * @param flAttachment		How much to move the attachment in units (from -25.0 to 25.0)
 * 							An array is used, so the first value will move the first attachment,
 * 							the second value will move the second attachment
 * 
 * @return					Returns 'true' if the model has been updated 
 */
native bool: api_wpn_player_model_set( const pPlayer, const szModel[ ] = "", const iBody = 0, const iSkin = 0, const iSequence = 0, const Float: flAttachment[ ] = { 0.0, 0.0 } );

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

/**
 * API Weapon Player Model Version
 */

#define WPM_VERSION_MAJOR       1
#define WPM_VERSION_MINOR       1
#define WPM_VERSION_PATCH       1
#define WPM_VERSION_STRING      "1.1.1"

public __wpm_version_check( const iMajorVersion, const iMinorVersion )
{
	if ( iMajorVersion != WPM_VERSION_MAJOR )
	{
		new szTempBuffer[ 128 ];
		formatex( szTempBuffer, charsmax( szTempBuffer ), "[Weapon Player Model]: Api major version mismatch; expected %d, real %d", WPM_VERSION_MAJOR, iMajorVersion );
		set_fail_state( szTempBuffer );
		
		return;
	}

	if ( iMinorVersion < WPM_VERSION_MINOR )
	{
		new szTempBuffer[ 128 ];
		formatex( szTempBuffer, charsmax( szTempBuffer ), "[Weapon Player Model]: Api minor version mismatch; expected at least %i, real %i", WPM_VERSION_MINOR, iMinorVersion );
		set_fail_state( szTempBuffer );

		return;
	}
}