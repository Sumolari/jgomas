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
	while( auxpla( C ) & C < L & auxtargetfoundpla( "NO" ) ) {
		.nth( C, FOVObjects, A );
		.nth( 1, A, Equipo );
		if ( Equipo == 100 ) {
			.nth( 6, A, Posicion);
			!notify_enemy_at_position( Posicion );
			!fw_add_task(
				task(
					3000,
					"TASK_GOTO_POSITION_2",
					M,
					Posicion,
					""
				)
			);
			-+auxtargetfoundpla( "SI" );
		}
		-+auxpla( C + 1 );
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