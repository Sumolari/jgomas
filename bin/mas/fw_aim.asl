/////////////////////////////////
//  GET AGENT TO AIM
/////////////////////////////////

/**
 * Calculates if there is an enemy at sight.
 *
 * This plan scans the list <tt> m_FOVObjects</tt> (objects in the Field
 * Of View of the agent) looking for an enemy. If an enemy agent is found, a
 * value of aimed("true") is returned. Note that there is no criterion (proximity, etc.) for the
 * enemy found. Otherwise, the return value is aimed("false")
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!get_agent_to_aim
	<-
	?fovObjects( FOVObjects );
	.length( FOVObjects, Length );
	if ( Length > 0 ) {
		+bucle( 0 );
		-+aimed( "false" );
		while ( aimed( "false" ) & bucle( X ) & ( X < Length ) ) {
			.nth( X, FOVObjects, Object );
			// Object structure
			// [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
			.nth( 2, Object, Type );

			if ( Type > 1000 ) {
			} else {
				// Object may be an enemy
				.nth( 1, Object, Team );
				?my_formattedTeam( MyTeam );

				?team( Equipo );

				if ( Equipo == "AXIS" ) {
					if ( Team == 100 ) { // Only if I'm AXIS
						+aimed_agent( Object );
						-+aimed( "true" );
					}
				} else {
					if ( Team == 200 ) { // Only if I'm ALLIED
						+aimed_agent( Object );
						-+aimed( "true" );
					}
				}
			}
			-+bucle( X + 1 );
		}
	}
	-bucle( _ ).


/////////////////////////////////
//  PERFORM ACTIONS
/////////////////////////////////

/**
 * Action to do when agent has an enemy at sight.
 *
 * This plan is called when agent has looked and has found an enemy,
 * calculating (in agreement to the enemy position) the new direction where
 * is aiming.
 *
 *  It's very useful to overload this plan.
 *
 */
+!perform_aim_action
	<-
	// Aimed agents have the following format:
	// [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
	?aimed_agent( AimedAgent );
	.nth( 1, AimedAgent, AimedAgentTeam );
	?my_formattedTeam( MyTeam );

	if ( AimedAgentTeam == 100 ) {
		.nth( 6, AimedAgent, NewDestination );
		//update_destination(NewDestination);
	}
	.