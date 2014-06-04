debug(3).

// Name of the manager
manager("Manager").

// Team of troop.
team("AXIS").
// Type of troop.
type("CLASS_FIELDOPS").

// Value of "closeness" to the Flag, when patrolling in defense
patrollingRadius(40).

// Import needed modules.

{ include("jgomas.asl") }

{ include("fw_priorities.asl") }

{ include("fw_communication.asl") }

{ include("fw_resources.asl") }

{ include("fw_aim.asl") }

{ include("fw_look.asl") }

/*******************************
*
* Actions definitions
*
*******************************/

/**
 * Action to do when the agent is looking at.
 *
 * This plan is called just after Look method has ended.
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!perform_look_action .

/////////////////////////////////
//  UPDATE TARGETS
/////////////////////////////////

/**
 * Action to do when an agent is thinking about what to do.
 *
 * This plan is called at the beginning of the state "standing"
 * The user can add or eliminate targets adding or removing tasks or changing
 * priorities
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!update_targets .

/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!init .