/*******************************
*
* Actions definitions
*
*******************************/

/////////////////////////////////
/// CUSTOM ACTIONS
/////////////////////////////////

vigil_direction( 1 ).
search_radius( 4 ).
alreadySaid( "NO" ).
blind_march( "NO" ).

/**
 * Se pone a seguir a un agente del equipo dado.
 */
+!search_commander(O) : shouldContinue("YES") & blind_march("NO")
	<-
	?search_radius( R );
	?my_position( X, Y, Z );
	RX = math.round( X );
	RZ = math.round( Z );

	if ( O == 4 ) {
		-+vigil_direction( 1 );
	} else {
		-+vigil_direction( O + 1 );
	}

	if ( O == 1 ) {
		Xp = RX - R;
		Zp = RZ;
	}

	if ( O == 2 ) {
		Xp = RX;
		Zp = RZ + R;
	}

	if ( O == 3 ) {
		Xp = RX + R;
		Zp = RZ;
	}

	if ( O == 4 ) {
		Xp = RX;
		Zp = RZ - R;
	}

	!fw_add_task(
		task(
			7501,
			"TASK_GOTO_POSITION_2",
			M,
			pos(
				Xp,
				0,
				Zp
			),
			""
		)
	)
	.

+!search_commander( O )
	<-
	!check_task_end
	.

+cmdpos( Equis, Igrega, Ceta )[ source( S ) ] : blind_march( "NO" )
	<-
	if( Equis > 0 & Ceta > 0 ) {
		+commander( S );
		-+tasks( [] );
		!fw_add_task(
			task(
				9999,
				"TASK_GOTO_POSITION_ORDER",
				M,
				pos(
					Equis,
					0,
					Ceta
				),
				""
			)
		);
		?alreadySaid(Yn);
		if( Yn == "YES" ){
			-+blind_march("YES");
		}
		-+alreadySaid( "NO" );
	}
	.

+!cmdpos( Ex, Yg, Zt ) .

+objective( Ex, Yg, Zt ) : cmdpos( Cx, Cy, Cz )
	<-
	tasks( [] );
	-+blind_march( "YES" );
	!fw_add_task(
		task(
			4000,
			"TASK_GET_TO_BASE",
			M,
			pos(
				Ex,
				0,
				Zt
			),
			""
		)
	);
	!cover_me
	.

+!cover_me <-
	wait( 5000 );
	.my_team( "ALLIED", E );
	?my_position( X, Y, Z );
	?tasks( T );
	.concat( "flagpos(", X, ",", 0, ",", Z, ")", Messg );
	.send_msg_with_conversation_id( E, tell, Messg, "INT" );
	!cover_me
	.
	
+shouldContinue( "YES" ) : blind_march( "YES" )
	<-
	?objective(Ox, Oy, Oz);
	!fw_add_task(
		task(
			5000,
			"TASK_GET_THE_FLAG",
			M,
			pos(
				Ox,
				0,
				Oz
			),
			""
		)
	)
	.

+shouldContinue( "YES" ) : alreadySaid( "NO" ) & cmdpos( Cx, Cy, Cz ) & Cx > 0 & Cz > 0 & blind_march( "NO" )
	<-
	?commander( A );
	.concat( "soldierIsReady", Messg );
	.send_msg_with_conversation_id( A, tell, Messg, "INT" );
	-+alreadySaid( "YES" )
	.

/**
 * "Callback" que se ejecuta cada vez que el agente percibe objetos en su punto
 * de vista.
 */
+!perform_look_action_follow_agent : following( TEAM ) & TEAM > 0
	<-
	?fovObjects( FOVObjects );
	.length( FOVObjects, L );
	+auxC( 0 );
	+targetFound( "NO" );
	while ( auxC( C ) & L > C & targetFound( "NO" ) ) {
		.nth( C, FOVObjects, A );
		.nth( 1, A, Equipo );
		if ( Equipo == TEAM ) {
			.nth( 6, A, Posicion);
			!fw_add_task(
				task(
					3000,
					"TASK_GOTO_POSITION_2",
					M,
					Posicion,
					""
				)
			);
			-+targetFound( "SI" );
		}
		-+auxC( C + 1 );
	}
	-auxC( _ );
	-targetFound( _ )
	.

+!perform_look_action_follow_agent .

/**
* Action to do when the agent is looking at.
*
* This plan is called just after Look method has ended.
*
* <em> It's very useful to overload this plan. </em>
*
*/
+!perform_look_action : position_bug
	<-
	-+state( standing );
	-+tasks( [] );
	-position_bug
	.

+!perform_look_action .
	// can overload again

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
	?my_position( X, Y, Z );
	if ( X == 0 & Z == 0 ) {
		+position_bug;
	} else {
		?vigil_direction( D );
		!search_commander( D );
	}
	.

/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!init .
