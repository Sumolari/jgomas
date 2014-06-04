debug(3).

// Name of the manager
manager("Manager").

// Team of troop.
team("ALLIED").
// Type of troop.
type("CLASS_SOLDIER").





{ 
    include("jgomas.asl") 
}

{
    include("fw_distance.asl")
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

maxDistToShoot(5).
agent_in_the_middle(_).


/*
* Guarda en una variable si hay algún agente aliado en el camino o no
*/
+!agent_in_the_middle(Xe, Ye, Ze) <-
    +allies([]);
    ?fovObjects(FOVObjects);
    .length(FOVObjects,Length);
    -+agent_in_the_middle( "false" );
    -+bucle(0);
    while (bucle(X) & (X < Length)) {
        //.println("En el bucle, y X vale:", X);
        .nth(X, FOVObjects, Object);
        // Object structure
        // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
        .nth(2, Object, Team);
        if ( Team == 1 ) {  // Only if I'm ALLIED
          ?allies(Ally);
          .concat(Ally,[Object],Allies);
          -+allies(Allies);
        }
      -+bucle(X+1);
    }

    ?allies(Allies);
    .length(Allies, AlliesLength);
    +auxM( 0 );
    while ( auxM( C ) & C < AlliesLength ) {
        .nth( C, Allies, Target );
        .nth( 6, Target, Posicion);
        -+posMiddle( Posicion );
        ?posMiddle( pos(Xa, Ya, Za));
        ?my_position( X, Y, Z);
        if( math.abs((Ze - Z)*(Xa - X) - (Xe - X)*(Za - Z)) <= 2){
            -+agent_in_the_middle( "true" );
        }
      -+auxM(C+1); 
    }
    -auxM(_);
    -bucle(_).



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
<-  ?debug(Mode); if (Mode<=2) { .println("Looking for agents to aim."); }

?fovObjects(FOVObjects);
.length(FOVObjects, Length);
+enemies([]);
?debug(Mode); if (Mode<=1) { .println("El numero de objetos es:", Length); }

if (Length > 0) {
    
    //?aimed_agent(AimedAgent);
    //.println(AimedAgent);
    .println("OBSERVO");
    if(aimed("false")){
      +bucle(0);
      while (bucle(X) & (X < Length)) {
        .nth(X, FOVObjects, Object);
        // Object structure
        // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
        .nth(2, Object, Type);

        ?debug(Mode); if (Mode<=2) { .println("Objeto Analizado: ", Object); }

        if (Type > 1000) {
            ?debug(Mode); if (Mode<=2) { .println("I found some object."); }
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
                ?enemies(Enem);
                .concat(Enem,[Object],Enemigos);
                -+enemies(Enemigos);
              }
          }
        -+bucle(X+1);
      }
    

      ?enemies(Enem);
      .length(Enem, EnemLength);
      if(EnemLength > 0){ 
        !fw_nearest( Enem );
        ?fw_nearest( Cagent, PosAgent, D);
        +aimed_agent( Cagent );
        -+aimed("true");
        .my_team("ALLIED", E);
        .length( E, L );
        +auxC( 0 );
        while ( auxC( C ) & C < L ) {
            .nth( C, E, Target );
            .concat( "get_agent_to_aimNew(", Cagent, ")", Messg );
            .send_msg_with_conversation_id( Target, tell, Messg, "INT" );
            -+auxC( C + 1 );
        }
      }
    } else {
      .println("Ya tengo un objetivo");
    }
  } 
-bucle(_);
-auxC(_).


+get_agent_to_aimNew(Recagente)[source(S)] <-
    ?aimed(Apuntando);
    ?type(Clase);

    if(not (Recagente==-1) & Apuntando == "false" & Clase ==  "CLASS_SOLDIER" ){
      .println("Recibo mensajey EJECUTO EL IF");
      ?my_position( X, Y, Z);
      .nth( 6, Recagente, Posicion);
      -+posMiddle( Posicion );
      ?posMiddle( pos(Xa, Ya, Za));
      !fw_distance( pos( X, Y, Z ), pos( Xa, Ya, Za ) );
      ?fw_distance( D );
      ?maxDistToShoot(Maxdist);
      if( D <= Maxdist ){
            .println("RECIBO UN AGENTE Y LE SIGO");
            -+aimed_agent(Recagente);
            -+aimed("true");
      }
      .println("TERMINO DE EJECUTAR EL IF");
    }.

/////////////////////////////////
//  LOOK RESPONSE
/////////////////////////////////
+look_response(FOVObjects)[source(M)]
    <-  //-waiting_look_response;
        .length(FOVObjects, Length);
        if (Length > 0) {
            ?debug(Mode); if (Mode<=1) { .println("HAY ", Length, " OBJETOS A MI ALREDEDOR:\n", FOVObjects); }
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
+!perform_aim_action <-  // Aimed agents have the following format:
        // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
    ?fovObjects(FOVObjects);
    .length(FOVObjects, Length);
    .println("AIM ACTION");
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
        -+newDest(NewDestination);
        ?newDest(pos(Xv,Y,Z));
        !agent_in_the_middle( Xv, Y, Z);
        ?agent_in_the_middle( Isthereagent);


        +bucle(0);
        +checker("false");
        .nth(0, AimedAgent, Nameaimed);
        while (bucle(X) & (X < Length)) {
          .nth(X, FOVObjects, Object);
          // Object structure
          // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
          .nth(0, Object, Namelist);
          if ( Nameaimed == Namelist ) {  // Only if I'm ALLIED
            -+checker("true");
            .println("VOY A LA POSICION: ", Xv,",",Y,",",Z);
            !fw_follow(Object, 1);
            ?fw_follow(Task);
            .println(Task);
            !fw_add_task(Task);
            -+bucle(Length);
          } else{
            -+bucle(X+1);
          }
        } -bucle(_);

        /*
        if ( Isthereagent == "true"){
            .println("Hay un tio en medio asi que quito target");
            //-aimed_agent(_);
            //-+aimed("false");
        }
        */
        /*
        if(checker(Check) & Check == "false"){
          .println("RETIRO TARGET PORQUE SE ME HA IDO DEL RANGO");
          -aimed_agent(_);
          -+aimed("false");

        }*/
        -checker(_);
        ?debug(Mode);
        if ( Mode <= 1 ) {
            .println("NUEVO DESTINO DEBERIA SER: ", pos(X,Y,Z));
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
+!perform_look_action .
   /// <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_LOOK_ACTION GOES HERE.") }.

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
   /// <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_NO_AMMO_ACTION GOES HERE.") }.

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
    ///<- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_INJURY_ACTION GOES HERE.") }.


/////////////////////////////////
//  SETUP PRIORITIES
/////////////////////////////////
/**  You can change initial priorities if you want to change the behaviour of each agent  **/
+!setup_priorities
    <-  +task_priority("TASK_NONE",0);
        +task_priority("TASK_GIVE_MEDICPAKS", 2000);
        +task_priority("TASK_GIVE_AMMOPAKS", 0);
        +task_priority("TASK_GIVE_BACKUP", 0);
        +task_priority("TASK_GET_OBJECTIVE",1000);
        +task_priority("TASK_ATTACK", 1000);
        +task_priority("TASK_RUN_AWAY", 1500);
        +task_priority("TASK_GOTO_POSITION", 750);
        +task_priority("TASK_PATROLLING", 500);
        +task_priority("TASK_WALKING_PATH", 1750).



/////////////////////////////////
//  UPDATE TARGETS
/////////////////////////////////
/**
 * Action to do when an agent is thinking about what to do.
 *
 * This plan is called at the beginning of the state "standing"
 * The user can add or eliminate targets adding or removing tasks or changing priorities
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */

+!update_targets
	<-	?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR UPDATE_TARGETS GOES HERE.") }.



/////////////////////////////////
//  CHECK MEDIC ACTION (ONLY MEDICS)
/////////////////////////////////
/**
 * Action to do when a medic agent is thinking about what to do if other agent needs help.
 *
 * By default always go to help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
 +!checkMedicAction
     <-  -+medicAction(on).
      // go to help


/////////////////////////////////
//  CHECK FIELDOPS ACTION (ONLY FIELDOPS)
/////////////////////////////////
/**
 * Action to do when a fieldops agent is thinking about what to do if other agent needs help.
 *
 * By default always go to help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
 +!checkAmmoAction
     <-  -+fieldopsAction(on).
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
+!performThresholdAction
       <-

       ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_TRESHOLD_ACTION GOES HERE.") }

       ?my_ammo_threshold(At);
       ?my_ammo(Ar);

       if (Ar <= At) {
          ?my_position(X, Y, Z);

         .my_team("fieldops_ALLIED", E1);
         //.println("Mi equipo intendencia: ", E1 );
         .concat("cfa(",X, ", ", Y, ", ", Z, ", ", Ar, ")", Content1);
         .send_msg_with_conversation_id(E1, tell, Content1, "CFA");


       }

       ?my_health_threshold(Ht);
       ?my_health(Hr);

       if (Hr <= Ht) {
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




+cfm_agree[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_agree GOES HERE.")};
      -cfm_agree.

+cfa_agree[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_agree GOES HERE.")};
      -cfa_agree.

+cfm_refuse[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_refuse GOES HERE.")};
      -cfm_refuse.

+cfa_refuse[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_refuse GOES HERE.")};
      -cfa_refuse.



/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!init
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR init GOES HERE.")}.



