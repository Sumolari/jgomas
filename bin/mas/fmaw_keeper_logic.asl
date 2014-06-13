// Plans

/*******************************
*
* Actions definitions
*
*******************************/

/////////////////////////////////
/// CUSTOM ACTIONS
/////////////////////////////////

+!keeper
	<-
	//?keeper(P);
	?objective( Ox, Oy, Oz );
	?my_position( X, Y, Z );
	!add_task(
		task(
			3000,
			"TASK_GOTO_POSITION",
			M,
			pos(
				Ox, Oy, Oz
			),
			""
		)
	)
	.

/**
 * Action to do when the agent is looking at.
 *
 * This plan is called just after Look method has ended.
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!perform_look_action
	<-
	?fovObjects( FOVObjects );
	.length( FOVObjects, L );
	-+auxpla( 0 );
	-+auxtargetfoundpla( "NO" );
	-+enemies( [] );

	+bucle( 0 );
	while ( bucle( X ) & ( X < L ) ) {
		.nth( X, FOVObjects, Object );
		// Object structure
		// [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
		.nth( 2, Object, Type );

		if ( Type > 1000 ) {
		} else {
			// Object may be an enemy
			.nth( 1, Object, Team );
			?my_formattedTeam( MyTeam );

			if ( team( "ALLIED" ) ) {
				if ( Team == 200 ) {  // Only if I'm ALLIED
					?enemies( Enem );
					.concat( Enem, [Object], Enemigos );
					-+enemies( Enemigos );
				}
			} else {
				if ( Team == 100 ) {  // Only if I'm ALLIED
					?enemies( Enem );
					.concat( Enem, [Object], Enemigos );
					-+enemies( Enemigos );
				}
			}
		}
		-+bucle( X + 1 );
	}
	-bucle( _ );

	?enemies( Enem );
	.length( Enem, EnemLength );
	if( EnemLength > 0 ) {
		!fw_nearest( Enem );
		?fw_nearest( Cagent, PosAgent, D );
		.nth( 6, Cagent, NewDestination );
		
		!notify_enemy_at_position( NewDestination );
	}
	.

/////////////////////////////////
//  UPDATE TARGETS
/////////////////////////////////

/**
 * Action to do when an agent is thinking about what to do.
 *
 * This plan is called at the beginning of the state "standing"
 * The user can add or eliminate targets adding or removing tasks or changing
 * priorities
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!update_targets <- !keeper.

/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!init .