
{ include( "framework.asl" ) }

{ include( "fw_distance.asl" ) }

/**
 * Notifies other agents in team that an enemy has been found at given position.
 */
+!notify_enemy_at_position( P )
	<-
	// Get current agent's team.
	?team( Myteam );
	// Get list of other members of his team.
	.my_team( Myteam, E );
	// Create new belief, to be sent soon.
	.concat( "enemy_at_pos(", P, ")", Messg );
	// Send it to members of the team.
	.send_msg_with_conversation_id( E, tell, Messg, "INT" )
	.

/**
 * Reacts to an incoming beliefs about the position of an enemy.
 */
+enemy_at_pos( pos( X, Y, Z ) )
	<-
	
	//Don't interrupt an agent that is pursuing and enemy
	?aimed(Aiming);
	if(Aiming == "false"){
		// Get distance from my position to target's.
		!fw_distance( pos( X, Y, Z ) );
		?fw_distance( D );
		// If enemy is near enough...
		if ( D < 60 ) {
			// Get him!
			!fw_add_task(
				task(
					7500,
					"TASK_GOTO_POSITION_KILL",
					M,
					pos(
						X,
						Y,
						Z
					),
					""
				)
			);
		} else {
			// Go to flag just in case...
			?objective( Ox, Oy, Oz );
			!fw_add_task(
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
		}
	}
	.