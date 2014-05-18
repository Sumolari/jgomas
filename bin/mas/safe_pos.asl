
// @todo Check positions by increasing coordinates.
// Given X, Y and Z, computes the nearest valid position.
// @results +safe_pos( Nx, Y, Nz )
+!safe_pos( X, Y, Z )
	<-
	// Internal belief to store the position being checked.
	+fw_new_pos( X, Z );
	// Reset position's validity belief.
	check_position( pos( X, 0, Z ) );
	?position( V );
	// While the position is not valid...
	while ( position( invalid ) ) {
		?fw_new_pos( Nx, Nz );
		// While we can decrease X coordinate.
		while ( position( invalid ) & fw_new_pos( I, _ ) & I > 0 ) {
			// Retrieve the position being checked.
			?fw_new_pos( Mediumnx, Mediumnz );
			// Store Nz in a new belief to not modify the originals.
			+fw_new_pos_fixed_x( Mediumnz );
			// While we can decrease Z coordinate.
			while ( position( invalid ) & fw_new_pos_fixed_x( N ) & N > 0 ) {
				?fw_new_pos_fixed_x( Innernxz );
				// Forget about previously invalid position.
				-position( invalid );
				// Try reducing Z by 1.
				// Check position retrieved. Note that we maintain Y coord.
				check_position( pos( Mediumnx, 0, Innernxz - 1 ) );
				?position( P );
				// Store new value of auxiliar variable.
				-+fw_new_pos_fixed_x( Innernxz - 1 );
			}
			// Either we reached Z < 0 or we found a valid position.
			// We restore Nz to try reducing Nx next time.
			-+fw_new_pos_fixed_x( Mediumnz );
			-fw_new_pos_fixed_x( Mediumnz );
			// We reduce Nx.
			-+fw_new_pos( Mediumnx - 1, Mediumnz );
		}
		// Retrieve results.
		?fw_new_pos( Ax, Az );
		// Check position retrieved. Note that we maintain Y coord.
		check_position( pos( Ax, Y, Az ) );
		// Store new position to be checked.
		-+fw_new_pos( Ax, Az );
	}
	?fw_new_pos( Nx, Nz );
	// Forget about position validity.
	-position( valid );
	// Forget about position to be checked.
	?fw_new_pos( RemoveX, RemoveZ );
	-fw_new_pos( RemoveX, RemoveZ );
	// Return valid position with belief named as function.
	-+safe_pos( Nx + 1, Y, Nz + 1 );
	-position( valid )
	.