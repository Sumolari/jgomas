/////////////////////////////////
//  SETUP PRIORITIES
/////////////////////////////////

/**
 * You can change initial priorities if you want to change the behaviour of each
 * agent
 */
+!setup_priorities
	<-
	+task_priority( "TASK_NONE", 0 );
	+task_priority( "TASK_GIVE_MEDICPAKS", 2000 );
	+task_priority( "TASK_GIVE_AMMOPAKS", 0 );
	+task_priority( "TASK_GIVE_BACKUP", 0 );
	+task_priority( "TASK_GET_OBJECTIVE", 1000 );
	+task_priority( "TASK_ATTACK", 1000 );
	+task_priority( "TASK_RUN_AWAY", 1500 );
	+task_priority( "TASK_GOTO_POSITION", 750 );
	+task_priority( "TASK_PATROLLING", 500 );
	+task_priority( "TASK_WALKING_PATH", 750 )
	.