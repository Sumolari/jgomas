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
