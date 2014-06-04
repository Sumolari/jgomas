/////////////////////////////////
//  LOOK RESPONSE
/////////////////////////////////

+look_response( FOVObjects )[ source( M ) ]
	<-
	-look_response( _ )[ source( M ) ];
	-+fovObjects( FOVObjects );
	!look
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
