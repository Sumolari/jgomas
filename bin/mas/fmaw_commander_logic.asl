/*******************************
*
* Actions definitions
*
*******************************/

/////////////////////////////////
/// CUSTOM ACTIONS
/////////////////////////////////

in_pos( false ).
everybodyReady( "YES" ).
in_position( "NO" ).
blind_march( "NO" ).
afterinit( "N" ).
inited( no ).

+!get_the_flag : everybodyReady( "YES" ) & in_position( "NO" ) & blind_march( "NO" )
	<-
	?objective( FlagX, FlagY, FlagZ );
	-+in_position( "YES" );
	-+my_objective( FlagX - 30, FlagY, FlagZ - 30 )
	.

+!get_the_flag .

+!to_the_flag
	<-
	-+my_objective( 0, 0, 0 );
	-my_objective( 0, 0, 0 );
	?objective( FlagX, FlagY, FlagZ );
	.concat( "cmdpos(", FlagX, ",", 0, ",", FlagZ, ")", Messg );
	.my_team( "ALLIED", E );
	.send_msg_with_conversation_id( E, tell, Messg, "INT" );
	!fw_add_task(
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
	)
	.

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

+!go_com_pos : shouldContinue( "YES" ) & everybodyReady( "YES" ) & my_objective( X, Y, Z ) & my_objective_old( Xx, Yy, Zz ) & ( X < Xx | Z < Zz | X > Xx | Z > Zz ) & blind_march( "NO" )
	<-
	.wait(1000);
	-+my_objective_old(X,Y,Z);

	!fw_add_task(
		task(
			7500,
			"TASK_GOTO_POSITION_3",
			M,
			pos(
				X,
				0,
				Z
			),
			""
		)
	);

	.my_team("ALLIED", E);

	.length( E, L );
	+auxC( 0 );
	+waitingFor( L );
	while ( auxC( C ) & C < L ) {
		.nth( C, E, Target );
		if ( C == 0 ) {
			.concat( "cmdpos(", X, ",", 0, ",", Z + 20, ")", Messg );
		}
		if ( C == 1 ) {
			.concat( "cmdpos(", X + 20, ",", 0, ",", Z, ")", Messg );
		}
		if ( C == 2 ) {
			.concat( "cmdpos(", X - 20, ",", 0, ",", Z, ")", Messg );
		}
		if ( C == 3 ) {
			.concat( "cmdpos(", X + 30, ",", 0, ",", Z - 20, ")", Messg );
		}
		if ( C == 4 ) {
			.concat( "cmdpos(", X - 30, ",", 0, ",", Z - 20, ")", Messg );
		}
		if ( C == 5 ) {
			.concat( "cmdpos(", X + 10, ",", 0, ",", Z - 20, ")", Messg );
		}
		if ( C == 6 ) {
			.concat( "cmdpos(", X - 10, ",", 0, ",", Z - 20, ")", Messg );
		}
		.send_msg_with_conversation_id( Target, tell, Messg, "INT" );
		-+auxC( C + 1 );
	}
	.at( "now +30 s", {+!no_more_waiting} )
	.

+!go_com_pos <-
	!check_task_end
	.
	
+!no_more_waiting <-
	// .at does not accept conditional plans
	!no_more_waiting_2
	.
	
+!no_more_waiting_2 : waitingFor( Wa ) <-
	-+waitingFor(0)
	.

+!no_more_waiting_2 .

+soldierIsReady[ source( V ) ]
	<-
	?waitingFor( W );
	-+waitingFor( W - 1 );
	-soldierIsReady[ source( V ) ]
	.

+waitingFor( 0 ) : in_position( "YES" )
	<-
	-waitingFor( 0 );
	-+everybodyReady( "YES" );
	!to_the_flag
	.

+waitingFor( 0 )
	<-
	-waitingFor( 0 );
	-+everybodyReady( "YES" );
	!get_the_flag
	.

+waitingFor( W ) : W > 0
	<-
	-+everybodyReady( "NO" )
	.

+shouldContinue( "YES" ) .

/**
 * "Callback" que se ejecuta cada vez que el agente percibe objetos en su punto
 * de vista.
 */
+!perform_look_action_follow_agent : following( TEAM ) & TEAM > 0 & blind_march( "NO" ) <-
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
	!custom_init;
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
		!go_com_pos;
	}
	?debug(Mode)
	.

/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!custom_init : inited( no )
	<-
	?debug( Mode );
	?my_position( X, Y, Z );
	
	!map_12;
	
	if( math.round( X ) < 35 ){
		if( math.round( Z ) < 25 ){
			+my_objective( 40, Y, 30 );
		}
		else{
			+my_objective( 40, Y, math.round( Z ) );
		}
	}
	else{ 
		if( math.round( Z ) < 25 ){
			+my_objective( math.round( X ), Y, 30 );
		}
		else{
			+my_objective( math.round( X ), Y, math.round( Z ) );
		}
	}
	
	if( map_12( yes ) ){
		?objective(Fx, Fy, Fz);
		-+my_objective( Fx, Fy, Fz );
	}
	.

+!custom_init .

+!init 
	<-
	+my_objective_old( 0, 0, 0 );
	-+tasks( [] );
	.