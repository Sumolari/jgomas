{ include( "framework.asl" ) }

{ include( "fw_distance.asl" ) }

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
+!performThresholdAction
	<-
	?my_ammo_threshold( At );
	?my_ammo( Ar );

	?team( Myteam );
	.concat( "fieldops_", Myteam, Desiredammoteam );
	.concat( "medic_", Myteam, Desiredmedicteam );

	if ( Ar <= At ) {
		?my_position( X, Y, Z );
		.my_team( Desiredammoteam, E1 );
		.concat( "fw_cfa(", X, ", ", Y, ", ", Z, ", ", Ar, ")", Content1 );
		.send_msg_with_conversation_id( E1, tell, Content1, "CFA" );
	}

	?my_health_threshold( Ht );
	?my_health( Hr );

	if ( Hr <= Ht ) {
		?my_position( X, Y, Z );
		.my_team( Desiredmedicteam, E2 );
		.concat( "fw_cfm(", X, ", ", Y, ", ", Z, ", ", Hr, ")", Content2 );
		.send_msg_with_conversation_id( E2, tell, Content2, "CFM" );
	}
	.

/////////////////////////////////
//  ATENDER PETICION CALL FOR
//  AMMO (SOLO FIELDOPS)
/////////////////////////////////

// Soy Fieldops y me han pedido ayuda.
+fw_cfa( X, Y, Z, Ammo )[ source( M ) ]
	<-
	// Get my position.
	?my_position( Myx, Myy, Myz );
	// Get distance.
	!fw_distance( pos( X, Y, Z ), pos( Myx, Myy, Myz ) );
	?fw_distance( Dist );
	// If distance is lower than threshold.
	if ( Dist < 125 & Ammo < 30 ) {
		// Give ammo.
		!fw_add_task( task( 9999, "TASK_GIVE_AMMOPAKS", M, pos( X, Y, Z ), "" ) );
		//.send(M, tell, "cfa_agree");
		.concat( "cfa_agree", Content );
		.send_msg_with_conversation_id( M, tell, Content, "CFA" );
		-+state( standing );
	} else {
		// Ingore.
		//.send(M, tell, "cfa_refuse");
		.concat("cfm_refuse", Content);
		.send_msg_with_conversation_id(M, tell, Content, "CFA");
	}
	-fw_cfa( _ )[ source( M ) ]
	.

/////////////////////////////////
//  ATENDER PETICION CALL FOR
//  MEDIC  (SOLO MEDICOS)
/////////////////////////////////

// Soy medico y me han pedido ayuda
+fw_cfm( X, Y, Z, Salud )[ source( M ) ]
	<-
	// Get my position.
	?my_position( Myx, Myy, Myz );
	// Get distance.
	!fw_distance( pos( X, Y, Z ), pos( Myx, Myy, Myz ) );
	?fw_distance( Dist );
	// If distance is lower than threshold.
	if ( Dist < 75 & Salud < 25 ) {
		// Give medpack.
		!fw_add_task( task( 9999, "TASK_GIVE_MEDICPAKS", M, pos( X, Y, Z ), "" ) );
		// .send(M, tell, "cfm_agree");
		.concat( "cfm_agree", Content );
		.send_msg_with_conversation_id( M, tell, Content, "CFM" );
		.concat( "+get_medipack( ",pos(Myx,Myy,Myz),")", Messg );
		?team(Miequipo);
		.my_team( Miequipo, E );
		.length( E, L );
		+auxC( 0 );
		while ( auxC( C ) & C < L ) {
			.nth( C, E, Target );
			.send_msg_with_conversation_id( Target, tell, Messg, "INT" );
			-+auxC( C + 1 );
		}
		-auxC( _ );
		-+state( standing );
	} else {
		// Ingore.
		//.send(M, tell, "cfm_refuse");
		.concat( "cfm_refuse", Content );
		.send_msg_with_conversation_id( M, tell, Content, "CFM" );
	}
	-fw_cfm( _ )[ source( M ) ]
	.

/////////////////////////////////
//  NO_RESOURCE_ACTION
/////////////////////////////////

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