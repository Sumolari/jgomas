{ include( "framework.asl" ) }

{ include( "fw_distance.asl" ) }

maxDistToShoot( 15 ).
agent_in_the_middle( _ ).
checkhp("false").
checkamm("false").

/*
* Guarda en una variable si hay algún agente aliado en el camino o no
*/
+!agent_in_the_middle( Xe, Ye, Ze )
	<-
	+allies( [] );
	?fovObjects( FOVObjects );
	.length( FOVObjects, Length );
	-+agent_in_the_middle( "false" );
	-+bucle( 0 );
	while ( bucle( X ) & ( X < Length ) ) {
		.nth( X, FOVObjects, Object );
		// Object structure
		// [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
		.nth( 1, Object, Team );
		if ( team( "ALLIED" ) ) {
			if ( Team == 100 ) { // Only if I'm ALLIED
				?allies( Ally );
				.concat( Ally, [Object], Allies );
				-+allies( Allies );
			}
		} else {
			if ( Team == 200 ) { // Only if I'm ALLIED
				?allies( Ally );
				.concat( Ally, [Object], Allies );
				-+allies( Allies );
			}
		}
		-+bucle( X + 1 );
	}

	?allies( Allies );
	.length( Allies, AlliesLength );
	+auxM( 0 );
	while ( auxM( C ) & C < AlliesLength ) {
		.nth( C, Allies, Target );
		.nth( 6, Target, Posicion );
		-+posMiddle( Posicion );
		?posMiddle( pos( Xa, Ya, Za ) );
		?my_position( X, Y, Z );
		if ( math.abs( ( Ze - Z ) * ( Xa - X ) - ( Xe - X ) * ( Za - Z ) ) <= 100 ) {
			-+agent_in_the_middle( "true" );
		}
		-+auxM( C + 1 );
	}
	-auxM( _ );
	-bucle( _ )
	.

/////////////////////////////////
//  GET AGENT TO AIM
/////////////////////////////////
/**
* Calculates if there is an enemy at sight.
*
* This plan scans the list <tt> m_FOVObjects</tt> (objects in the Field
* Of View of the agent) looking for an enemy. If an enemy agent is found, a
* value of aimed("true") is returned. Note that there is no criterion
* (proximity, etc.) for the enemy found. Otherwise, the return value is
* aimed("false")
*
* <em> It's very useful to overload this plan. </em>
*
*/
+!get_agent_to_aim
	<-
	?fovObjects( FOVObjects );
	.length( FOVObjects, Length );
	+enemies( [] );
	+packs( [] );
	+packsamm( [] );
	?my_health(Mivida);
	?my_ammo(Miammo);

	if ( Length > 0 ) {
		+bucle( 0 );
		-+checkhp("false");
		-+checkamm("false");

		while ( bucle( X ) & ( X < Length ) ) {
			.nth( X, FOVObjects, Object );

			// Object structure
			// [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
			.nth( 2, Object, Type );

			if ( Type == 1001 ) {
				.nth( 1, Object, Team );
				?my_formattedTeam( MyTeam );

				if ( team( "ALLIED" ) ) {
					if ( Team == 100 ) {  // Only if I'm ALLIED
						?packs( Packs );
						.concat( Packs, [Object], Packsd );
						-+packs( Packsd );
					}
				} else {
					if ( Team == 200 ) {  // Only if I'm ALLIED
						?packs( Packs );
						.concat( Packs, [Object], Packsd );
						-+packs( Packsd );
					}
				}
			}

			if ( Type == 1002 ) {
				.nth( 1, Object, Team );
				?my_formattedTeam( MyTeam );

				if ( team( "ALLIED" ) ) {
					if ( Team == 100 ) {  // Only if I'm ALLIED
						?packsamm( Packsa );
						.concat( Packsa, [Object], Packsad );
						-+packsamm( Packsad );
					}
				} else {
					if ( Team == 200 ) {  // Only if I'm ALLIED
						?packsamm( Packsa );
						.concat( Packsa, [Object], Packsad );
						-+packsamm( Packsad );
					}
				}
			}

			if( Type <= 1000 ) {
				// Object may be an enemy
				.nth( 1, Object, Team );
				?my_formattedTeam( MyTeam );

				if ( team( "ALLIED" ) ) {
					if ( Team == 200 ) {  // Only if I'm ALLIED
						?enemies( Enem );
						.concat( Enem, [Object], Enemigos );
						-+enemies( Enemigos );
					}
				} else {
					if ( Team == 100 ) {  // Only if I'm ALLIED
						?enemies( Enem );
						.concat( Enem, [Object], Enemigos );
						-+enemies( Enemigos );
					}
				}
			}

			-+bucle( X + 1 );
		}

		if ( Mivida <= 50 ) {
			?packs( PacksVida );
			.length( PacksVida, Pvlength );
			if ( Pvlength > 0 ) {
				!fw_nearest( PacksVida );
				?fw_nearest( Hppack, Pospack, D );
				.nth( 6, Hppack, NewDestination );
				if ( D <= 50 ) {
					-aimed_agent( _ );
					-+aimed( "false" );
					.println( "Voy a por botiquines" );
					-+checkhp("true");
					-+newDest( NewDestination );
					?newDest( pos( Xv, Y, Z ) );
					!fw_add_task(
						task( 7500, "TASK_GOTO_POSITION_3", M, pos( Xv, Y, Z ), "" )
					);
				}
			}
		}

		if ( Miammo < 35 & checkhp( "false" ) ) {
			?packsamm( Packsmuni );
			.length( Packsmuni, Ammlength );
			if( Ammlength > 0 ) {
				!fw_nearest( Packsmuni );
				?fw_nearest( Munipack, Pospack, D );
				.nth( 6, Munipack, NewDestination );
				if( D <= 50 ){
					-aimed_agent( _ );
					-+aimed( "false" );
					.println( "Voy a por municion" );
					-+checkamm( "true" );
					-+newDest( NewDestination );
					?newDest( pos( Xv, Y, Z ) );
					!fw_add_task(
						task(7500, "TASK_GOTO_POSITION_3", M, pos( Xv, Y, Z ), "" )
					);
				}
			}
		}

		if ( checkhp( "false" ) & checkamm( "false" ) ) {
			?enemies( Enem );
			.length( Enem, EnemLength );
			if( EnemLength > 0 ) {
				!fw_nearest( Enem );
				?fw_nearest( Cagent, PosAgent, D );
				.nth( 6, Cagent, NewDestination );
				-+newDest( NewDestination );
				?newDest( pos( Xv, Y, Z ) );
				!agent_in_the_middle( Xv, Y, Z );
				?agent_in_the_middle( Isthereagent );
				if ( Isthereagent == "false" ) {
					+aimed_agent( Cagent );
					-+aimed( "true" );
					.nth( 1, Cagent, Teamagent );
					?team( Myteam );
					.my_team( Myteam, E );
					.length( E, L );
					+auxC( 0 );
					while ( auxC( C ) & C < L ) {
						.nth( C, E, Target );
						.concat( "get_agent_to_aimNew(", Cagent, ")", Messg );
						.send_msg_with_conversation_id( Target, tell, Messg, "INT" );
						-+auxC( C + 1 );
					}
				} else{
					?aimed(Apuntado);
					//.println("Hay tios en medio asi que no cojo el objetivo: ",Apuntado);
				}
			}
		}

	}
	-bucle( _ );
	-auxC( _ )
	.


+get_medipack( Position )[ source( S ) ]
	<-
	-+lapos( Position );
	?lapos( pos( W, J, K ) );
	//.println( "Recibo la posicion: ", W, ",", J, ",", K );
	//.println( "HAN TIRADO UN MEDIPACK" );
	?my_health( Mivida );
	if ( Mivida <= 50 ) {
		//.println( "LO NECESITO" );
		?my_position( X, Y, Z );
		!fw_distance( pos( X, Y, Z ), Position );
		?fw_distance( D );
		if ( D <= 50 ) {
			.println( "Tengo poca vida y estoy cerca, voy a por el medipack" );
			!fw_add_task(
				task( 7500, "TASK_GOTO_POSITION_3", M, Position , "" )
			);
		}
	}
	.

+get_ammopack( Position )[ source( S ) ]
	<-
	-+lapos( Position );
	?lapos( pos( W, J, K ) );
	//.println( "Recibo la posicion: ", W, ",", J, ",", K );
	//.println( "HAN TIRADO UN AMMOPACK" );
	?my_ammo( Miammo );
	if ( Miammo <= 35 ) {
		//.println("LO NECESITO");
		?my_position( X, Y, Z );
		!fw_distance( pos( X, Y, Z ), Position );
		?fw_distance( D );
		if ( D <= 300 ) {
			.println( "Tengo poca vida y estoy cerca, voy a por el ammopack" );
			!fw_add_task(
				task( 7500, "TASK_GOTO_POSITION_3", M, Position , "" )
			);
		}
	}
	.

+get_agent_to_aimNew( Recagente )[ source( S ) ]
	<-
	?aimed( Apuntando );
	?type( Clase );
	if ( not ( Recagente == -1 ) & Apuntando == "false" & Clase == "CLASS_SOLDIER" &
			not ( checkhp( "true" ) ) & not ( checkamm( "true" ) ) ) {
		?my_position( X, Y, Z );
		.nth( 6, Recagente, Posicion );
		-+posMiddle( Posicion );
		?posMiddle( pos( Xa, Ya, Za ) );
		!fw_distance( pos( X, Y, Z ), pos( Xa, Ya, Za ) );
		?fw_distance( D );
		?maxDistToShoot( Maxdist );
		!agent_in_the_middle( Xa, Ya, Za );
		?agent_in_the_middle( Isthereagent );
		if ( D <= Maxdist & Isthereagent == "false") {
			-+aimed_agent( Recagente );
			-+aimed( "true" );
		}
	}
	.

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
	//.println( "AIM ACTION CON : ", Yolouno, ",",Yolodos );
	?fovObjects( FOVObjects );
	.length( FOVObjects, Length );
	?aimed_agent( AimedAgent );

	if ( team( "AXIS" ) ) {
		-+auxmyteamcod( 100 );
	} else {
		-+auxmyteamcod( 200 )
	}

	.nth( 1, AimedAgent, AimedAgentTeam );

	?my_formattedTeam( MyTeam );
	if ( auxmyteamcod( Auxmymyteamcod ) & AimedAgentTeam == Auxmymyteamcod ) {
		.nth( 6, AimedAgent, NewDestination );
		-+newDest( NewDestination );
		?newDest( pos( Xv, Y, Z ) );
		!agent_in_the_middle( Xv, Y, Z );
		?agent_in_the_middle( Isthereagent );

		if ( Isthereagent == "true" ) {
			-aimed_agent( _ );
			-+aimed( "false" );
		} else {
			+bucle( 0 );
			+checker("false");
			.nth( 0, AimedAgent, Nameaimed );
			while ( bucle( X ) & ( X < Length ) ) {
				.nth( X, FOVObjects, Object );
				// Object structure
				// [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
				.nth( 0, Object, Namelist );
				if ( Nameaimed == Namelist ) {  // Only if I'm ALLIED
					-+checker( "true" );
					!fw_follow( Object, 1 );
					?fw_follow( Task );
					!fw_add_task( Task );
					-+bucle( Length );
				} else {
					-+bucle( X + 1 );
				}
			}
			-bucle( _ );

			if ( checker( Check ) & Check == "false" ) {
				-aimed_agent( _ );
				-+aimed( "false" );
			}
			-checker( _ );
		}

	}
	.