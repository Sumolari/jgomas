
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
 * Ignore orders if I know where I should be.
 */
+enemy_at_pos( pos( X, Y, Z ) ) : keeper_position( Ox, Oy, Oz )
	<-
	.println( "Ignoring enemy notification..." );
	.

/**
 * Reacts to an incoming beliefs about the position of an enemy.
 */
+enemy_at_pos( pos( X, Y, Z ) )
	<-
	// Get distance from my position to target's.
	!fw_distance( pos( X, Y, Z ) );
	?fw_distance( D );
	// If enemy is near enough...
	if ( D < 80 & map_12( no ) ) {
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
		if ( map_12( yes ) ) {
			Aleatorio = math.random( 1 );
			.println( Aleatorio );
			if ( Aleatorio > 0.4 ) {
				.println( "Going to top-right" );
				// Go to where enemies will be...
				-+keeper_position( 230, 0, 108 );
			} else {
				.println( "Going to bottom-right" );
				// Go to where enemies will be...
				-+keeper_position( 215, 0, 150 );
			}
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