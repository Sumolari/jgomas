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
+!fw_nearest( Agents ) //: .length( Agents, Length ) & Length > 0
	<-
	// Save an arbitrary solution.
	-+fw_nearest( yolo, pos( -1, -1, -1 ), 9999 );
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

// Fallback.
//+!fw_nearest( Agents ) .
	.