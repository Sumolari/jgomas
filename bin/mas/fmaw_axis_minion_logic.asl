{ include( "framework.asl" ) }

repositioned( no ).

/*******************************
*
* Actions definitions
*
*******************************/

/////////////////////////////////
/// CUSTOM ACTIONS
/////////////////////////////////

// To keep a position regardless any default behaviour.
+!keeper : map_12( yes ) & keeper_position( Ox, Oy, Oz )
	<-
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

+!keeper : map_13( yes ) & keeper_position( Ox, Oy, Oz )
	<-
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

// By default guard no position.
+!keeper .

// This belief triggers the guard.
+keeper_position( Ox, Oy, Oz )
	<-
	-+objective( Ox, Oy, Oz );
	!keeper;
	-+state( standing );
	.

/**
 * Action to do when the agent is looking at.
 *
 * This plan is called just after Look method has ended.
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!perform_look_action .

/////////////////////////////////
//  HACK TO TAKE THE ENEMIES
/////////////////////////////////

+!take_them : map_13( yes )
	<-
	.println( "Take them at enemy's spawn!" );
	// Go to where enemies will be...
	-+repositioned( yes );
	-+keeper_position( 153, 0, 153 );
	.

+!take_them
	<-
	.println( "THIS SHOULD NOT BE HAPPENING!" );
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
+!update_targets
	<-
	!map_12;
	!map_13;
	if ( map_12( yes ) ) {
		-+patrollingRadius( 20 );
	}
	if ( map_13( yes ) ) {
		if ( repositioned( no ) ) {
			.at( "now +30 s", {+!take_them} );
			?my_position( Myx, Myy, Myz );
			?objective( Ox, Oy, Oz );
			if ( Myx > Ox ) {
				-+keeper_position( 190, 0, 130 );
			} else { 
				-+keeper_position( 130, 0, 190 );
			}
			-+patrollingRadius( 30 );
		}
	}
	.

/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!init .