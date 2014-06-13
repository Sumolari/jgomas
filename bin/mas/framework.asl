/////////////////////////////////
//  Beliefs used by framework
/////////////////////////////////

currentActionPriority( 0 ).
fwDebug( 3 ).

/////////////////////////////////
//  Framework
/////////////////////////////////

position( valid ). // Weird bug.
shouldContinue("YES").
currentObjective(0, 0, 0).

+!log( Text, Level ) <-
	?fwDebug( Mode );
	if ( Mode <= Level ) {
		.length( Text, L );
		+auxC( 0 );
		+auxContent( "" );
		while( auxC( C ) & C < L ) {
			.nth( C, Text, T );
			?auxContent( PreviousContent );
			.concat( PreviousContent, T, Content );
			-+auxContent( Content );
			-+auxC( C + 1 );
		}
		-auxContent( Content );
		-auxC( C );
	}
	.

+flagpos(Fx, Fy, Fz)[source(A)] <-
	-+tasks([]);
	!fw_add_task(
		task(
			4500,
			"TASK_MEAT_SHIELD",
			M,
			pos(
				Fx,
				0,
				Fz
			),
			""
		)
	);
	-flagpos(Fx, Fy, Fz)[source(A)]
	.

+!fw_add_task( task( Priority, Order, Agent, pos( X, Y, Z ), Desc ) ) :
	currentActionPriority( CurrentPriority ) <-
	check_position( pos( X, Y, Z ) );
	?position( V );
	if ( V == valid ) {
		!add_task( task( Priority, Order, Agent, pos( X, Y, Z ), Desc ) );
		if ( Priority > CurrentPriority ) {
			-+state(standing);
			-+currentObjective(X, Y, Z);
			-+shouldContinue("NO");
		}
	}
	.

+!check_task_end <-
	?my_position(X, Y, Z);
	?currentObjective(Ox, Oy, Oz);

	RX = math.round(X);
	RZ = math.round(Z);
	if( Ox - RX < 2 & RX - Ox < 2 & Oz - RZ < 2 & RZ - Oz < 2 ){
		-+shouldContinue("YES");
	}
	.

+!map_12
	<-
	-+map_12( no );
	check_position( pos( 115, 0, 44 ) ); // Maybe
	if ( position( invalid ) ) {
		check_position( pos( 125, 0, 210 ) ); // Sure
		if ( position( invalid ) ) {
			-+map_12( yes );
		}
	}
	.

/**
 * Replaces item at given position for given item in array stored in my_array belief.
 */

+!replace( Item, 0 )
	:
	my_array( Array ) &                            // Pilla el array
	.length( Array, Arraylength ) &                // Longitid original
	.sublist( Y, Array ) &                         // Pilla cualquier sublista (queremos la segunda mitad)
	.length( Y, Arraylength - 1 ) &                // Fuerza que la sublista tenga la longitud de la segunda mitad menos 1
	.nth( 1, Array, Half ) &                       // Pilla el item que está después de que estás editanto
	.nth( 0, Y, Half )                             // Fuerza que la segunda mitad comience donde se espera
	<-
	// Crea el nuevo array.
	.concat( [ Item ], Y, Union );
	// Guárdalo.
	-+my_array( Union )
	.

+!replace( Item, Position )
	:
	my_array( Array ) &                            // Pilla el array
	.length( Array, Position + 1 ) &               // Longitid original
	.sublist( X, Array ) &                         // Pilla cualquier sublista (queremos la primera mitad)
	.length( X, Position ) &                       // Fuerza que la sublista tenga la longitud de la primera mitad
	.nth( 0, Array, First ) &                      // Pilla el primer item de la lista original
	.nth( 0, X, First )                            // Fuerza que la sublista comience en la primera mitad
	<-
	// Crea el nuevo array.
	.concat( X, [ Item ], Union );
	// Guárdalo.
	-+my_array( Union )
	.

+!replace( Item, Position )
	:
	my_array( Array ) &                            // Pilla el array
	.length( Array, Arraylength ) &                // Longitid original
	.sublist( X, Array ) &                         // Pilla cualquier sublista (queremos la primera mitad)
	.length( X, Position ) &                       // Fuerza que la sublista tenga la longitud de la primera mitad
	.nth( 0, Array, First ) &                      // Pilla el primer item de la lista original
	.nth( 0, X, First ) &                          // Fuerza que la sublista comience en la primera mitad
	.sublist( Y, Array ) &                         // Pilla cualquier sublista (queremos la segunda mitad)
	.length( Y, ( Arraylength - Position ) - 1 ) & // Fuerza que la sublista tenga la longitud de la segunda mitad menos 1
	.nth( Position + 1, Array, Half ) &            // Pilla el item que está después de que estás editanto
	.nth( 0, Y, Half )                             // Fuerza que la segunda mitad comience donde se espera
	<-
	// Crea el nuevo array.
	.concat( X, [ Item ], Y, Union );
	// Guárdalo.
	-+my_array( Union )
	.