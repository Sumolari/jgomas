{ include( "fw_safe_pos.asl" ) }

// Given two positions, returns the euclidean distance.
// Note that this might not be the real shortest distance (walls).
// @results +fw_distance( Nx, Y, Nz )
// Usage:
/*
	!fw_distance( pos( 0, 0, 0 ), pos ( 4, 0, 3 ) );
	?fw_distance( D );
	.println( "Distance is ", D );
*/
+!fw_distance( pos( A, B, C ), pos( X, Y, Z ) )
	<-
	D = math.sqrt( ( A - X ) * ( A - X ) + ( B - Y ) * ( B - Y ) + ( C - Z ) * ( C - Z ) );
	-+fw_distance( D )
	.

// Given a list of agents, returns the nearest one to the agent using this plan.
// Note that this might not be the real shortest distance (walls).
// @results +fw_nearest( Agent, Position, Distance )
// Usage:
/*
	!fw_nearest( Agents );
	?fw_nearest( Agent, Position, Distance );
	.println( "Nearest agent is ", Agent, " who is at ", Position, " (distance ", Distance, ")"  );
*/
+!fw_nearest( Agents )
	<-
	// Save an arbitrary solution.
	-+fw_nearest( -1, pos( -1, -1, -1 ), 9999 );
	// Store internal counter.
	+fwn_aux_c( 0 );
	// Store length of list of agents.
	.length( Agents, L );
	// Retrieve my position.
	?my_position( Myx, Myy, Myz );
	// While there are unchecked agents...
	while( fwn_aux_c( C ) & C < L ) {
		// Retrieve agent.
		.nth( C, Agents, Target );
		// Extract position.
		.nth( 6, Target, Targetposition );
		// Compute distance.
		!fw_distance( pos( Myx, Myy, Myz ), Targetposition );
		?fw_distance( D );
		// Get previous minimum distance.
		?fw_nearest( _, _, Prevd );
		// If new one is lower...
		if ( D < Prevd ) {
			// Save new nearest agent.
			-+fw_nearest( Target, Targetposition, D );
		}
		// Update counter.
		-+fwn_aux_c( C + 1 );
	}
	// Clean auxiliar beliefs.
	-+fwn_aux_c( 0 );
	-fwn_aux_c( 0 )
	.

// Given an Agent, returns the task to follow that agent with a threshold.
// Note that this plan will return -1 if it is not possible to find such a
// position.
//
// @results +fw_follow( Task ) || +fw_follow( -1 )
//
// Usage:
/*
	!fw_follow( Agents, Threshold );
	?fw_follow( Task );
	!add_task( Task )
*/

// In case an invalid agent is given.
+!fw_follow( -1, Threshold )
	<-
	-+fw_follow( -1 );
	.

+!fw_follow( Agent, Threshold )
	<-
	// Extract agent position.
	//.println( Agent );
	.nth( 6, Agent, Pos );
	//.println( Pos );
	-+fw_follow( Pos );
	?fw_follow( pos( Tx, Ty, Tz ) );
	-fw_follow( Pos );
	// Get my position.
	?my_position( Myx, Myy, Myz );
	// Compute current distance.
	!fw_distance( pos( Myx, Myy, Myz ), pos( Tx, Ty, Tz ) );
	?fw_distance( Previousdistance );
	// Compute desired location.
	if ( Myx > Tx ) {
		-+fw_follow_dest_x( Tx + Threshold );
	} else {
		-+fw_follow_dest_x( Tx - Threshold );
	}
	if ( Myz > Tz ) {
		-+fw_follow_dest_z( Tz + Threshold );
	} else {
		-+fw_follow_dest_z( Tz - Threshold );
	}
	// Extract desired location.
	?fw_follow_dest_x( Dx );
	?fw_follow_dest_z( Dz );
	// Clean beliefs.
	-fw_follow_dest_x( Dx );
	-fw_follow_dest_z( Dz );
	// Get nearest valid position.
	!fw_safe_pos( Dx, 0, Dz );
	?fw_safe_pos( Fx, Fy, Fz );
	// Compute new distance.
	!fw_distance( pos( Fx, Fy, Fz ), pos( Tx, Ty, Tz ) );
	?fw_distance( Newdistance );
	if ( Newdistance < Previousdistance ) {
		-+fw_follow( task( 3000, "TASK_FW_FOLLOW", M, pos( Fx, Fy, Fz ), "" ) );
	} else {
		-+fw_follow( -1 );
	}
	.