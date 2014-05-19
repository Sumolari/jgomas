debug(3).

// Name of the manager
manager("Manager").

// Team of troop.
team("ALLIED").
// Type of troop.
type("CLASS_FIELDOPS").

{
	include("jgomas.asl")
}

{
	include("framework.asl")
}

// Plans

/*******************************
*
* Actions definitions
*
*******************************/

/////////////////////////////////
/// CUSTOM ACTIONS
/////////////////////////////////

following("NO").
go_now(0).
in_pos(false).
everybodyReady("YES").

+!do_nothing <-
	//~ ?state(State);
	//~ ?tasks(Tasks);
	//~ .println("State: ", State, "  Tasks:", Tasks);
	-+go_now(10);
	.

+!do_algo : go_now(N) & N > 0 <-
	//~ ?state(State);
	//~ ?tasks(Tasks);
	//~ .println("State algo: ", State, "  Tasks algo:", Tasks);
	-+state(standing);
	-+tasks([]);
	-+go_now(0)
	.

+!go_com_pos : shouldContinue("YES") & everybodyReady("YES") <-
	.wait(1000);
	?my_position(X,Y,Z);
	RX = math.round(X)+30;
	RZ = math.round(Z)+30;
	.println( "De camino a la posicion de comandancia ", RX, " ", Y, " ", RZ );
	
	!fw_add_task(
		task(
			7500,
			"TASK_GOTO_POSITION_3",
			M,
			pos(
				RX,
				0,
				RZ
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
			.concat( "cmdpos(", RX, ",", 0, ",", RZ + 20, ")", Messg );
		}
		if ( C == 1 ) {
			.concat( "cmdpos(", RX + 20, ",", 0, ",", RZ, ")", Messg );
		}
		if ( C == 2 ) {
			.concat( "cmdpos(", RX - 20, ",", 0, ",", RZ, ")", Messg );
		}
		if ( C == 3 ) {
			.concat( "cmdpos(", RX + 30, ",", 0, ",", RZ - 20, ")", Messg );
		}
		if ( C == 4 ) {
			.concat( "cmdpos(", RX - 30, ",", 0, ",", RZ - 20, ")", Messg );
		}
		if ( C == 5 ) {
			.concat( "cmdpos(", RX + 10, ",", 0, ",", RZ - 20, ")", Messg );
		}
		if ( C == 6 ) {
			.concat( "cmdpos(", RX - 10, ",", 0, ",", RZ - 20, ")", Messg );
		}
		//!log( [ "Ordered: ", Messg, " to ", Target, " (", C, ")" ], 2 );
		.println( "Ordered: ", Messg, " to ", Target, " (", C, ")" );
		.send_msg_with_conversation_id( Target, tell, Messg, "INT" );
		-+auxC( C + 1 );
	}
	
	.
	
+!go_com_pos <-
	!check_task_end
	.

+soldierIsReady[source(V)] <- 
	?waitingFor(W);
	-+waitingFor(W-1);
	.println(W-1, " more to go!");
	-soldierIsReady[source(V)]
	.

+waitingFor(0) <- 
	.wait(2000);
	-waitingFor(0);
	-+everybodyReady( "YES" )
	.

+waitingFor(W) : W > 0 <-
	-+everybodyReady( "NO" )
	.

/*
+!command : in_pos(C) & C <-
	
	.
	
+!command .*/
	
+!check_the_pos : com_pos(Ex, Wy, Zt) <-
	?my_position(X,Y,Z);
	
	if( math.round(X) == Ex & math.round(Z) == Zt ){
		-+in_pos(true);
		.println("I am in position!");
	}
	.

+!do_algo .

/**
 * "Callback" que se ejecuta cada vez que el agente percibe objetos en su punto
 * de vista.
 */
+!perform_look_action_follow_agent : following( TEAM ) & TEAM > 0 <-
	?fovObjects(FOVObjects);
	.length( FOVObjects, L );
	+auxC( 0 );
	+targetFound( "NO" );
	//.println(FOVObjects);
	while ( auxC( C ) & L > C & targetFound( "NO" ) ) {
		.nth( C, FOVObjects, A );
		.nth( 1, A, Equipo );
		//.println( A );
		if ( Equipo == TEAM ) {
			.nth( 6, A, Posicion);
			//.println( "Voy hacia: ", Posicion );
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
	-auxC(_);

	if ( targetFound( "NO" ) ) {
		//.println( "No veo a quien seguir..." );
	}

	-targetFound(_);
	.

+!perform_look_action_follow_agent .

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
+!get_agent_to_aim <-
	?debug(Mode);
	if ( Mode <= 2 ) {
		.println( "Looking for agents to aim." );
	}
	?fovObjects(FOVObjects);
	.length( FOVObjects, Length );

	?debug(Mode);
	if ( Mode <= 1 ) {
		.println( "El numero de objetos es:", Length );
	}

	if ( Length > 0 ) {
		+bucle(0);
		-+aimed("false");

		while ( aimed("false") & bucle(X) & ( X < Length ) ) {

			//.println("En el bucle, y X vale:", X);

			.nth( X, FOVObjects, Object );
			// Object structure
			// [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
			.nth( 2, Object, Type );

			?debug(Mode);
			if ( Mode <= 2 ) {
				.println( "Objeto Analizado: ", Object );
			}

			if ( Type > 1000 ) {
				?debug(Mode);
				if ( Mode <= 2 ) {
					.println( "I found some object." );
				}
			} else {
				// Object may be an enemy
				.nth(1, Object, Team);
				?my_formattedTeam(MyTeam);

				if ( Team == 200 ) {  // Only if I'm ALLIED
					?debug(Mode);
					if (Mode<=2) {
						.println( "Aiming an enemy. . .",
						           MyTeam, " ",
						           .number(MyTeam),
						           " ",
						           Team,
						           " ",
						           .number(Team)
						        );
					}
					+aimed_agent(Object);
					-+aimed("true");
					.my_team("ALLIED",E);
					?my_position(Equis,Igrega,Ceta);
					.concat("cmdpos(",Equis,",",Igrega,",",Ceta,")",Lapos);
					.send_msg_with_conversation_id(E,achieve,Lapos,"INT");
				}
			}

			-+bucle(X+1);
		}
	}

	-bucle(_).

/////////////////////////////////
//  LOOK RESPONSE
/////////////////////////////////

+look_response(FOVObjects)[source(M)] <-
	//-waiting_look_response;
	.length( FOVObjects, Length );
	if ( Length > 0 ) {
		/*
		?debug(Mode);
		if ( Mode <= 1 ) {
			.println("HAY ", Length, " OBJETOS A MI ALREDEDOR:\n", FOVObjects);
		}
		*/
	};
	-look_response(_)[source(M)];
	-+fovObjects(FOVObjects);
	//.//;
	!look.

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
+!perform_aim_action <-
	// Aimed agents have the following format:
	// [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
	?aimed_agent(AimedAgent);
	?debug(Mode);
	if (Mode<=1) {
		.println("AimedAgent ", AimedAgent);
	}

	.nth(1, AimedAgent, AimedAgentTeam);
	?debug(Mode);
	if ( Mode <= 2 ) {
		.println( "BAJO EL PUNTO DE MIRA TENGO A ALGUIEN DEL EQUIPO ",
		          AimedAgentTeam
		        );
	}

	?my_formattedTeam(MyTeam);
	if ( AimedAgentTeam == 200 ) {
		.nth( 6, AimedAgent, NewDestination );
		?debug(Mode);
		if ( Mode <= 1 ) {
			.println("NUEVO DESTINO DEBERIA SER: ", NewDestination);
		}
	}
 	.

/**
* Action to do when the agent is looking at.
*
* This plan is called just after Look method has ended.
*
* <em> It's very useful to overload this plan. </em>
*
*/
+!perform_look_action <-
	!do_algo
	.
	/*
	<-
	?debug(Mode);
	if ( Mode <= 1 ) {
		.println("YOUR CODE FOR PERFORM_LOOK_ACTION GOES HERE.")
	}
	.
	*/

/**
* Action to do if this agent cannot shoot.
*
* This plan is called when the agent try to shoot, but has no ammo. The
* agent will spit enemies out. :-)
*
* <em> It's very useful to overload this plan. </em>
*
*/
+!perform_no_ammo_action .
   /*
	<-
	?debug(Mode);
	if ( Mode <= 1 ) {
		.println("YOUR CODE FOR PERFORM_NO_AMMO_ACTION GOES HERE.")
	}
	.
	*/

/**
 * Action to do when an agent is being shot.
 *
 * This plan is called every time this agent receives a messager from
 * agent Manager informing it is being shot.
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!perform_injury_action .
	/*
	<-
	?debug(Mode);
	if ( Mode <= 1 ) {
		.println("YOUR CODE FOR PERFORM_INJURY_ACTION GOES HERE.")
	}
	.
	*/

/////////////////////////////////
//  SETUP PRIORITIES
/////////////////////////////////

/**
 * You can change initial priorities if you want to change the behaviour of
 * each agent
 */
+!setup_priorities <-
	+task_priority("TASK_NONE",0);
	+task_priority("TASK_GIVE_MEDICPAKS", 0);
	+task_priority("TASK_GIVE_AMMOPAKS", 2000);
	+task_priority("TASK_GIVE_BACKUP", 0);
	+task_priority("TASK_GET_OBJECTIVE",1000);
	+task_priority("TASK_ATTACK", 1000);
	+task_priority("TASK_RUN_AWAY", 1500);
	+task_priority("TASK_GOTO_POSITION", 750);
	+task_priority("TASK_PATROLLING", 500);
	+task_priority("TASK_WALKING_PATH", 1750);
	+task_priority("TASK_SQUARE_PATROL",5000).

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

+!update_targets <-
	?my_position(X, Y, Z);
	if ( X == 0 & Z == 0 ){
		!do_nothing;
	}
	else {
		//?everybodyReady(R);
		//.println(R);
		!go_com_pos;
		//.println("commander pos: ", X, "  ", Y, "  ", Z);
	}
	?debug(Mode);
	if ( Mode <= 1 ) {
		.println("YOUR CODE FOR UPDATE_TARGETS GOES HERE.")
	}
	.

/////////////////////////////////
//  CHECK MEDIC ACTION (ONLY MEDICS)
/////////////////////////////////

/**
 * Action to do when a medic agent is thinking about what to do if other agent
 * needs help.
 *
 * By default always go to help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!checkMedicAction <-
	-+medicAction(on).
	// go to help


/////////////////////////////////
//  CHECK FIELDOPS ACTION (ONLY FIELDOPS)
/////////////////////////////////

/**
 * Action to do when a fieldops agent is thinking about what to do if other
 * agent needs help.
 *
 * By default always go to help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!checkAmmoAction <-
	-+fieldopsAction(on).
	//  go to help



/////////////////////////////////
//  PERFORM_TRESHOLD_ACTION
/////////////////////////////////
/**
 * Action to do when an agent has a problem with its ammo or health.
 *
 * By default always calls for help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!performThresholdAction <-

	?debug(Mode);
	if ( Mode <= 1 ) {
		.println("YOUR CODE FOR PERFORM_TRESHOLD_ACTION GOES HERE.")
	}

	?my_ammo_threshold(At);
	?my_ammo(Ar);

	if ( Ar <= At ) {
		?my_position(X, Y, Z);

		.my_team("fieldops_ALLIED", E1);
		//.println("Mi equipo intendencia: ", E1 );
		.concat("cfa(",X, ", ", Y, ", ", Z, ", ", Ar, ")", Content1);
		.send_msg_with_conversation_id(E1, tell, Content1, "CFA");
	}

	?my_health_threshold(Ht);
	?my_health(Hr);

	if ( Hr <= Ht ) {
		?my_position(X, Y, Z);

		.my_team("medic_ALLIED", E2);
		//.println("Mi equipo medico: ", E2 );
		.concat("cfm(",X, ", ", Y, ", ", Z, ", ", Hr, ")", Content2);
		.send_msg_with_conversation_id(E2, tell, Content2, "CFM");
	}
	.

/////////////////////////////////
//  ANSWER_ACTION_CFM_OR_CFA
/////////////////////////////////

+cfm_agree[source(M)] <-
	?debug(Mode);
	if ( Mode <= 1 ) {
		.println("YOUR CODE FOR cfm_agree GOES HERE.")
	};
	-cfm_agree.

+cfa_agree[source(M)] <-
	?debug(Mode);
	if ( Mode <= 1 ) {
		.println("YOUR CODE FOR cfa_agree GOES HERE.")
	};
	-cfa_agree.

+cfm_refuse[source(M)] <-
	?debug(Mode);
	if ( Mode <= 1 ) {
		.println("YOUR CODE FOR cfm_refuse GOES HERE.")
	};
	-cfm_refuse.

+cfa_refuse[source(M)] <-
	?debug(Mode);
	if ( Mode <= 1 ) {
		.println("YOUR CODE FOR cfa_refuse GOES HERE.")
	};
	-cfa_refuse.

/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!init <-
	?debug(Mode);
	if ( Mode <= 1 ) {
		.println("YOUR CODE FOR init GOES HERE.")
	}
	
	.
