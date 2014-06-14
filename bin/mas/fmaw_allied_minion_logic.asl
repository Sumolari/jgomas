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
commander("nil").
indpendent_mode( "NO" ).
afterinit( "N" ).

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

+!go_to_valid_pos( X, Y, Z )
	<-
	+auxX(0);
	+auxZ(0);
	+auxPos(X, Y, Z);
	while( position( invalid ) ){
		-position(_);
		?auxX(Ax);
		?auxZ(Az);
		-+auxX(Ax+1);
		-+auxZ(Az+1);
		check_position( pos( X+Ax, Y, Z+Az ) );
	}
	?auxX(Ax);
	?auxZ(Az);
	.println("Finally going to ", X+Ax, " ", Z+Az);
	!fw_add_task(
		task(
			9999,
			"TASK_GOTO_POSITION_ORDER",
			M,
			pos(
				X+Ax,
				0,
				Z+Az
			),
			""
		)
	);
	-auxX(_);
	-auxZ(_);
	.

+!take_the_flag
	<-
	?objective( FlagX, FlagY, FlagZ );
	!fw_add_task(
		task(
			9999,
			"TASK_GOTO_POSITION_2",
			M,
			pos(
				FlagX,
				FlagY,
				FlagZ
			),
			""
		)
	)
	.

+cmdpos( Equis, Igrega, Ceta )[ source( S ) ] : indpendent_mode( "YES" )
	<-
	!take_the_flag
	.

+cmdpos( Equis, Igrega, Ceta )[ source( S ) ] : blind_march( "NO" )
	<-

	?alreadySaid(Yn);
	if( Yn == "YES" ){
		-+blind_march("YES");
	}
	-+alreadySaid( "NO" );

	+commander( S );
	-position( _ );
	check_position( pos( Equis, Igrega, Ceta ) );

	if ( position( invalid ) ) {
		.println( "entering invalid mode: ", pos( Equis, Igrega, Ceta ) );
		-+indpendent_mode( "YES" );
		-+shouldContinue("YES");
		!go_to_valid_pos( Equis, Igrega, Ceta );
	} else {
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
	}
	.

+!cmdpos( Ex, Yg, Zt ) .

+objective( Ex, Yg, Zt ) : afterinit( "Y" )
	<-
	tasks( [] );
	-+my_objective(Ex, Yg, Zt);
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
	.my_team( "ALLIED", E );
	?my_position( X, Y, Z );
	.concat( "flagpos(", X, ",", 0, ",", Z, ")", Messg );
	.send_msg_with_conversation_id( E, tell, Messg, "INT" );
	.at( "now +1 s", {+!cover_me} )
	.

+shouldContinue( "YES" ) : blind_march( "YES" )
	<-
	?my_objective(Ox, Oy, Oz);
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
+!perform_look_action_follow_agent : following( TEAM ) & TEAM > 0 & blind_march( "NO" )
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
	<-
	?my_position( X, Y, Z );
	-+afterinit( "Y" );
	?tasks(Ts);
	if ( map_12( yes ) ) {
		.length( Ts, Tl );
		if( Tl == 0 ){
			?objective( Fx, Fy, Fz );
			-+my_objective( Fx, Fy, Fz );
		}
		?my_objective( FlagX, FlagY, FlagZ );
		!add_task(
			task(
				1000,
				"TASK_GET_OBJECTIVE",
				M,
				pos(
					FlagX,
					0,
					FlagZ
				),
				""
			)
		);
	} else {
		?vigil_direction( D );
		!search_commander( D );
	}
	.

/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!init
	<-
	!map_12;
	
	?objective(Fx, Fy, Fz);
	+my_objective( Fx, Fy, Fz );
	.
