{ include( "framework.asl" ) }

/*******************************
*
* Actions definitions
*
*******************************/

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
+!update_targets .

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