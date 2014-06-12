{ include( "framework.asl" ) }

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
	//<-
	//!keeper;
	.

/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!init
	<-
	!map_12;
	if ( map_12( yes ) ) {
		.println( "I'm at map 12!!" );
		-+patrollingRadius( 140 );
	}
	.