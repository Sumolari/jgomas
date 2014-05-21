{ include( "fw_safe_pos.asl" ) }

// Given a list of positions ([pos(X,Y,Z)]), enqueues tasks to reach each one of
// them in given order, converting unsafe positions to safe positions.
// Agent will finish where it started.
//
// @warning This method alters enqueued tasks!
//
// Usage:
/*
	!fw_patrol( [ pos( 50, 0, 50 ), pos( 75, 0, 50 ), pos( 75, 0, 75 ), pos( 50, 0, 75 ) ] );
	?fw_safe_pos( X, Y, Z );
	.println( "It is safe to go to pos( ", X, ", ", Y, ", ", Z, " )" );
*/
+!fw_patrol( Points )
	<-
	// Get amount of points.
	.length( Points, L );
	// Create counter.
	+fw_patrol_c( 0 );
	// For each point in patrol...
	while( fw_patrol_c( C ) & C < L ) {
		// Generate task's name.
		.concat( "TASK_FW_PATROL_", C, Taskname );
		// Get target point.
		.nth( C, Points, Targetpoint );
		// Store it in an auxiliar value to get components.
		-+fw_patrol_aux( Targetpoint );
		// Extract target position.
		?fw_patrol_aux( pos( Tx, Ty, Tz ) );
		// Remove auxiliar belief.
		-fw_patrol_aux( Targetpoint );
		// Get nearest safe position.
		!fw_safe_pos( Tx, Ty, Tz );
		?fw_safe_pos( Fx, Fy, Fz );
		// Enqueue task to get there.
		!add_task( task( 3000 - C, Taskname, M, pos( Fx, Fy, Fz ), "" ) );
		// Enqueue origin.
		if ( C + 1 == L ) {
			.nth( 0, Points, Startingpoint );
			// Store it in an auxiliar value to get components.
			-+fw_patrol_aux( Startingpoint );
			// Extract target position.
			?fw_patrol_aux( pos( Sx, Sy, Sz ) );
			// Remove auxiliar belief.
			-fw_patrol_aux( Startingpoint );
			// Get nearest safe position.
			!fw_safe_pos( Sx, Sy, Sz );
			?fw_safe_pos( Fsx, Fsy, Fsz );
			// Enqueue task to get there.
			!add_task( task( 3000 - C - 1, "TASK_RETURN_PATROL", M, pos( Fsx, Fsy, Fsz ), "" ) );
		}
		// Increase counter.
		-+fw_patrol_c( C + 1 );
	}
	// Clean auxiliar beliefs.
	?fw_patrol_c( Fc );
	-fw_patrol_c( Fc );
	.